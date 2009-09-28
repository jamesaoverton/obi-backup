#|
AI: AR will model by Sept. 28 (as discussed on previous call) or we go
with generic treatment approach.
- need to capture data transformation of collection of measurements
from the AT3 assay.
-- They used a statistical test (i.e., generated a P-value) but not
clear which test (don't want to say t-test if don't know for sure).

AR has feedback from BS who suggests:

blinding - model as disclosure process, and 'lacks disclosure to
subjects/researchers' for single/double blinded trials

modelling which person (and inferring group) treated with active vs
control compound - is OK

BS suggests adding a new subtype of subject role 'to be treated with
fucoidan during study fucoidan study' - will be realised in an instance
of a study, is a defined class specialized by context. Needs a better label.

AI: AR will model both blinding and to be treated role  examples for the
fucoidan example in the instance file

Discussion on modelling the dosing regime - 3g per day over 12 days. JF
wants to model this precisely. AR suggests modelling each daily dose as
a separate process and using an aggregate process to combine these sub
part processes. HP raised question what's the output/input as the input
for day2/dose 2 has to be the specified output of day1/dose 1 process,
and these need to be linked in order and referenced to specific
participants - day1->day2 , etc. Will be easier to model as a single
process where the plan specifies the dose - less granlar though

http://clinicaltrials.gov/ct2/info/glossary

BLIND: A randomized trial is "Blind" if the participant is not told
which arm of the trial he is on. A clinical trial is "Blind" if
participants are unaware on whether they are in the experimental or
control arm of the study. also called masked. (See Single Blind Study
and Double Blind Study).

INFORMED CONSENT: The process of learning the key facts about a
clinical trial before deciding whether or not to participate. It is
also a continuing process throughout the study to provide information
for participants. To help someone decide whether or not to
participate, the doctors and nurses involved in the trial explain the
details of the study.
|#

(register-namespace "obifce:" "http://purl.obolibrary.org/obo/obi/example/fucoidan/fc_")

(register-namespace "obisoon:" "http://purl.obolibrary.org/obo/TMPOBI_")

(register-namespace "iaosoon:" "http://purl.obolibrary.org/obo/TMPIAO_")

(defun fcuri (i)
  (make-uri nil (format nil "obifce:~4,'0d" i)))

(defun fcobiuri (i)
  (make-uri nil (format nil "obisoon:~7,'0d" (+ i))))

(defun fciaouri (i)
  (make-uri nil (format nil "iaosoon:~7,'0d" (+ i))))

(defun 4obi () (editor-note "2009/09/28 Alan Ruttenberg. This class is a class that should be added to OBI. It was motivated by the Fucoidan trial use case"))

(defun 4import ()
  (editor-note "2009/09/28 Alan Ruttenberg. This class is a class that should be mireoted in to OBI. It was motivated by the Fucoidan trial use case"))

(defun 4iao ()
  (editor-note "2009/09/28 Alan Ruttenberg. This class is a class that should be added to IAO. It was motivated by the Fucoidan trial use case"))

(defun signedalan () (definition-editor "Person:Alan Ruttenberg"))
(defun signedhelen () (definition-editor "Person:Helen Parkinson"))
(defun editor-note (note) (annotation !editor-node note))
(defun definition (note) (annotation !definition note))
(defun definition-source (note) (annotation !definition-source note))
(defun definition-editor (note) (annotation !definition-editor note))

