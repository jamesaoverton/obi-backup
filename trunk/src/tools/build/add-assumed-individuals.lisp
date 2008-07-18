;; see http://groups.google.com/group/obi-owl/msg/e64b981a835405eb
;; 
(defun write-assumed-individuals (&optional (kb (load-kb-jena "obi:newids;obid.owl"))
				  (path "obi:newids;assumed-individuals.owl"))
  ;; add instances of classes with no descendants
  (check kb)
  (with-ontology assumed (:base (format nil "http://purl.obofoundry.org/obo/obi/~a.~a"
					(pathname-name (translate-logical-pathname path))
					(pathname-type (translate-logical-pathname path)))) 
      ((loop for class in (descendants !bfo:Entity kb)
	  when (null (descendants class kb))
	  collect (individual (type class))))
    ;; rewrite the rdfxml to get rid of the classes (redundant) and undo the 
    ;; abstract syntax anonymous indivual bug and make then really anonymous
    (let ((rdfxml (rdfxml assumed)))
      (setq rdfxml (#"replaceAll"  rdfxml "(?s)\\s*<owl:Class rdf:about=\".*?\"/>\\s*\\n" ""))
      (setq rdfxml (#"replaceAll"  rdfxml "(?s)rdf:about=\"urn:blank:" "rdf:nodeID=\"b"))
      (with-open-file (f path :if-exists :supersede :if-does-not-exist :create :direction :output)
	(write-string rdfxml f)))
    ;; now check that the ontology + assumed individuals is consistent 
    ;; removed, as it triggers something nasty when run in the server
    '(with-ontology +assumed ()
	((owl-imports (kb-loaded-from kb))
	 (owl-imports (format nil "file://~a" (namestring (truename path)))))
      (unless (check +assumed)
	(format t "Ontology is inconsistent when assumed individuals are added")))
    t
    ))
				       
