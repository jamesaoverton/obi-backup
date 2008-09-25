(defun write-inferred-superclasses (&optional (kb (load-kb-jena "obi:newids;obidi.owl"))
				    (path "obi:newids;superclasses.owl"))
  (if (check kb)
      (with-ontology inferred (:base (format nil "http://purl.obofoundry.org/obo/obi/~a.~a"
					     (pathname-name (translate-logical-pathname path))
					     (pathname-type (translate-logical-pathname path)))) 
	  ((loop for class in (descendants !owl:Thing kb)
	      append
	      (loop for super in (parents class kb)
		 collect (class class :partial super))))
	(check inferred)
	(write-rdfxml inferred path))
      (error "KB isn't consistent, so inferred superclasses won't be correct")))
				       