(define-ontology investigation-use-case
    (:base (uri-full !obo:obi/investigation-use-case.owl) :about (uri-full !obo:obi/investigation-use-case.owl))
  (ontology-annotation !owl:versionInfo "$Revision: 80 $")
  (let ((*default-uri-label-source* :obi))
    (with-obo-metadata-uris
	(object-property !'is_specified_output_of'@)   (object-property !'has_specified_output'@)
	(object-property !'has_specified_input'@) (object-property !'denotes'@)
	(object-property !'realizes'@)  (object-property !'is_realized_by'@) (object-property !'bearer_of'@)
	(object-property !'inheres_in'@) (object-property !'role_of'@) (object-property !'has grain'@)
	(object-property !'has_quality'@) (object-property !oborel:has_part) (object-property !oborel:part_of)
	(object-property !oborel:has_participant) (object-property !'has_role'@)
	(object-property !'has measurement unit label'@) (datatype-property !'has measurement value'@)
	(annotation-property !rdfs:label)  (annotation-property !owl:versionInfo)
	(annotation-property !definition (label "definition"))
	(annotation-property !definition-source (label "definition source"))
	(annotation-property !definition-editor (label "definition editor"))
	(annotation-property !editor-note (label "editor note"))
	;;	(owl-imports !obo:obi.owl)
	;; put these uris into a http://purl.obolibary.org/obo/obi/example/OBIX_xxxxx
	(let ((fucoidan-75% (fcuri 1))
	      (rm-lowenthal (fcuri 2))
	      (lowenthal-pi-role (fcuri 3))
	      (lowenthal-study-plan (fcuri 4))
	      (fucoidan-investigation-planning (fcuri 5))
	      (fucoidan-study-enrollment (fcuri 6))
	      (fucoidan-study-execution (fcuri 7))
	      (fucoidan-investigation (fcuri 8))
	      (fucoidan-study-design (fcuri 9))
	      (fucoidan-drug-role (fcuri 10))
	      (guar-gum-role (fcuri 11))
	      (tube (fcuri 12))
	      (control-group (fcuri 13))
	      (treated-group (fcuri 14))
	      (control-subject (fcuri 15))
	      (treated-subject (fcuri 16))
	      (to-be-treated-with-guar-gum-role (fcuri 17))
	      (to-be-treated-with-fucoidan-role (fcuri 18))
	      (subject1 (fcuri 19))
	      (subject2 (fcuri 20))
	      (guar-gum-capsule-for-fucoidan-study (fcuri 21))
	      (fucoidan-capsule-for-fucoidan-study (fcuri 22))
	      (mass-of-3-grams (fcuri 23))
	      (mass-of-2point25-grams (fcuri 24))
	      (mass-of-point75-grams (fcuri 25))
	      (single-treatment-of-fucoidan-in-fucoidan-study (fcuri 26))
	      (single-treatment-of-placebo-in-fucoidan-study (fcuri 27))
	      (mass-measurement-datum (fcuri 28))
	      (fucoidan-treatment-portion (fcuri 29))
	      ;; imports
	      (mouth !obo:FMA#FMA_49184)
	      (mass !pato:0000125)
	      (mass-unit !unit:0000002)
	      (gram !unit:00000021)
	      ;; the following should move into obi proper - here for now to be able to keep track of them
	      (informed-consent-process (fcobiuri 1))
	      (informed-consent-document-agreement-by-patient (fcobiuri 2))
	      (informing-subject-of-study-arm (fcobiuri 3))
	      (informing-investigator-of-subject-study-arm (fcobiuri 3))
	      (informing-investigator-of-subject-study-arm (fcobiuri 4))
	      (single-blind-study-execution (fcobiuri 5))
	      (double-blind-study-execution (fcobiuri 6))
	      (to-be-treated-with-placebo-role (fcobiuri 7))
	      (to-be-treated-with-active-ingredient-role (fcobiuri 8))
	      (pill (fcobiuri 9))
	      (capsule (fcobiuri 10))
	      (capsule-shell (fcobiuri 11))
	      (filled-capsule (fcobiuri 12))
	      (oral-ingestion-of-pill (fcobiuri 13))
	      (treatment-portion-of-study-execution (fcobiuri 14))
	      (unblinding-process (fcobiuri 15))
	      ;; the following should move into iao proper - here for now to be able to keep track of them
	      (is-quality-measured-as (fciaouri 1))
	      )
	  (macrolet ((mass-measured-as-grams-def (n)
		       `(manch (and mass
				    (some is-quality-measured-as
					  (and mass-measurement-datum
					       (has !'has measurement unit label'@ gram)
					       (has !'has measurement value'@ (literal ,n !xsd:float))))))))


	    (list

	     (object-property is-quality-measured-as (label "is quality measured as") (inverse-of !'is quality measurement of'@))

	     ;; involved in running the study
	     (individual rm-lowenthal
	       (label "RM Lowenthal")
	       (type !taxon:9606)
	       (value !'bearer_of'@ lowenthal-pi-role))

	     ;; don't know if we need this. Alternative (type (manch (some !bearer_of !'principal investigator role'@)))
	     (individual lowenthal-pi-role
	       (label "PI role of RM Lowenthal")
	       (type !'principal investigator role'@))

	     ;; the investigation as process
	
	     ;; Probably should be generalized to IAO - communication
	     ;; process, with information giver and receiver role analogous
	     ;; to target of material addition role

	     (class informed-consent-process 
	       (definition "One or more processes in which subject is taught key facts about a clinical trial both before deciding whether or not to participate, and throughout the study. Agents of the investivation, such as doctors and nurses involved in the trial, explain the details of the study.")
	       (4obi)
	       (definition-source "http://clinicaltrials.gov/ct2/info/glossary#informed")
	       (editor-note "09/28/2009 Alan Ruttenberg: This is made a subclass of the higher level processual entity in BFO because I don't want to take a stand on whether it is a process aggregate. Analogous to the situation with Material entity.")
	       (signedalan)
	       (label "Informed consent process")
	       :partial (manch (and !snap:ProcessualEntity
				    (some !oborel:has_participant
					  (some !'has_role'@ !'investigation agent role'@))
				    (some !oborel:has_participant
					  (manch (some !'has_role'@ !'study subject role'@)))
				    )))

	
	     (class informed-consent-document-agreement-by-patient
	       (definition "A process in which a subject receives an informed consent document and agrees that they have understood it")
	       (signedalan)
	       (4obi)
	       (editor-note "09/28/2009 Alan Ruttenberg. There's a need for a general process like this in IAO - document and person in, signed document (and associated obligations, rights, out")
	       (label "subject agrees they understand informed consent document")
	       :partial
	       (manch (and !'planned process'@
			   (some !oborel:part_of informed-consent-process))))

	     (class informing-subject-of-study-arm :partial
		    (4obi)
		    (label "informing subject of study arm")
		    (definition "A process in which the subject is made aware of which study arm they are participating in, for example whether they are receiving a placebo or a treatment with an investigational compound.")
		    (signedalan)
		    (editor-note "09/28/2009 Alan Ruttenberg. This and the class informing-investigator-of-study-arm are defined in order to solve the question of how to represent single and double blind experiments. To represent the aspect of blinding pertaining to subjects (happens in single and double blinding) we say that that the study execution doesn't include any processes of this sort")
		    (manch (and !span:Process
				(some !oborel:has_participant
				      (some !'has_role'@ !'study subject role'@))
				(some !oborel:part_of informed-consent-process))))
	       
	     (class informing-investigator-of-subject-study-arm :partial
		    (4obi)
		    (label "informing investigator of subject study arm")
		    (definition "A process in which an investigator is made aware of which study arm that a patient is participating in, for example whether they are receiving a placebo or a treatment with an investigational compound.")
		    (signedalan)
		    (editor-note "09/28/2009 Alan Ruttenberg. This and the class informing-subject-of-study-arm are defined in order to solve the question of how to represent single and double blind experiments. To represent the aspect of double blinding pertaining to investigators, we say that the study execution doesn't include any processes of this sort")
		    (manch (and !span:Process
				(some !oborel:has_participant
				      (some !'has_role'@ !'investigation agent role'@))
				(some !'has_specified_input'@
				      (some !'denotes'@ (some !'bearer_of'@ !'study subject role'@)))
				)))
	     
	     (class treatment-portion-of-study-execution :partial (manch (and !'planned process'@
									      (some !oborel:part_of !'study design execution'@)))
		    (label "treatment portion of study execution")
		    (signedalan)
		    (4obi)
		    (definition "A planned process, part of a study design execution, during which the treatment of subjects is ongoing")
		    (editor-note "09/28/2009 Alan Ruttenberg. Needed because we have to have a process to scope blinding over"))


	     (class single-blind-study-execution :complete
		    (4obi)
		    (label "single blind study execution")
		    (definition "A single blind study execution is defined as any study execution in which the subjects are not informed of which study arm they are part of")
		    (signedalan)
		    (definition-source "http://clinicaltrials.gov/ct2/info/glossary#single")
		    (manch (and treatment-portion-of-study-execution
				(all !oborel:has_part (not informing-subject-of-study-arm)))))

	     (class double-blind-study-execution 
	       (label "double blind study execution")
	       (4obi)
	       (definition "A double blind study execution is defined as any study execution in which neither the subjects nor the investigators are informed of which study arm the subjects are part of")
	       (signedalan)
	       (definition-source "http://clinicaltrials.gov/ct2/info/glossary#double")	   
	       :complete
	       (manch (and treatment-portion-of-study-execution
			   (all !oborel:has_part (not (or informing-subject-of-study-arm
							  informing-investigator-of-subject-study-arm
							  ))))))

	     (class unblinding-process :partial (manch (and !'planned process'@
						     (some !oborel:part_of !'study design execution'@)
						     (some !oborel:part_of informing-subject-of-study-arm)))
		    (label "Unblinding process")
		    (definition "The part of the study execution in which the subjects are told what study arm they are in and in which the investigators are told which subjects are in which trials")
		    (signedalan)
		    (4obi))
	  
	     (individual fucoidan-investigation
	       (label "investigation - Fucoidan Investigation")
	       (type !'investigation'@)
	       (signedhelen)
	       (value !oborel:has_part fucoidan-study-execution)
	       (value !oborel:has_part fucoidan-investigation-planning))

	     (individual lowenthal-study-plan
	       (label "plan - RM Lowenthal's plan to develop a study design for Fucoisidan investigation")
	       (type !'plan'@)
	       (signedhelen)
	       (value !'inheres_in'@ rm-lowenthal)
	       (value !'is_realized_by'@ fucoidan-investigation-planning))

	     (individual fucoidan-investigation-planning
	       (label "planning - part of Fucoidan Investigation")
	       (type !'planning'@)
	       (signedhelen)
	       (value !'has_specified_output'@ fucoidan-study-design)
	       (value !'realizes'@ lowenthal-study-plan))

	     (individual fucoidan-study-execution
	       (label "study design execution - of Fucoidan investigation")
	       (signedhelen)
	       (type 
		(manch (and 
			!'study design execution'@
			(all !oborel:has_part (not informing-subject-of-study-arm)))))
	       )
	     	     
	     (individual fucoidan-treatment-portion
	       (label "treatment portion of study design execution - of Fucoidan investigation")
	       (signedalan)
	       (type 
		(manch (and 
			treatment-portion-of-study-execution
			(all !oborel:has_part (not informing-subject-of-study-arm)))))
	       (value !oborel:part_of fucoidan-study-execution)
	       )

	     (individual fucoidan-study-design
	       (label "study design - of Fucoidan Investigation")
	       (signedhelen)
	       (type !'study design'@)
	       (value !'is_specified_output_of'@ fucoidan-investigation-planning)
	       (editor-note "This should be a more specific subclass of study design. Parallel group and reference design were suggested. Need to further investigate and determine disjoints."))

  
	     (individual fucoidan-study-enrollment
	       (label "enrollment - of patients for Fucoidan investigation")
	       (signedhelen)
	       (type !'human subject enrollment'@))

	     ;; materials - there are going to be a lot of instances of these

	     ;; this one is wrong - fucoidan is a molecular entity. We need to use the concentration example here.
	     (individual fucoidan-75% 
	       (label "fucoidan 75 % - fucoidan study")
	       (type !'fucoidan'@)
	       (signedhelen)
	       (definition "Instance of fucoidan 75% - fucoidan study")
	       (editor-note "2009/09/28 Alan Ruttenberg. Mistake - fucoidan is a molecular entity. See class fucoidan-capsule-for-fucoidan-study"))

	     ;; don't think we need to instantiate - better to just assert the type
	     (individual fucoidan-drug-role
	       (label "drug role - fucoidan study")
	       (definition "instance of guar gum  reference material - fucoidan study")
	       (signedhelen)
	       (type !'drug role'@)
	       (value !'inheres_in'@ fucoidan-75%))

	     ;; going to be a lot of these
	     (individual tube 
	       (label "polystyrene tube - fucoidan study")
	       (type !'polystyrene tube'@)
	       (signedhelen)
	       (definition "instance of a polystyrene tube - fucoidan study"))

	     ;; and these
	     (individual !obi:guar_gum_6
	       (label "guar gum reference - fucoidan study")
	       (type guar-gum-capsule-for-fucoidan-study)
	       (signedhelen)
	       (definition "instance of guar gum  reference material - fucoidan study")
	       (editor-note "2009/09/28 Alan Ruttenberg. See class guar-gum-capsule-for-fucoidan-study"))

	     ;; don't think we need to instantiate - better to just assert the type
	     (individual guar-gum-role
	       (label "guar gum negative reference role - fucoidan study")
	       (definition "instance of negative reference substance role for guar gum - fucoidan study")
	       (signedhelen)
	       (type !'negative reference substance role'@)
	       (value !'inheres_in'@ !obi:guar_gum_6)
	       (editor-note "2009/09/28 Alan Ruttenberg. Probably no need to create this instance - part of type definition of guar-gum-capsule-for-fucoidan-study and can thus be queried for"))

	     ;; subjects - there are going to be a lot of instances of these. 

	     (class to-be-treated-with-active-ingredient-role
	       :partial !'study subject role'@
	       (4obi)
	       (label "to be treated with active ingredient role")
	       (definition "A study subject role which begins to exist when a subject is assigned to be one of those who will receive active ingredient, and is realized in a study execution in which they receive the active ingredient")
	       (signedalan)
	       )

	     (class to-be-treated-with-fucoidan-role
	       :complete
	       (manch (and to-be-treated-with-active-ingredient-role
			   (some !'is_realized_by'@ single-treatment-of-fucoidan-in-fucoidan-study)
			   ))
	       (label "Role of subject to be treated with fucoidan in the pilot study")
	       (definition "Role of any subject in the fucoidan study who is to be treated with fucoidan pilot study as active ingredient")
	       (signedalan)
	       )

	     (class oral-ingestion-of-pill
	       (label "oral ingestion of pill")
	       (definition "An adding a material entity to target with the entity is a pill and the target is the mouth")
	       (4obi)
	       :complete
	       (manch (and (some !'realizes'@ (and !'material to be added role'@
						   (some !'role_of'@ pill)))
			   (some !'realizes'@
				 (and !'target of material addition role'@
				      (some !'role_of'@ mouth)))
			   (some !'has_specified_input'@ pill)
			   )))
	   
	     (class filled-capsule (4obi) (label "filled capsule")
		    (definition "A pill in the form of a small rounded gelatinous container with medicine inside.")
		    (definition-source "http://www.golovchenko.org/cgi-bin/wnsearch?q=capsule#2n")
		    (signedalan)
		    :partial (manch (and pill (some !'has_part'@ capsule-shell))))

	     (class pill (label "pill")
		    (4obi)
		    (signedalan)
		    (definition "A dose of medicine or placebo in the form of a small pellet.")
		    (definition-source "http://www.golovchenko.org/cgi-bin/wnsearch?q=pill#2n")
		    :partial !snap:MaterialEntity)

	     (class capsule-shell (4obi) (label "capsule shell")
		    (definition "a small rounded gelatinous container")
		    (signedalan)
		    (definition-source "http://www.golovchenko.org/cgi-bin/wnsearch?q=capsule#2n")
		    :partial !snap:MaterialEntity)

	     (class mass (label "mass") (4import) :partial !'quality'@)
	     (class mouth (label "mouth") (4import) :partial (manch (and !snap:MaterialEntity (some !'part_of'@ !'homo sapiens'@))))

	     (class mass-measurement-datum
	       (4iao)
	       (label "mass measurement datum")
	       (signedalan)
	       (definition "A scalar measurement datum that is the result of measurement of mass quality")
	       :partial 
	       (manch (and !'scalar measurement datum'@ 
			   (all !'has measurement unit label'@ mass-unit)
			   (all !'is quality measurement of'@ mass))))
	     
	     (class mass-unit (4import) (label "mass unit") :partial !'measurement unit label'@)

	     (individual gram (4import) (label "gram") (type mass-unit))

	     (class mass-of-3-grams (label "mass measured to be 3 grams") :complete
		    (mass-measured-as-grams-def 3.0))
	     
	     (class mass-of-2point25-grams (label "mass measured to be 2.25 grams") :complete
		    (mass-measured-as-grams-def 2.25))
		    
	     (class mass-of-point75-grams (label "mass measured to be .75 grams") :complete
		    (mass-measured-as-grams-def .75))
	   
	     (class guar-gum-capsule-for-fucoidan-study
	       (label "guar gum capsule for fucoidan study")
	       :complete
	       (manch (and filled-capsule
			   (some !'has_part'@ 
				 (and
				  !'guar gum'@
				  (some !'has_quality'@ mass-of-3-grams))
				 capsule-shell))))

	     (class fucoidan-capsule-for-fucoidan-study :complete
		    (label "fucoidan capsule for fucoidan study")
		    (manch (and filled-capsule
				(some !'has_part'@
				      (and
				       (some !'has grain'@ !'fucoidan'@)
				       (some !'has_quality'@ mass-of-2point25-grams)))
				(some !'has_part'@
				      (and
				       (some !'has_quality'@ mass-of-point75-grams)))
				(some !'has_part'@ capsule-shell))))

	     (class single-treatment-of-placebo-in-fucoidan-study 
	       (label "single treatment of placebo in fucoidan study")
	       (signedalan)
	       :complete
	       (manch (and oral-ingestion-of-pill 
			   (some !'has_specified_input'@ guar-gum-capsule-for-fucoidan-study)
			   (some !'realizes'@ (and !'material to be added role'@
						   (some !'role_of'@ guar-gum-capsule-for-fucoidan-study)))
			   (has !'part_of'@ fucoidan-study-execution)
			   )))

	     (class single-treatment-of-fucoidan-in-fucoidan-study 
	       (label "single treatment of fucoidan in fucoidan study")
	       (signedalan)
	       :complete
	       (manch (and oral-ingestion-of-pill 
			   (some !'has_specified_input'@ fucoidan-capsule-for-fucoidan-study)
			   (some !'realizes'@ (and !'material to be added role'@
						   (some !'role_of'@ fucoidan-capsule-for-fucoidan-study)))
			   (has !'part_of'@ fucoidan-study-execution)
			   )))

	     (class to-be-treated-with-placebo-role :partial !'study subject role'@
		    (4obi)
		    (label "to be treated with placebo role")
		    (signedalan)
		    (definition "A study subject role which begins to exist when a subject is assigned to be one of those who will receive a placebo, and realized in a study execution in which they receive the placebo")
		    )

	     (class to-be-treated-with-guar-gum-role :complete
		    (manch (and to-be-treated-with-placebo-role
				(some !'is_realized_by'@ single-treatment-of-placebo-in-fucoidan-study)))
		    (label "Role of subject to be treated with placebo in the fucoidan pilot study")
		    (definition "Role of any subject in the fucoidan study who is to be treated with guar gum in the pilot study as placebo")
		    (signedalan))

	     (class control-subject :complete
		    (manch (and !'homo sapiens'@
				(some !'bearer_of'@ to-be-treated-with-guar-gum-role)))
		    (label "Subject in control arm of fucoidan pilot study")
		    (definition "Exactly those subjects who are assigned to be treated with active ingredient in the fucoidan pilot study")
		    (signedalan))

	     (class treated-subject :complete
		    (manch (and !'homo sapiens'@
				(some !'bearer_of'@ to-be-treated-with-fucoidan-role)))
		    (label "Subject in treated arm of fucoidan pilot study")
		    (definition "Exactly those subjects who are assigned to be treated with placebo in the fucoidan pilot study")
		    (signedalan))

	     ;; test - should be able to query for participants in the study and have this individual returned as result
	     (individual subject1
	       (label "Homo sapiens treated with fucoidan - fucoidan study")
	       (type treated-subject)
	       (signedhelen)
	       (definition "Instance of Homo sapiens for fucoidan study treated with fucoidan"))

	     (individual subject2
	       (label "Homo sapiens treated with guar gum - fucoidan study")
	       (type control-subject)
	       (signedhelen)
	       (definition "Instance of Homo sapiens for fucoidan study treated with guar gum"))
	     )
	    )))))