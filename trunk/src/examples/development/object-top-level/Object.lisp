(define-ontology object
    (:base "http://www.owl-ontologies.com/Ontology1186049502.owl" :about !<http://www.owl-ontologies.com/Ontology1186049502.owl>)
  (object-property !assembled_from (inverse-of !is_assemblage_of))
;  (object-property !is_assemblage_of (inverse-of !assembled_from)) redundant

  (object-property !formed_from);alan (inverse-of !forms))
;  (object-property !forms (inverse-of !formed_from))   redundant

  (object-property !has_constituent);alan (inverse-of !is_constituent_of))
;  (object-property !is_constituent_of (inverse-of !has_constituent))

  (object-property !has_grain);alanr (inverse-of !is_grain_of))
;  (object-property !is_grain_of (inverse-of !has_grain)) redundant

  (object-property !has_subportion);alan (inverse-of !is_subportion_of))
;  (object-property !is_subportion_of (inverse-of !has_subportion)) redundant



  (class !assemblage :complete (restriction !assembled_from (all-values-from !countable))); alan doesn't fix it

  (class !assemblage :partial !countable)
  (class !assemblage "An assemblage is a countable which is only composed from countable objects" :partial)

;  (class !collective :complete (restriction !is_constituent_of (all-values-from !collective)))
  (class !collective :complete (restriction !has_grain (all-values-from !countable)))
;  (class !collective :complete (restriction !has_grain (some-values-from !countable)))
  (class !collective :complete (restriction !has_constituent (all-values-from !collective)))
  (class !collective
    :partial
    !object_aggregate
    (restriction !has_subportion (all-values-from !collective))
;    (restriction !is_subportion_of (all-values-from !collective) ;alan
    )  
  (class !collective
    "citation (1a) ?Collectives? are made up of ?grains? all of which play the same role in the collective.

 (1b) ?Collectives? are not mathematical sets?their identity is not determined by their membership. (The issue of the identity of collectives is discussed in Section 4.4.1).

 (1c) Being a ?collective? (?collectivity?) is independent of the number of grains in the collective.

 (1d) There are emergent effects and characteristics of collectives as a whole not determinable from the individual characteristics of their grains."
    :partial
    (annotation !rdfs:comment "citation from PMID: 16515892"))

  (class !countable :partial !object)
  (class !countable
    "A countable is an object that when split in two the parts are not of the same class as the original object. It is possible that this means the same as object, although this will have to be confirmed with BFO."
    :partial)

  (class !formed_from_collective
    :complete
     (restriction !formed_from (all-values-from !collective)) (restriction !formed_from (cardinality 1)))
  (class !formed_from_collective :partial !countable)
  (class !formed_from_collective
    "A composed from portion is a countable object that all parts are from a portion. For example a glass testube; all parts are from the portion of glass."
    :partial)

  (class !object
    "A independent continuant that is spatially extended, maximally self-connected and self-contained (the parts of a substance are not separated from each other by spatial gaps) and possesses an internal unity. The identity of substantial objects is independent of that of other entities and can be maintained through time and through loss and gain of parts and qualities."
    :partial)

  (class !object_aggregate :partial)

  (annotation-property !rdfs:comment)
  (disjoint-classes !atom !molecule)
  (disjoint-classes !IPG_strip_7cm !molecule)
  (disjoint-classes !plastic_object !glass_object)
  (disjoint-classes !plastic !pure_water)
  (disjoint-classes !pure_water !salt_solution)
  (disjoint-classes !countable !collective)
  (disjoint-classes !NaCl !H2O)
  (disjoint-classes !formed_from_collective !assemblage)
  (disjoint-classes !object !object_aggregate)
  (disjoint-classes !glass !gel)
  (disjoint-classes !pure_water !glass)
  (disjoint-classes !plastic !gel)
  (disjoint-classes !atom !IPG_strip_7cm)
  (disjoint-classes !polyacrlymide !H2O)
  (disjoint-classes !salt_solution !gel)
  (disjoint-classes !plastic !glass)
  (disjoint-classes !NaCl !polyacrlymide)
  (disjoint-classes !pure_water !gel)
  (disjoint-classes !plastic !salt_solution)
;  (sub-class-of !owl:Thing (restriction !formed_from (min-cardinality 1)))
;  (sub-class-of !owl:Thing (restriction !has_grain (min-cardinality 1)))
;;   (class !Cy5 :partial !molecule)
;;   (class !GenePix_Professional_4200A :partial !assemblage)
;;   (class !H2O :partial !molecule)
;;   (class !IPG_strip_7cm
;;     :partial
;;     (restriction !assembled_from (some-values-from (restriction !formed_from (all-values-from !plastic))))
;;     !assemblage
;;     (restriction !assembled_from (some-values-from (restriction !formed_from (all-values-from !polyacrylamide_gel)))))
;;   (class !NaCl :partial !molecule)
;;   (class !RNA :partial !molecule)
;;   (class !amino_acid :partial !molecule)
;;   (class !gel :partial !collective)
;;   (class !glass :partial !collective)
;;   (class !glass_object :complete (restriction !formed_from (all-values-from !glass)))
;;  (class !glass_object :partial !formed_from_collective) surprising
;;   (class !growth_medium
;;     :partial
;;     (restriction !has_constituent (some-values-from !pure_water))
;;     (restriction !has_constituent (some-values-from (restriction !has_grain (all-values-from !amino_acid))))
;;     !collective)

;   (class !microarray :partial !assemblage)
;   (class !molecule :partial !assemblage)
;   (class !petri_dish :partial !plastic_object)
   (class !plastic :partial !collective)
   (class !plastic_object :complete (restriction !formed_from (all-values-from !plastic)))
;;   (class !plastic_object :partial !formed_from_collective)
;;   (class !polyacrlymide :partial !molecule)
;;   (class !polyacrylamide_gel
;;     :partial
;;     (restriction !has_constituent (some-values-from !pure_water))
;;     (restriction !has_constituent
;; 		 (some-values-from (intersection-of (restriction !has_grain (all-values-from !polyacrlymide)) !collective)))
;;     !gel)
;;   (class !pure_water :partial !collective (restriction !has_grain (all-values-from !H2O)))
;;   (class !salt_solution
;;     :complete
;;     (intersection-of (restriction !has_constituent (some-values-from !pure_water))
;; 		     (restriction !has_constituent (some-values-from (restriction !has_grain (all-values-from !NaCl))))))
;;   (class !salt_solution :partial !collective)
;;   (class !atom :partial !assemblage)
;;   (class !cell :partial !assemblage)
;;   (class !cell_culture
;;     :partial
;;     (restriction !assembled_from
;; 		 (some-values-from (restriction !formed_from
;; 						(all-values-from (restriction !has_grain (all-values-from !cell))))))
;;     (restriction !assembled_from (some-values-from !petri_dish))
;;     (restriction !assembled_from (some-values-from (restriction !formed_from (all-values-from !growth_medium))))
;;     !assemblage)

;  (class !organism :partial !assemblage)
;  (class !Mus_musculus :partial !organism)
;  (class !organ :partial);alan (restriction !is_assemblage_of (all-values-from !organism)) !assemblage)
;  (class !liver :partial !organ)
  )