(defun format-time (&optional (time-value (get-universal-time)))
  (multiple-value-bind (second minute hour day month year dow dst zone)
      (decode-universal-time time-value)
    (declare (ignore dow dst))
    (format nil "~2,'0D:~2,'0D:~4,'0D ~2,'0D:~2,'0D"
	    day month year  hour minute
	    )))

(defun localname (uri)
  (let ((full (uri-full uri)))
    (#"replaceFirst" full ".*/(.*)" "$1")))

(defun localname-namespaced (uri)
  (let* ((full (uri-full uri))
	(local  (#"replaceFirst" full ".*/(.*)" "$1")))
    (if (#"matches" (uri-full uri) "http://purl.obofoundry.org/obo/OBI_\\d+")
	(concatenate 'string "OBI:" local)
	(if (#"matches" local "^ro\\.owl#.*")
	    (concatenate 'string "OBO_REL:" (#"replaceFirst" local ".*#(.*)" "$1"))
	    (#"replaceFirst" local "#" ":")))))
	
(defun generate-obo (&optional (kb (load-kb-jena "obi:obil.owl"))
		     (path "obi:build;obi.obo"))
  (with-open-file (f  path :direction :output :if-does-not-exist :create :if-exists :supersede)
    (let ((*current-labels* (rdfs-labels kb))
          (*current-comments* (rdfs-comments kb)))
      (macrolet ((rdfs-label (e) `(gethash ,e *current-labels*))
		 (rdfs-comment (e) `(gethash ,e *current-comments*)))
	(format f "format-version: 1.2
date: ~a
saved-by: https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/generate-obo.lisp
auto-generated-by: https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/generate-obo.lisp
default-namespace: OBI
remark: This file is an subset of OBI adequate for indexing using the OLS service. It does not include all logical assertions present in the OWL file, which can be obtained at http://purl.obofoundry.org/obo/obi.owl
idspace: OBO_REL http://www.obofoundry.org/ro/ro.owl# \"OBO Relation ontology official home on OBO Foundry\"
idspace: snap http://www.ifomis.org/bfo/1.1/snap# \"BFO SNAP ontology (continuants)\"
idspace: span http://www.ifomis.org/bfo/1.1/span# \"BFO SPAN ontology (occurrents)\"
idspace: OBI http://purl.obofoundry.org/obo/OBI_ \"Ontology for Biomedical Investigations\"
idspace: CHEBI http://purl.org/obo/owl/CHEBI# \"Chemical Entities of Biological Interest\"
idspace: CL http://purl.org/obo/owl/CL# \"Cell Ontologhy\"
idspace: NCBITaxon http://purl.org/obo/owl/NCBITaxon# \"NCBI Taxonomy\"

" (format-time))
	(loop for class in (descendants !owl:Thing kb)
	   for obsolete = (member !<http://www.geneontology.org/formats/oboInOwl#ObsoleteClass> (ancestors class kb))
	   when (#"matches" (uri-full class) ".*(OBI|CHEBI|CL|NCBITaxon)_\\d+")
	   do 
	   (format f "[Typedef]~%id: ~a~%name: ~a~%"
		   (#"replaceFirst" (uri-full class) ".*(OBI|CHEBI|CL|NCBITaxon)(_\\d+)" "$1:$1$2")
		   (rdfs-label class))
	   (let ((comment (rdfs-comment class)))
	     (unless (or (null comment) (equal comment ""))
	       (format f "def: ~a~%" (#"replaceAll" comment "\\n" " " ))))
	   (if obsolete
	       (format f "is_obsolete: true~%")
	       (loop for super in (parents class kb)
		  do (format f "is_a: ~a ! ~a~%"  (localname-namespaced super) (rdfs-label super))))
	   (terpri f))
	(loop for proptype in (list !owl:AnnotationProperty !owl:DatatypeProperty !owl:ObjectProperty )
	   do
	   (loop for prop in (sparql `(:select (?prop) (:distinct t) (?prop !rdf:type ,proptype))  :use-reasoner :jena :kb kb :flatten t)
	      when (#"matches" (uri-full prop) ".*OBI_\\d+")
	      do
	      (format f "[Typedef]~%id: ~a~%name: ~a~%"
		      (localname-namespaced prop)
		      (rdfs-label prop))
	      (let ((comment (rdfs-comment prop)))
		(unless (or (null comment) (equal comment ""))
		  (format f "def: ~a~%" (#"replaceAll" comment "\\n" " " ))))
	      (format f "is_a: OBO_REL:relationship~%")
	      (let ((inverses
		     (mapcar 'aterm-to-sexp
			     (set-to-list
			      (#"getInverses" (kb-kb kb) (get-entity prop kb)) ))))
		(loop for inverse in inverses do
		     (format f "inverse_of: OBI:~a ! ~a~%" (localname inverse) (rdfs-label inverse))))
	      (let ((supers
		     (mapcar 'aterm-to-sexp
			     (apply 'append (mapcar 'set-to-list 
						    (set-to-list
						     (#"getSuperProperties" (kb-kb kb) (get-entity prop kb))))))))
		(loop for super in supers 
		     unless (eq super !ro:relationship)
		     do (format f "is_a: ~a ! ~a~%" (localname-namespaced super) (or (rdfs-label super) (localname super)))))
	      (terpri f)))))))
		      
