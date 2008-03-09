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
   :kb kb :use-reasoner :jena :trace t :values nil))  

     


