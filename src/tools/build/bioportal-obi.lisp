(defun necessary-subclass-assertions (kb)
  (let ((table (make-hash-table :test 'equalp)))
    (with-ontology subclass-only ()
	((loop for (s o) in
	      (sparql '(:select (?s ?o)()
			(?s !rdfs:subClassOf ?o)
			(:filter (and (not (isblank ?s)) (not (isblank ?o)))))
		      :kb kb :use-reasoner :none)
	    append (class s :partial o)))
      (#"classify" (kb-kb subclass-only))
      (loop for class in (descendants !owl:Thing subclass-only)
	   do
	   (loop for parent in (parents class subclass-only)
		do (setf (gethash (list (uri-full class) (uri-full parent)) table) t)))

      table)))

(defun ontology-names (kb)
  (mapcar 'uri-full
	  (sparql '(:select (?s)()
	    (?s !rdf:type !owl:Ontology))
	  :kb kb :use-reasoner :none :flatten t)))

(defun create-bioportal-obi (dest obi &optional last)
  (let* ((kb (load-kb-jena obi))
	 (imported (remove "http://" (imported kb) :test 'search))
	 (out-model (create-empty-obi-model))
	 (necessary-subclass-assertions (and last (necessary-subclass-assertions (load-kb-jena last))))
	 (imported-ontology-names (remove "http://purl.obolibrary.org/obo/obi.owl" (ontology-names kb) :test 'equal)))
    (loop for file in imported
       for in-model = (#"createDefaultModel" 'modelfactory)
       with dont = (list*
		    (mapcar 'uri-full (sparql '(:select (?term) ()
						(:union
						 ((?term !rdfs:label ?label)
							 (:filter (regex (str ?label) "^_.*")))
						 ;; COMMENT OUT IF YOU WANT TO INCLUDE OBSOLETE CLASSES
						 ((?term !rdfs:subClassOf !<http://www.geneontology.org/formats/oboInOwl#ObsoleteClass>))))
					      :kb kb :use-reasoner :none :flatten t)))
       do
       (format t "reading ~a~%" file)
       (#"read" in-model
		(new 'bufferedinputstream
		     (#"getInputStream" (#"openConnection" (new 'java.net.url file))))
		"http://purl.obolibrary.org/obo/obi.owl")
       (loop with iterator = (#"listStatements" in-model)
	  while (#"hasNext" iterator)
	  for statement = (#"next" iterator)
	  for subject = (#"getSubject" statement)
	  for object = (#"getObject" statement)
	  for predicate = (#"toString" (#"getURI" (#"getPredicate" statement)))
	  unless (or (member predicate '("http://www.w3.org/2002/07/owl#imports" "http://www.w3.org/2000/01/rdf-schema#isDefinedBy")
			     :test 'equal)
		     (and (equal predicate "http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
			  (equal (#"toString" (#"getURI" object)) "http://www.w3.org/2002/07/owl#Ontology"))
		     (and last
			  (equal predicate "http://www.w3.org/2000/01/rdf-schema#subClassOf")
			  (not (#"isAnon" subject))
			  (not (#"isAnon" object))
			  (not (gethash (list (#"toString" (#"getURI" subject)) (#"toString" (#"getURI" object)))
					necessary-subclass-assertions)))
		     (and (not (#"isAnon" subject) )
			  (or (member (#"toString" (#"getURI" subject)) dont :test 'equal)
			      (member (#"toString" (#"getURI" subject)) imported-ontology-names :test 'equal)))

		     (and (#"isResource" object)
			  (not (#"isAnon" object))
			  (member (#"toString" (#"getURI" object)) dont :test 'equal)))
	  do (#"add" out-model statement))
       (add-jena-triple out-model "http://purl.obolibrary.org/obo/obi.owl" !rdf:type !owl:Ontology))
    (if last
	(write-jena-model out-model (namestring (translate-logical-pathname dest)))
	(progn
	  (write-jena-model out-model (namestring (translate-logical-pathname dest)))
	  (create-bioportal-obi dest obi dest)
	  ))))
