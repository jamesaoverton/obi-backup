(defvar *label2obi* nil)
  
(defun label2uri (kb)
  (loop with table = (make-hash-table :test 'equalp)
     for (uri label) in 
     (sparql `(:select (?thing ?label) ()
		       (?thing !rdfs:label ?label)
		       )
	     :kb kb :use-reasoner :none)
     do 
       (pushnew uri (gethash (trim-label-whitespace label) table) :test 'equalp)
       (pushnew uri (gethash (substitute #\space #\_ (trim-label-whitespace label)) table) :test 'equalp)
     finally (return table)))

(defun obi-apropos (what)
  (maphash (lambda(k v) (when (all-matches k what) (print k)))
	   (or *label2obi* (setq *label2obi* (label2uri)))))

(defun defined-and-unambiguous-parent (name)
  (let ((lookup (gethash name (or *label2obi* (setq *label2obi* (label2uri))))))
    (if lookup 
	(if (cdr lookup)
	    (progn
	      (format t "Ambiguous ~a: ~a ~%" name lookup)
	      nil)
	    (car lookup))
	(progn 
	  (format t "Couldn't find ~a~%" name)
	  nil))))

(defun do-import (path &optional obi-id)
  (let ((new (make-hash-table :test 'equalp)))
    ;; collect the lines split into fields
    (let ((lines 
	   (with-open-file (f path)
	     (loop for line = (read-line f nil :eof)
		until (eq line :eof)
		for fields = (split-at-char line #\tab)
		collect fields))))
      ;; assign ids to the new entries
      (loop for fields in lines
	 do
	 (when (equal (first fields) "i")
	   (unless (gethash (third fields) new )
	     (setf (gethash (third fields) new )
		   (make-uri (format nil "http://obi.sourceforge.net/ontology/OBI.owl#OBI_~6,'0D" obi-id))
		   (gethash (substitute #\space #\_ (third fields)) new )
		   (gethash (third fields) new )
		   obi-id (1+ obi-id)))))
      (flet ((obi-definition-editor (string)
	       (and (not (#"matches" string "^\\s*$"))
		    (annotation !obi:definition_editor (format nil "PERSON:~a" string))))
	     (obi-definition-source (string)
	       (and (not (#"matches" string "^\\s*$"))
		    (annotation !obi:definition_citation string)))
	     (obi-editor-note (string)
	       (and (not (#"matches" string "^\\s*$"))
		    (annotation !obi:editor_note string)))
	     (obi-example (string)
	       (and (not (#"matches" string "^\\s*$"))
		    (annotation !obi:example_of_usage string)))
	     (obi-definition (string)
	       (and (not (#"matches" string "^\\s*$"))
		    (annotation !obi:definition string))))
	(loop for fields in lines
	   append
	     ;; only if "i" = import
	   (when (equal (first fields) "i")
	     (let ((found (or (gethash (second fields) new)
			      (defined-and-unambiguous-parent (second fields)))))
	       (when found 
		 (when (gethash (third fields) *label2obi*)
		   (format t "Redefining ~a~%" (third fields)))
		 (list (class (gethash (third fields) new)
			 :partial  (label (third fields))
			 (obi-definition (fourth fields))
			 (obi-example (fifth fields))
			 (obi-editor-note (format nil "~a~a" (sixth fields)
						  (if (nth 11 fields) 
						      (format nil "~%---~%~a~%"
							      (nth 11 fields))
						      "")))
			 (obi-definition-editor
			  (cond ((eighth fields) (eighth fields))
				((equal (seventh fields) "KPC")
				 "Kevin Clancy")
				((equal (seventh fields) "IEDB")
				 "Bjoern Peters")))
			 found
			 )))
	       )))))))

;(define-ontology sheet () 
;  (do-import "/Users/alanr/Desktop/obi-import.txt" 600017))


