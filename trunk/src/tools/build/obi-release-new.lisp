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
  (create-combined-obi dest obi :include-all-imports last))

(defun create-combined-obi (dest obi type &key version pretty last)
  (let* ((kb (load-kb-jena obi))
	 (imported (remove "http://" (imported kb) :test 'search))
	 (out-model (create-empty-obi-model))
	 (curation-note-uri "http://purl.obolibrary.org/obo/IAO_0000232")
	 (necessary-subclass-assertions (and last (necessary-subclass-assertions (load-kb-jena last))))
	 (imported-ontology-names (remove "http://purl.obolibrary.org/obo/obi.owl" (ontology-names kb) :test 'equal)))
    (if last
	(format t "~%Second pass~%")
	(format t "~%First pass~%"))
    (loop for file in (if (or (not last) (eq type :include-all-imports))
			  imported
			  (remove-if-not (lambda(e) (search "/src/ontology/branches/" e)) imported))
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
	  unless (or (member predicate `("http://www.w3.org/2002/07/owl#imports" "http://www.w3.org/2000/01/rdf-schema#isDefinedBy"
					 ,curation-note-uri)
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
    (when (and last (eq type :release))
      (loop for source in (list !<http://purl.obolibrary.org/obo/iao/iao.owl>
				!<http://www.obofoundry.org/ro/ro.owl>
				!<http://www.ifomis.org/bfo/1.1>
				!<http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl>
				!<http://purl.org/obo/owl/ro_bfo_bridge/1.1>)
	   do (add-jena-triple out-model "http://purl.obolibrary.org/obo/obi.owl" !owl:imports source)))
    (add-doap out-model version pretty)
;    (add-preflabels out-model)
;    (add-version-stuff out-model)
    (if last
	(write-jena-model out-model (namestring (translate-logical-pathname dest)))
	(progn
	  (write-jena-model out-model (namestring (translate-logical-pathname dest)))
	  (create-combined-obi dest obi type :last dest :pretty pretty :version version)
	  ))))

(defun add-doap (model version pretty-name &optional (doap "obi:branches;doap.owl"))
  (with-open-file (newdoap "/tmp/doap.owl" :direction :output :if-exists :supersede :if-does-not-exist :create)
    (with-open-file (f doap)
      (loop for line = (read-line f nil :eof)
	 until (eq line :eof)
	 do (write-line (#"replaceFirst" (#"replaceFirst"  line "__VERSION_GOES_HERE__" version) "__PRETTY_NAME_GOES_HERE__" pretty-name)
			newdoap))))
  (let ((in-model (create-empty-obi-model)))
    (#"read" in-model
	     (new 'bufferedinputstream
		  (#"getInputStream" (#"openConnection" (new 'java.net.url "file:///tmp/doap.owl" ))))
	     "http://purl.obolibrary.org/obo/obi.owl")
    (loop with iterator = (#"listStatements" in-model)
       while (#"hasNext" iterator)
       for statement = (#"next" iterator)
       do (#"add" model statement))))

(defun add-preflabels ()

;; Do you think you will be able to:
;; - save the editor notes to a file and remove from released file (actually that would be save the curator notes to a file and keep editor note)
;; - check matching between labels and preferred terms
;;        - if they match exit
;;        - if they don't
;;                - copy preferred term to alternative term property
;;                - overwrite preferred term with rdfs:label
)

