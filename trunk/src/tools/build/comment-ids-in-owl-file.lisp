(defun comment-ids-in-owl-file (in-path out-path &optional (kb (load-kb-jena :obi)))
  (let ((labels (rdfs-labels kb)))
    (with-open-file (in in-path)
      (with-open-file (out out-path :direction :output :if-does-not-exist :create :if-exists :supersede)
	(loop for line = (read-line in nil :eof)
	     until (eq line :eof)
	     for prop-replaced = (replace-all line  "<(OBI_\\d+)"
					      (lambda(id)
						(format nil "<!-- ~a --><~a" 
				      
							(gethash
							 (make-uri (format nil "http://purl.obofoundry.org/obo/~a" id)
								   ) labels)
							id)) 1)
	   for entity-replaced = (replace-all prop-replaced  "(rdf:(about|resource)=\"http://purl.obofoundry.org/obo/(OBI_\\d+)\"/{0,1}>)"
					    (lambda(whole id)
					      (format nil "~a<!-- ~a -->"  
				      
						      whole
						      (gethash
						       (make-uri (format nil "http://purl.obofoundry.org/obo/~a" id)
								 ) labels)))
					    1 3)
	     
	     do
	     (write-string entity-replaced out)
	     (terpri out))))))