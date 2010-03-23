(defparameter *bro-seen* (make-hash-table :test 'equalp))

(defun analyze-biositemaps ()
  (map nil 'analyze-biositemap
       (split-at-regex  (get-url "http://biositemaps.ncbcs.org/biositemap.registry" :force-refetch t) "(?s)\\n")))

(defun analyze-biositemap (map)
  (let ((in-model (#"createDefaultModel" 'modelfactory)))
    (#"read" in-model
	     (new 'bufferedinputstream
		  (#"getInputStream" (#"openConnection" (new 'java.net.url map))))
	     map)
    (flet ((check (uri)
	     (when (and uri 
			(#"matches" uri "http://bioontology.org/ontologies/BiomedicalResourceOntology.owl.*"))
	       (incf (gethash uri *bro-seen* 0) 1))))
      (loop with iterator = (#"listStatements" in-model)
	 while (#"hasNext" iterator)
	 for statement = (#"next" iterator)
	 for subject = (#"getSubject" statement)
	 for object = (#"getObject" statement)
	 for predicate = (#"getPredicate" statement)
	 do
	 (when (and (#"isResource" subject) (not (#"isAnon" subject)))
	   (check (#"getURI" subject)))
	 (when (and (#"isResource" object) (not (#"isAnon" object)) (not (#"isLiteral" object)))
	   (check (#"getURI" object)))))))
      
(defun report-bro-usage ()
  (analyze-biositemaps)
  (loop for (what howmany) in
       (sort
	(loop for uri being the hash-keys of *bro-seen*
	   using (hash-value count)
	   collect (list (#"replaceFirst" uri ".*?#" "")  count))
	'> :key 'second)
       do (format t "~a: ~a~%" what howmany)))