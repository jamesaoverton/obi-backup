(defun write-inferred-superclasses (&optional (kb (load-kb-jena "obi:newids;obid.owl"))
				    (path "obi:newids;superclasses.owl"))
  (with-ontology inferred (:base (format nil "file:/~a.~a"
					 (pathname-name (translate-logical-pathname path))
					 (pathname-type (translate-logical-pathname path)))) 
      ((loop for class in (descendants !owl:Thing kb)
	  append
	  (loop for super in (parents class kb)
	     collect (class class :partial super))))
    (check inferred)
    (write-rdfxml inferred path)))
				       
