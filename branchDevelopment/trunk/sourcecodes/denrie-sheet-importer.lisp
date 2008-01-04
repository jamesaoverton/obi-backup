;; Modified from sheet-importer. Used for denrie/role branch.


;Denrie: parent	term	definition_source	definition	definition_source	definition_editor	curation_status	example_of_usage	editor_note	curation_status	alternative_term	alternative_term_tag	alternative_term_source

;Role: Parent	Term	Bearers	Process that realizes the role/function	Relation the bearer has in the processes which are the realizations of the role/function.	Definition-draft3	External source	curation_status	example	alternative_term	alternative_term_tag	editor_note	definition_editor


(defvar *label2obi* nil)
  
(defun label2uri (&optional (kb *default-kb*))
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

(defun defined-and-unambiguous-parent (name new)
  (let ((lookup (gethash name (or *label2obi* (setq *label2obi* (label2uri))))))
    (if lookup 
	(if (cdr lookup)
	    (progn
	      (format t "Ambiguous ~a: ~a ~%" name lookup)
	      nil)
	    (car lookup))
	(progn 
	  (format t "Couldn't find ~a~%" name)
;	  (maphash (lambda(k v) (print-db k v)) new)
	  (break)

	  nil))))

(defun read-headers (stream)
  (split-at-char (read-line stream nil :eof) #\tab))
  
(defun make-headers (string &optional hide)
  (let ((them (split-at-regex string "\\s*\\t\\s*")))
    (flet ((usearch (a b) (search a b :test 'char-equal)))
      (loop for h in hide do (setf (nth h them) ""))
      (let ((parent (position  "parent" them :test #'usearch ))
	    (editor (position "definition_editor" them :test #'usearch))
	    (status (position "status" them :test #'usearch))
	    (citation (or (position "definition_source" them :test #'usearch)
			  (position "definition_citation" them :test #'usearch)
			  (position "external source" them :test #'usearch)))
	    (example (position "example" them :test #'usearch))
	    (notes (position "note" them :test #'usearch))
	    (definition (position "definition" them :test #'equalp))
	    (term (position "term" them :test #'usearch)))
	(list :parent parent  :editor editor :status status :citation citation :example example :notes notes :definition definition
	      :term term)))))
  
(defun do-import (path &key (hide nil) (should-import (lambda(fields) t)))
  (let ((new (make-hash-table :test 'equalp))
	headers)
    (flet ((field (key list)
	     (nth (getf headers key) list))
	   )
      ;; collect the lines split into fields
      (let ((lines 
	     (with-open-file (f path)
	       (setq headers (make-headers (read-line f nil :eof) hide)) ; (split-at-char (read-line stream nil :eof) #\tab))
	       (loop for line = (read-line f nil :eof)
		  until (eq line :eof)
		  for fields = (split-at-char line #\tab)
		  collect fields))))
	;; assign ids to the new entries
	(loop for fields in lines
	   do
	   (when (funcall should-import fields)
	     (let ((term (field :term fields)))
	       (unless (gethash term new )
		 (setf (gethash term new)
		       (make-uri (format nil "http://obi.sourceforge.net/ontology/OBI.owl#~a" (substitute #\_ #\space term)))
		       (gethash (substitute #\space #\_ term) new )
		       (gethash term new )
		       )))))
	(flet ((obi-definition-editor (string)
		 (and string (not (#"matches" string "^\\s*$"))
		      (loop for editor in (split-at-regex  string "\\s*,\\s*")
			 collect
			 (annotation !obi:definition_editor (format nil "PERSON:~a" editor)))))
	       (obi-definition-source (string)
		 (and string (not (#"matches" string "^\\s*$"))
		      (annotation !obi:definition_citation string)))
	       (obi-editor-note (string)
		 (and string (not (#"matches" string "^\\s*$"))
		      (annotation !obi:editor_note string)))
	       (obi-example (string)
		 (and string ( not (#"matches" string "^\\s*$"))
		      (annotation !obi:example_of_usage string)))
	       (obi-definition (string)
		 (and string (not (#"matches" string "^\\s*$"))
		      (annotation !obi:definition string))))
	  (loop for fields in lines
	     for parent = (field :parent fields)
	     for term = (field :term fields)
	     collect
	     ;; only if "i" = import
	     (when (funcall should-import fields)
	       (let* ((parent-class (or (gethash parent new)
					(defined-and-unambiguous-parent parent new))))
		 (when (gethash term *label2obi*)
		   (format t "Redefining ~a~%" term))
		 (apply 'class (gethash term new)
		    :partial  parent-class
		    (label term)
		    (obi-definition (field :definition fields))
		    (obi-example (field :example fields))
		    (obi-editor-note (field :notes fields))
		    (obi-definition-editor (field :editor fields))))		   
	       )))))))


(defvar *obi* (load-kb-jena :obi))

(defun denrie-branch ()
  (define-ontology denrie (:base "http://obi.sourceforge.net/ontology/OBI/DigitalEntityPlus.owl") 
    (let ((*default-kb* *obi*))
      (do-import "~/repos/obi/branchDevelopment/trunk/spreadsheets-imported/denrie-2007-12-20.txt" :hide '(4 6)))
    ))

(defun role-branch ()
  (define-ontology role () 
    (let ((*default-kb* *obi*))
      (do-import "~/repos/obi/branchDevelopment/trunk/spreadsheets-imported/role-branch-2007-11-28.txt" :should-import
		 (lambda(fields) 
		   (not (equal (car fields) "")))))
    ))


