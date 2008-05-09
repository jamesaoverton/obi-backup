;;;; -*- Mode: LISP -*-
;;;;

(in-package :asdf)

(setf (logical-pathname-translations "obi")
      `(("branches;*.*" ,(make-pathname :directory
						    (append (butlast (pathname-directory *load-pathname*) 3)
							    '("src" "ontology" "branches"))
						    :name :wild
						    :type :wild))
	("build;*.*" ,(make-pathname :directory (append (butlast (pathname-directory *load-pathname*) 3)
							'("build"))
				     :name :wild
				     :type :wild))
	("lisp;*.*" ,(make-pathname :directory (append (butlast (pathname-directory *load-pathname*) 3)
						       '("src" "tools" "build"))
				    :name :wild
				    :type :wild))
	))

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
