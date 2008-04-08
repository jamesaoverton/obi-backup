(defun curation-status-report (kb)
  (sparql
   '(:select (?s ?status) (:distinct t)
     (?p !rdfs:label |\"curation status\"@en|)
      (:optional
       (?si ?p ?statusi)
       (?statusi !rdfs:label ?status)
       (?si !rdfs:label ?s))
     (:optional
      (?si ?p ?status)
      (:filter (isLiteral ?status))
      (?si !rdfs:label ?s)
      )
     )
   :kb kb :use-reasoner :jena :trace "Curation status" :values nil :trace-show-query nil))

(defun missing-curation (kb)
  (sparql
   '(:select (?si ?s ?type) (:distinct t)
     (?p !rdfs:label |\"curation status\"@en|)
     (?p :a !owl:AnnotationProperty)
     (:union
      ((?si !rdf:type !owl:AnnotationProperty))
      ((?si !rdf:type !owl:ObjectProperty))
      ((?si !rdf:type !owl:DatatypeProperty))
      ((?si !rdf:type !owl:Class))
     )
     (?si !rdfs:label ?s)
     (?si :a ?type)
     (:optional (?si ?p ?status))
     (:filter (and (regex (str ?si) "obi|OBI")
	       (not (equal ?type !rdf:Property))
	       (not (equal ?type !owl:Thing))
	       (not (equal ?type !rdfs:Class))
	       (not (bound ?status))))
     )
   :kb kb :use-reasoner :jena :trace "Terms missing curation status" :values nil :trace-show-query nil))

(defun extra-curation-status-instances (kb)
  (sparql
   '(:select (?ci ?label) (:distinct t)
     (?c !rdfs:label |\"curation status\"@en|)
     (?c :a !owl:Class)
     (?ci :a ?c)
     (:optional (?ci !rdfs:label ?label))
     (:filter (and 
	       (not (equal ?ci !<http://purl.obofoundry.org/obo/OBI_0000318>))
	       (not (equal ?ci !<http://purl.obofoundry.org/obo/OBI_0000319>))
	       (not (equal ?ci !<http://purl.obofoundry.org/obo/OBI_0000320>))
	       (not (equal ?ci !<http://purl.obofoundry.org/obo/OBI_0000323>))
	       (not (equal ?ci !<http://purl.obofoundry.org/obo/OBI_0000328>))
	       )))
   :kb kb :use-reasoner :jena :trace "Extra curation status instances" :values nil :trace-show-query nil))
  

;; (defun string-curation-status (kb)
;;   (sparql
;;    '(:select (?si ?s ?type) (:distinct t)
;;      (?p !rdfs:label |\"curation status\"@en|)
;;      (?p :a !owl:AnnotationProperty)
;;      (:union
;;       ((?si !rdf:type !owl:AnnotationProperty))
;;       ((?si !rdf:type !owl:ObjectProperty))
;;       ((?si !rdf:type !owl:DatatypeProperty))
;;       ((?si !rdf:type !owl:Class))
;;      )
;;      (?si !rdfs:label ?s)
;;      (?si :a ?type)
;;      (:optional (?si ?p ?status))
;;      (:filter (and (regex (str ?si) "obi|OBI")
;; 	       (not (equal ?type !rdf:Property))
;; 	       (not (equal ?type !owl:Thing))
;; 	       (not (equal ?type !rdfs:Class))
;; 	       (not (bound ?status))
;; 	       (not (isuri ?status))))
;;      )
;;    :kb kb :use-reasoner :none :trace "Terms with strings as curation status" :values nil :trace-show-query nil))

(defun untranslated-uris (kb)
  (sparql
   '(:select (?si ?s) (:distinct t)
     (?si !rdfs:label ?s)
     (:union
      ((?si !rdf:type !owl:AnnotationProperty))
      ((?si !rdf:type !owl:ObjectProperty))
      ((?si !rdf:type !owl:DatatypeProperty))
      ((?si !rdf:type !owl:Class))
     )
     (:filter (and (regex (str ?si) "obi|OBI") (not (regex (str ?si) "http://purl.obofoundry.org") ))
     ))
   :kb kb :use-reasoner :jena :trace "old obi ids" :values nil :trace-show-query nil)
  (sparql
   '(:select (?si ?s) (:distinct t)
     (?si !rdfs:label ?s)
     (:union
      ((?si !rdf:type !owl:AnnotationProperty))
      ((?si !rdf:type !owl:ObjectProperty))
      ((?si !rdf:type !owl:DatatypeProperty))
      ((?si !rdf:type !owl:Class))
     )
     (:filter (regex (str ?si) "http://www.geneontology.org/formats/oboInOwl#")))
   :kb kb :use-reasoner :jena :trace "geneontology ids" :values nil :trace-show-query nil)
  (sparql
   '(:select (?si ?s) (:distinct t)
     (?si !rdfs:label ?s)
     (:union
      ((?si !rdf:type !owl:AnnotationProperty))
      ((?si !rdf:type !owl:ObjectProperty))
      ((?si !rdf:type !owl:DatatypeProperty))
      ((?si !rdf:type !owl:Class))
     )
     (:filter (regex (str ?si) "Class_\\d+")))
   :kb kb :use-reasoner :jena :trace "ids that look like Class_12" :values nil :trace-show-query nil)
  (sparql
   '(:select (?si ?s) (:distinct t)
     (?si !rdfs:label ?s)
     (:union
      ((?si !rdf:type !owl:AnnotationProperty))
      ((?si !rdf:type !owl:ObjectProperty))
      ((?si !rdf:type !owl:DatatypeProperty))
      ((?si !rdf:type !owl:Class))
      )
     (:filter (and (regex (str ?si) "http://purl.obofoundry.org")
	       (not (regex (str ?si) "http://purl.obofoundry.org/obo/OBI_\\d{7}") )))
      )
   :kb kb :use-reasoner :jena :trace "uris without ids assigned yet" :values nil :trace-show-query nil)
  )

(defun next-unused-id (kb &optional (howmany 1))
  (let ((already
	 (mapcar (lambda(uri)
		   (parse-integer
		    (subseq (uri-full uri)
			    (+ 4 (search "OBI_" (uri-full uri))))))
		 (sparql
		  '(:select (?si) (:distinct t)
		    (?si !rdf:type ?type)
		    (:filter (regex (str ?si) "OBI_\\d+")))
		  :kb kb :use-reasoner :jena :flatten t))))
    (loop for candidate from 1 
       with count = 1
       when (not (member candidate already))
       collect candidate into nexts and do (incf count)
       do
	 (when (> count howmany)
	   (return-from next-unused-id nexts)))))

(defun missing-label (kb)
  (sparql
   '(:select (?si) (:distinct t)
     (:union
      ((?si !rdf:type !owl:AnnotationProperty))
      ((?si !rdf:type !owl:ObjectProperty))
      ((?si !rdf:type !owl:DatatypeProperty))
      ((?si !rdf:type !owl:Class))
      )
     (:optional (?si !rdfs:label ?label))
     (?si :a ?type)
     (:filter (and (regex (str ?si) "obi|OBI")
	       (not (equal ?type !rdf:Property))
	       (not (equal ?type !owl:Thing))
	       (not (equal ?type !rdfs:Class))
	       (not (bound ?label))))
     )
   :kb kb :use-reasoner :jena :trace "Missing labels" :values nil :trace-show-query nil))

