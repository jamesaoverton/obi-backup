(defun write-inferred-superclasses (&optional (kb (load-kb-jena "obi:newids;obid.owl"))
				    (path "obi:newids;superclasses.owl"))
  (with-ontology inferred () 
      ((loop for class in (descendants !owl:Thing kb)
	  append
	  (loop for super in (parents class kb)
	     collect (class class :partial super))))
    (write-rdfxml inferred path)))
				       
