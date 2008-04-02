(defun new-purls (kb kbprev)
  (let ((kb-purls
	 (sparql
	  '(:select (?thing) (:distinct t)
	    (:union
	     ((?thing ?p ?o))
	     ((?s ?thing ?o))
	     ((?s ?p ?thing)))
	    (:filter (regex (str ?thing) "OBI_\\d+"))
	    )
	  :kb kb :use-reasoner :none :flatten t))
	(kbprev-purls
	 (and kbprev
	      (sparql
	       '(:select (?thing) (:distinct t)
		 (:union
		  ((?thing ?p ?o))
		  ((?s ?thing ?o))
		  ((?s ?p ?thing)))
		 (:filter (regex (str ?thing) "OBI_\\d+"))
		 )
	       :kb kbprev :use-reasoner :none :flatten t))))
;    (print-db (length kb-purls) (car kb-purls) (length kbprev-purls) (car kbprev-purls))
    (format t "<recs>~%")
    (loop for new in (set-difference kb-purls kbprev-purls)
       for purl = (#"replaceFirst" (uri-full new) ".*/obo/" "/obo/")
       for id = (#"replaceFirst" purl ".*/" "")
       do (format t "<rec><purl>~a</purl><url>http://sw.neurocommons.org/obiterm/~a</url><id>CMUNGALL</id><type>User_Batch_Add</type></rec>~%" purl id ))
    (format t "</recs>~%")))
