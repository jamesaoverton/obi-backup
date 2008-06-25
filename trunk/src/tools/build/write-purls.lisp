(defun write-purls (kb kbprev &optional (dest "obi:build;list-purls.xml"))
  (let((kb-purls
	(sparql
	 '(:select (?thing) (:distinct t)
	   (:union
	    ((?thing ?p ?o))
	    ((?s ?thing ?o))
	    ((?s ?p ?thing)))
	   (:filter (and (isuri ?thing) (regex (str ?thing) "OBI_\\d+")))
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
		(:filter (and (isuri ?thing) (regex (str ?thing) "OBI_\\d+")))
		)
	      :kb kbprev :use-reasoner :none :flatten t))))
    (flet ((doit (out)

	     (format out "<recs>~%")
	     (loop for new in (set-difference kb-purls kbprev-purls)
		for purl = (#"replaceFirst" (uri-full new) ".*/obo/" "/obo/")
		for id = (#"replaceFirst" purl ".*/" "")
		do (format out "<rec><purl>~a</purl><url>http://sw.neurocommons.org/obiterm/~a</url><id>CMUNGALL</id><id>MELANIE</id><id>ALANRUTTENBERG</id><type>User_Batch_Add</type></rec>~%" purl id ))
	     (format out "</recs>~%")
	     ))
      (if (or (eq dest t) (streamp dest))
	  (doit dest)
	  (with-open-file (out dest
			       :direction :output
			       :if-exists :supersede)
	    (doit out))
	  )
      (when (set-difference kbprev-purls kb-purls)
	(format t "Hmm, we seem to have lost some ids (deprecation lossage?): ~%~{~a~%~}"
		(set-difference kbprev-purls kb-purls)))    
      )))



;; e.g. (create-dated-purls "2007-06-27" "alanruttenberg" "alanspassword")
;1. /obo/2008-06-27/obi.owl http://obi.svn.sourceforge.net/svnroot/obi/tags/releases/2008-06-27/merged/OBI.owl
;2. /obo/2008-06-27/obi/branches/ http://obi.svn.sourceforge.net/svnroot/obi/tags/releases/2008-06-27/branches/
(defun create-dated-purls (datestring user password)
  (create-new-purl (format nil "/obo/~a/obi.owl" datestring)
		   (format nil "http://obi.svn.sourceforge.net/svnroot/obi/tags/releases/~a/merged/OBI.owl" datestring) user password '("obi"))
  (create-new-purl (format nil "/obo/~a/obi/branches/" datestring)
		   (format nil "http://obi.svn.sourceforge.net/svnroot/obi/tags/releases/~a/branches/" datestring) user password '("obi") t))

;; e.g. (update-current-purls "2007-06-27" "alanruttenberg" "alanspassword")
;1. /obo/obi.owl http://obi.svn.sourceforge.net/svnroot/obi/tags/releases/2008-06-27/merged/OBI.owl
;2. /obo/obi/protege/obi.owl http://obi.svn.sourceforge.net/svnroot/obi/tags/releases/2008-06-27/merged/protege/OBI-ProtegeFriendly.owl
(defun update-current-purls (datestring user password)
  (macrolet ((create-new-purl (&rest args)
	       `(print (list 'create-new-purl ,@args))))
    (update-purl (format nil "/obo/obi.owl" datestring)
		 (format nil "http://obi.svn.sourceforge.net/svnroot/obi/tags/releases/~a/merged/OBI.owl" datestring) user password '("obi") (format nil "release of ~a" datestring))
    (update-purl (format nil "/obo/obi/protege/obi.owl" datestring)
		     (format nil "http://obi.svn.sourceforge.net/svnroot/obi/tags/releases/~a/merged/protege/OBI-ProtegeFriendly.owl" datestring) user password '("obi") (format nil "release of ~a" datestring))))