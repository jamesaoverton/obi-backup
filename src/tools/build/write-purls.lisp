(defun write-purls (kb kbprev &optional (dest "obi:list-purls.xml"))
  (let((kb-purls
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
    
    (with-open-file (out dest
			 :direction :output
			 :if-exists :supersede)
      (format out "<recs>~%")
      (loop for new in (set-difference kb-purls kbprev-purls)
	 for purl = (#"replaceFirst" (uri-full new) ".*/obo/" "/obo/")
	 for id = (#"replaceFirst" purl ".*/" "")
	 do (format out "<rec><purl>~a</purl><url>http://sw.neurocommons.org/obiterm/~a</url><id>CMUNGALL</id><id>MELANIE</id><type>User_Batch_Add</type></rec>~%" purl id ))
      (format out "</recs>~%")
      )
    (when (set-difference kbprev-purls kb-purls)
      (format t "Hmm, we seem to have lost some ids (deprecation lossage?): ~%~{~a~%~}"
	  (set-difference kbprev-purls kb-purls)))    
    ))



