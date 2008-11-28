(defun format-time (&optional (time-value (get-universal-time)))
  (multiple-value-bind (second minute hour day month year dow dst zone)
      (decode-universal-time time-value)
    (declare (ignore dow dst))
    (format nil "~2,'0D:~2,'0D:~4,'0D ~2,'0D:~2,'0D"
	    day month year  hour minute
	    )))

(defun localname (uri)
  (let ((full (uri-full uri)))
    (#"replaceFirst" full ".*[/#](.*)" "$1")))

(defun localname-namespaced (uri)
  (let* ((full (uri-full uri))
	(local  (#"replaceFirst" full ".*/(.*)" "$1")))
    (if (is-obi-uri uri)
	local
	(if (#"matches" local "^ro\\.owl#.*")
	    (concatenate 'string "OBO_REL:" (#"replaceFirst" local ".*#(.*)" "$1"))
	    (if (#"matches" local "^MGEDOntology\\.owl.*")
		(concatenate 'string "MGED:" (#"replaceFirst" local ".*#(.*)" "$1"))
		(#"replaceFirst" local "#" ":"))))))
	
(defun generate-obo ( &key (kb (load-kb-jena "obi:branches;obil.owl"))
		     (classes-matching ".*([A-Za-z]+)_\\d+")
		     (properties-matching ".*OBI_\\d+")
		     (path "obi:branches;obi.obo"))
  (with-open-file (f  path :direction :output :if-does-not-exist :create :if-exists :supersede)
    (let ((*current-labels* (rdfs-labels kb))
          (*current-comments* (rdfs-comments kb)))
      (macrolet ((rdfs-label (e) `(gethash ,e *current-labels*))
		 (rdfs-comment (e) `(gethash ,e *current-comments*)))
	(format f "format-version: 1.2
date: ~a
saved-by: obi
auto-generated-by: https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/generate-obo.lisp
default-namespace: OBI
idspace: OBO_REL http://www.obofoundry.org/ro/ro.owl# \"OBO Relation ontology official home on OBO Foundry\"
idspace: snap http://www.ifomis.org/bfo/1.1/snap# \"BFO SNAP ontology (continuants)\"
idspace: span http://www.ifomis.org/bfo/1.1/span# \"BFO SPAN ontology (occurrents)\"
idspace: OBI http://purl.obofoundry.org/obo/OBI_ \"Ontology for Biomedical Investigations\"
idspace: CHEBI http://purl.org/obo/owl/CHEBI# \"Chemical Entities of Biological Interest\"
idspace: CL http://purl.org/obo/owl/CL# \"Cell Ontology\"
idspace: NCBITaxon http://purl.org/obo/owl/NCBITaxon# \"NCBI Taxonomy\"
remark: This file is a subset of OBI adequate for indexing using the OLS service. It does not include all logical assertions present in the OWL file, which can be obtained at http://purl.obofoundry.org/obo/obi.owl

" (format-time))
	(loop for class in (descendants !owl:Thing kb)
	   for obsolete = (member !obsolete-class (ancestors class kb))
	   when t;(#"matches" (uri-full class) classes-matching)
	   do 
	   (format f "[Term]~%id: ~a~%name: ~a~%"
		   ;(#"replaceFirst"  (#"replaceFirst" (uri-full class) ".*(OBI|CHEBI|CL|NCBITaxon)(_\\d+)" "$1:$1$2") "OBI:" "")
		   (localname-namespaced class)

		   (or (rdfs-label class) (localname class)))
	   (let ((comment (rdfs-comment class)))
	     (unless (or (null comment) (equal comment ""))
	       (format f "def:\"~a\" \[\]~%"  (#"replaceAll" (#"replaceAll" comment "\\n" " " )
			  "\\\\" "\\\\\\\\" ))))
	   (if obsolete
	       (format f "is_obsolete: true~%")
	       (loop for super in (parents class kb)
		  do (format f "is_a: ~a ! ~a~%"  (localname-namespaced super) (rdfs-label super))))
	   (terpri f))
	(loop for proptype in (list !owl:AnnotationProperty !owl:DatatypeProperty !owl:ObjectProperty )
	   do
	   (loop for prop in (sparql `(:select (?prop) (:distinct t) (?prop !rdf:type ,proptype))  :use-reasoner :jena :kb kb :flatten t)
	      when t;(#"matches" (uri-full prop) properties-matching)
	      do
	      (format f "[Typedef]~%id: ~a~%name: ~a~%"
		      (localname-namespaced prop)
		      (or (rdfs-label prop) (localname prop)))
	      (let ((comment (rdfs-comment prop)))
		(unless (or (null comment) (equal comment ""))
		  (if (#"matches" comment "(?s).*beta.*") (print comment))
		  (format f "def:\"~a\" \[\]~%" (#"replaceAll" (#"replaceAll" comment "\\n" " " )
			  "\\\\" "\\\\\\\\" ))))
	      (format f "is_a: OBO_REL:relationship~%")
	      (let ((inverses
		     (mapcar 'aterm-to-sexp
			     (set-to-list
			      (#"getInverses" (kb-kb kb) (get-entity prop kb)) ))))
		(loop for inverse in inverses do
		     (format f "inverse_of: ~a ! ~a~%" (localname-namespaced inverse) (rdfs-label inverse))))
	      (let ((supers
		     (mapcar 'aterm-to-sexp
			     (apply 'append (mapcar 'set-to-list 
						    (set-to-list
						     (#"getSuperProperties" (kb-kb kb) (get-entity prop kb))))))))
		(loop for super in supers 
		     unless (eq super !ro:relationship)
		     do (format f "is_a: ~a ! ~a~%" (localname-namespaced super) (or (rdfs-label super) (localname super)))))
	      (terpri f)))))))
		      
