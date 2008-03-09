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
   :kb kb :use-reasoner :jena :trace t :values nil))

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
   :kb kb :use-reasoner :jena :trace t :values nil))

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
   :kb kb :use-reasoner :jena :trace "old obi ids" :values nil)
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
   :kb kb :use-reasoner :jena :trace "geneontology ids" :values nil)
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
   :kb kb :use-reasoner :jena :trace "ids that look like Class_12" :values nil)
  )

(defun next-unused-id (kb &optional (howmany 1))
  (let ((already
	 (mapcar (lambda(uri)
		   (parse-integer
		    (subseq (uri-full uri)
			    (+ 4 (search "OBI_" (uri-full uri))))))
		 (sparql
		  '(:select (?si) (:distinct t)
		    (:union
		     ((?si !rdf:type !owl:AnnotationProperty))
		     ((?si !rdf:type !owl:ObjectProperty))
		     ((?si !rdf:type !owl:DatatypeProperty))
		     ((?si !rdf:type !owl:Class))
		     )
		    (:filter (regex (str ?si) "OBI_\\d+")))
		  :kb kb :use-reasoner :jena :flatten t))))
    (loop for candidate from 1 
       with count = 1
       when (not (member candidate already))
       collect candidate into nexts and do (incf count)
       do
	 (when (> count howmany)
	   (return-from next-unused-id nexts)))))
