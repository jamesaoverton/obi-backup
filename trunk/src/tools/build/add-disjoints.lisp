(defun build-disjoints ()
  (write-disjoints (load-kb-jena "obi:newids;obil.owl") "obi:newids;disjoints.owl"))

(defun write-disjoints (&optional (kb (load-kb-jena :obi)) (path "obi:branches;disjoints.owl"))
  (loop 
     with parent2child = (make-hash-table)
     with labels = (make-hash-table)
     for (sub super subname supername) in
       (sparql '(:select (?sub ?super ?subname ?supername) (:distinct t)
		 (?sub !rdfs:subClassOf ?super)
		 (:optional (?sub !rdfs:label ?subname))
		 (:optional (?super !rdfs:label ?supername))
		 (:filter (not (or (isblank ?sub) (isblank ?super)))))
	       :kb kb
	       :use-reasoner :none)
       ; build a tree
       do
       (pushnew sub (gethash super parent2child))
       (setf (gethash sub labels) subname)
       (setf (gethash super labels) supername)
       finally
       ; iterate downward from bfo:entity. If you hit a junk class (starts with "_") stop
       ; otherwise add mutual disjoints between the obi classes, and disjoints from them to the other siblings BUT
       ; don't add a disjoint from a defined class to anything else. 
       (flet ((labels-of (uris)
		(mapcar (lambda(el) (gethash el labels)) uris)))
	 (loop with queue = (list !<http://www.ifomis.org/bfo/1.1#Entity>) 
	    with defined-classes = (defined-classes kb)
	    with all-disjoints = nil
	    for root = (pop queue)
	    for children = (gethash root parent2child)
	    for obi-children = (mapcan (lambda(c)
					 (when (#"matches" (uri-full c) "http://purl.obofoundry.org/obo/OBI_\\d+")
					   (list c)))
				       children)
	    for ignore-children = (mapcan (lambda(c)
					    (when (or (and (gethash c labels) (#"matches" (gethash c labels) "_.*"))
						      (member c defined-classes))
					      (list c)))
					  children)
	    for other-children = (set-difference (set-difference children obi-children) ignore-children)
	    when (and obi-children
		      (or (eq root !<http://purl.obofoundry.org/obo/OBI_0000141>)
			  (not (member root defined-classes)))
		      (or (not (gethash root labels))
			  (and (gethash root labels) (not (#"matches" (gethash root labels) "_.*"))))
		      )
	    do (progn
		 (when nil		;debug
		   (print-db (or (gethash root labels) root) (labels-of obi-children) (labels-of ignore-children) other-children))
		 (let ((obi-disjoints (set-difference obi-children ignore-children)))
		   (when (>= (length obi-disjoints) 2)
		     (push `(disjoint-classes ,@obi-disjoints) all-disjoints))
		   (dolist (other other-children)
		     (dolist (obi obi-children)
		       ;(print-db other-children)
		       (push `(disjoint-classes ,obi ,other) all-disjoints)))))
	    do (setf queue (append queue obi-children other-children))
	    until (null queue)
	    finally (eval `(with-ontology disjoints (:base "http://purl.obofoundry.org/obo/obi/disjoints.owl")
			       ,all-disjoints
			     (write-rdfxml disjoints ,path)))
	    )
	 ))
  (truename path))

(defun defined-classes (&optional (kb (load-kb-jena :obi)))
  (sparql '(:select (?class) (:distinct t)
	    (?class !owl:equivalentClass ?other)
	    (:optional (?class !rdfs:label ?classname))
	    (:optional (?other !owl:unionOf ?union))
	    (:filter (and (isblank ?other) (not (bound ?union)))))
	  :kb kb
	  :use-reasoner :none
	  :flatten t))