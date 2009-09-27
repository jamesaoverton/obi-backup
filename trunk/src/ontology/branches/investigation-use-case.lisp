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
(defun fcuri (i)
  (make-uri nil (format nil "obifce:~4,'0d" i)))
(defun fcobiuri (i)
  (make-uri nil (format nil "obisoon:~7,'0d" (+ i))))

(define-ontology investigation-use-case
    (:base (uri-full !obo:obi/investigation-use-case.owl) :about (uri-full !obo:obi/investigation-use-case.owl))
  (ontology-annotation !owl:versionInfo "$Revision: 80 $")
  (let ((*default-uri-label-source* :obi))
    (with-obo-metadata-uris
	(object-property !'is_specified_output_of'@)   (object-property !'has_specified_output'@)
	(object-property !'has_specified_input'@) (object-property !'denotes'@)
	(object-property !'realizes'@)  (object-property !'is_realized_by'@) (object-property !'bearer_of'@)
	(object-property !'inheres_in'@)  (object-property !oborel:has_part) (object-property !oborel:part_of) (object-property !oborel:has_participant)
	(object-property !'has_role'@)
	(annotation-property !rdfs:label)  (annotation-property !owl:versionInfo)
	(owl-imports !obo:obi.owl)
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
	      ;; the following should move into obi proper - here for now to be able to keep track of them
	      (informed-consent-process (fcobiuri 1))
	      (informed-consent-document-agreement-by-patient (fcobiuri 2))
	      (informing-subject-of-study-arm (fcobiuri 3))
	      (informing-investigator-of-subject-study-arm (fcobiuri 3))
	      (informing-investigator-of-subject-study-arm (fcobiuri 4))
	      (single-blind-study-execution (fcobiuri 5))
	      (double-blind-study-execution (fcobiuri 6))
	      (to-be-treated-with-placebo-role (fcobiuri 7))
	      (to-be-treated-with-active-ingredient-role (fcobiuri 8)))
	
	  (list

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
	     (annotation !definition "One or more processes in which subject is taught key facts about a clinical trial both before deciding whether or not to participate, and throughout the study. Agents of the investivation, such as doctors and nurses involved in the trial, explain the details of the study.")
	     (annotation !definition-source "http://clinicaltrials.gov/ct2/info/glossary#informed")
	     (annotation !definition-editor "Person:Alan Ruttenberg")
	     (label "Informed consent process")
	     :partial (manch (and !snap:ProcessualEntity
				  (some !oborel:has_participant
					(some !'has_role'@ !'investigation agent role'@))
				  (some !oborel:has_participant
					(manch (some !'has_role'@ !'study subject role'@)))
				  )))
	
	   (class informed-consent-document-agreement-by-patient
	     (annotation !definition "A process in which a subject receives an informed consent document and agrees that they have understood it")
	     (annotation !definition-editor "Person:Alan Ruttenberg")
	     :partial
	     (manch (and !'planned process'@
			 (some !oborel:part_of informed-consent-process))))

	   (class informing-subject-of-study-arm :partial
		  (label "informing subject of study arm")
		  (annotation !definition "A process in which the subject is made aware of which study arm they are participating in, for example whether they are receiving a placebo or a treatment with an investigational compound.")
		  (annotation !definition-editor "Person:Alan Ruttenberg")
		  (manch (and !span:Process
			      (some !oborel:has_participant
				    (some !'has_role'@ !'study subject role'@))
			      (some !oborel:part_of informed-consent-process))))
	       
	   (class informing-investigator-of-subject-study-arm :partial
		  (label "informing investigator of subject study arm")
		  (annotation !definition "A process in which an investigator is made aware of which study arm that a patient is participating in, for example whether they are receiving a placebo or a treatment with an investigational compound.")
		  (annotation !definition-editor "Person:Alan Ruttenberg")
		  (manch (and !span:Process
			      (some !oborel:has_participant
				    (some !'has_role'@ !'investigation agent role'@))
			      (some !'has_specified_input'@
				    (some !'denotes'@ (some !'bearer_of'@ !'study subject role'@)))
			      )))

	   (class single-blind-study-execution :complete
		  (label "single blind study execution")
		  (annotation !definition "A single blind study execution is defined as any study execution in which the subjects are not informed of which study arm they are part of")
		  (annotation !definition-editor "Person:Alan Ruttenberg")
		  (annotation !definition-source "http://clinicaltrials.gov/ct2/info/glossary#single")
		  (manch (and !'study design execution'@
			      (all !oborel:has_part (not informing-subject-of-study-arm)))))

	   (class double-blind-study-execution 
	     (label "double blind study execution")
	     (annotation !definition "A double blind study execution is defined as any study execution in which neither the subjects nor the investigators are informed of which study arm the subjects are part of")
	     (annotation !definition-editor "Person:Alan Ruttenberg")
	     (annotation !definition-source "http://clinicaltrials.gov/ct2/info/glossary#double")	   
	     :complete
	     (manch (and !'study design execution'@
			 (all !oborel:has_part (not (or informing-subject-of-study-arm
							informing-investigator-of-subject-study-arm
							))))))
	  
	   (individual fucoidan-investigation
	     (label "investigation - Fucoidan Investigation")
	     (type !'investigation'@)
	     (value !oborel:has_part fucoidan-study-execution)
	     (value !oborel:has_part fucoidan-investigation-planning))

	   (individual lowenthal-study-plan
	     (label "plan - RM Lowenthal's plan to develop a study design for Fucoisidan investigation")
	     (type !'plan'@)
	     (value !'inheres_in'@ rm-lowenthal)
	     (value !'is_realized_by'@ fucoidan-investigation-planning))

	   (individual fucoidan-investigation-planning
	     (label "planning - part of Fucoidan Investigation")
	     (type !'planning'@)
	     (value !'has_specified_output'@ fucoidan-study-design)
	     (value !'realizes'@ lowenthal-study-plan))

	   (individual fucoidan-study-execution
	     (label "study design execution - of Fucoidan investigation")
	     (type 
	      (manch (and 
		      !'study design execution'@
		      (all !oborel:has_part (not informing-subject-of-study-arm)))))
	     )

	   (individual fucoidan-study-design
	     (label "study design - of Fucoidan Investigation")
	     (type !'study design'@)
	     (value !'is_specified_output_of'@ fucoidan-investigation-planning)
	     (annotation !editor-note
			 "This should be a more specific subclass of study design. Parallel group and reference design were suggested. Need to further investigate and determine disjoints."))
  
	   (individual fucoidan-study-enrollment
	     (label "enrollment - of patients for Fucoidan investigation")
	     (type !'human subject enrollment'@))

	   ;; materials - there are going to be a lot of instances of these

	   ;; this one is wrong - fucoidan is a molecular entity. We need to use the concentration example here.
	   (individual fucoidan-75% 
	     (label "fucoidan 75 % - fucoidan study")
	     (type !'fucoidan'@)
	     (annotation !definition-editor "Helen Parkinson")
	     (annotation !definition "Instance of fucoidan 75% - fucoidan study"))

	   ;; don't think we need to instantiate - better to just assert the type
	   (individual fucoidan-drug-role
	     (label "drug role - fucoidan study")
	     (annotation !definition "instance of guar gum  reference material - fucoidan study")
	     (annotation !definition-editor "Helen Parkinson")
	     (type !'drug role'@)
	     (value !'inheres_in'@ fucoidan-75%))

	   ;; going to be a lot of these
	   (individual tube 
	     (label "polystyrene tube - fucoidan study")
	     (type !'polystyrene tube'@)
	     (annotation !definition-editor "Helen Parkinson")
	     (annotation !definition "instance of a polystyrene tube - fucoidan study"))

	   ;; and these
	   (individual !obi:guar_gum_6
	     (label "guar gum reference - fucoidan study")
	     (type !<http://purl.obofoundry.org/obo/guar_gum>)
	     (annotation !definition-editor "Helen Parkinson")
	     (annotation !definition "instance of guar gum  reference material - fucoidan study"))

	   ;; don't think we need to instantiate - better to just assert the type
	   (individual guar-gum-role
	     (label "guar gum reference - fucoidan study")
	     (annotation !definition "instance of negative reference substance role for guar gum - fucoidan study")
	     (annotation !definition-editor "Helen Parkinson")
	     (type !'negative reference substance role'@)
	     (value !'inheres_in'@ !obi:guar_gum_6))

	   ;; subjects - there are going to be a lot of instances of these. 

	   (class to-be-treated-with-active-ingredient-role
	     :partial !'study subject role'@
	     (label "to be treated with active ingredient role")
	     (annotation !definition "A study subject role which begins to exist when a subject is assigned to be one of those who will receive active ingredient, and is realized in a study execution in which they receive the active ingredient")
	     (annotation !definition-editor "Person:Alan Ruttenberg")
	   )

	   ;; more detail needed here: that the subject ingests the drug
	   (class to-be-treated-with-fucoidan-role

	     :complete
		  (manch (and to-be-treated-with-active-ingredient-role
			      (some !'is_realized_by'@ (one-of fucoidan-study-execution))))
		  (label "Role of subject to be treated with fucoidan in the pilot study")
		  (annotation !definition "Role of any subject in the fucoidan study who is to be treated with fucoidan pilot study as active ingredient")
		  (annotation !definition-editor "Person:Alan Ruttenberg")
		  )

	   (class to-be-treated-with-placebo-role :partial !'study subject role'@
	     (label "to be treated with placebo role")
	     (annotation !definition "A study subject role which begins to exist when a subject is assigned to be one of those who will receive a placebo, and realized in a study execution in which they receive the placebo")
	     (annotation !definition-editor "Person:Alan Ruttenberg"))

	   ;; more detail needed here: that the subject ingests the placebo
	   (class to-be-treated-with-guar-gum-role :complete
		  (manch (and to-be-treated-with-placebo-role
			      (some !'is_realized_by'@ (one-of fucoidan-study-execution))))
		  (label "Role of subject to be treated with placebo in the pilot study")
		  (annotation !definition "Role of any subject in the fucoidan study who is to be treated with guar gum in the pilot study as placebo")
		  (annotation !definition-editor "Person:Alan Ruttenberg"))

	   (class control-subject :complete
		  (manch (and !'homo sapiens'@
		      (some !'bearer_of'@ to-be-treated-with-guar-gum-role)))
		  (label "Subject in control arm of fucoidan pilot study")
		  (annotation !definition "Exactly those subjects who are assigned to be treated with active ingredient in the fucoidan pilot study")
		  (annotation !definition-editor "Person:Alan Ruttenberg"))

	   (class treated-subject :complete
		  (manch (and !'homo sapiens'@
			      (some !'bearer_of'@ to-be-treated-with-fucoidan-role)))
		  (label "Subject in treated arm of fucoidan pilot study")
		  (annotation !definition "Exactly those subjects who are assigned to be treated with placebo in the fucoidan pilot study")
		  (annotation !definition-editor "Person:Alan Ruttenberg"))

	   ;; test - should be able to query for participants in the study and have this individual returned as result
	   (individual subject1
	     (label "Homo sapiens treated with fucoidan - fucoidan study")
	     (type treated-subject)
	     (annotation !definition-editor "Helen Parkinson")
	     (annotation !definition "Instance of Homo sapiens for fucoidan study treated with fucoidan"))

	   (individual subject2
	     (label "Homo sapiens treated with guar gum - fucoidan study")
	     (type control-subject)
	     (annotation !definition-editor "Helen Parkinson")
	     (annotation !definition "Instance of Homo sapiens for fucoidan study treated with guar gum"))
	   )))))