;;;; -*- Mode: LISP -*-
;;;;

(in-package :asdf)

(setf (logical-pathname-translations "obi")
      `(("**;*.*" ,(make-pathname :directory (append (butlast (pathname-directory *load-pathname*))
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
     )
    :depends-on (owl))

;;;; eof
