;;;; -*- Mode: LISP -*-
;;;;

(in-package :asdf)

(setf (logical-pathname-translations "obi")
      `(("branches;**;*.*" "obi:src;ontology;branches;**;*.*")
	("build;**;*.*" "obi:build;**;*.*")
	("lisp;**;*.*" "obi:src;tools;build;**;*.*")
	("**;*.*" ,(make-pathname :directory (append (butlast (pathname-directory *load-pathname*) 3)
						     '(:wild-inferiors))
				  :name :wild
				  :type :wild))))

(defsystem :obi
    :name "OBI Tools"
    :author "Alan Ruttenberg"
    :version "1"
    :licence "BSD"
    :components
    ((:file "qc-queries")
     (:file "uri-report")
     (:file "add-disjoints")
     (:file "new-purls")
     )
    :depends-on (owl))

;;;; eof
