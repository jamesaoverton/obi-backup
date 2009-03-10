(defparameter *core-terms* 
  (remove-duplicates(list !obo:IAO_0000018 ;;material entity
	!obo:OBI_0100026 ;;organism
	!obo:OBI_0000245 ;;organization
	!chebi:23367	 ;;molecular entities
	!obo:OBI_0302729 ;;chemical entities in solution
	!obo:OBI_0000256 ;;environmental matter
	!obo:OBI_0100015 ;;anatomical entity
	!obo:OBI_0000047 ;;processed material - was artifact object
	!obo:OBI_0100051 ;;specimen



	!obo:IAO_0000027 ;;data item
	!obo:IAO_0000100 ;;data set
	;;data structure
	!obo:IAO_0000091 ;;narrative object - report
	!obo:IAO_0000059 ;;narrative object - figure
	!obo:IAO_0000010 ;;software
	;;variable
	!obo:OBI_0000074 ;;hypothesis
	!obo:IAO_0000088 ;;report of results
	!obo:IAO_0000035 ;;conclusion
	!obo:IAO_0000005 ;;objective specification
	!obo:OBI_0500000 ;;study design
	!obo:IAO_0000032 ;;scalar measurement datum

	!obo:OBI_0000275 ;;analyte role
	!obo:OBI_0000587 ;;protocol participant role
	!obo:OBI_0000022 ;;specified input role
	!obo:OBI_0000657 ;;specified output role
	!obo:OBI_0000067 ;;evaluant role
	!obo:OBI_0000086 ;;reagent role
	!obo:OBI_0000133 ;;reference role
	;;study personnel role
	!obo:OBI_0000097 ;;study subject role
	!obo:OBI_0000112 ;;specimen role



	!obo:OBI_0000066 ;;investigation
	!obo:OBI_0500000 ;;study design - already in from denrie
	!obo:OBI_0000272 ;;protocol
	!obo:OBI_0000070 ;;assay
	!obo:OBI_0000443 ;;analyte assay
	!obo:OBI_0000274 ;;adding a material entity into a target (was material administration?)
	!obo:OBI_0000011 ;;planned process
	!obo:IAO_0000005 ;;objective specification - already in from DENRIE
	!obo:IAO_0000104 ;;plan specification
	!obo:OBI_0000094 ;;processing material - was artifact creation?
	!obo:OBI_0600014 ;;material separation
	!obo:OBI_0000457 ;;manufacturing



	!obo:OBI_0200000 ;;DT
	!obo:OBI_0200166 ;;DT objective
	!obo:OBI_0000417 ;; achieves_planned_objective
	!obo:OBI_0000301 ;;has_specified_output_information
	!obo:OBI_0000315 ;;has_specified_input_information
	!obo:IAO_0000027 ;;data item - already in from DENRIE
	!obo:IAO_0000100 ;;data set - already in from DENRIE
	;;report figure -  - already in from DENRIE
	;;software -  - already in from DENRIE



	!obo:OBI_0400002 ;;device
	!obo:OBI_0400003 ;;instrument
	!obo:OBI_0000050 ;;platform
	!obo:OBI_0000047 ;;processed material - was artifact object - already in from Biom
	!obo:OBI_0400167 ;;device function
	!obo:OBI_0000402 ;;canonical realization of device function
	!obo:OBI_0000453 ;;produce data function
	!obo:OBI_0000392 ;;information processor function
	!span:Process
	!obo:OBI_0000272 ;;protocol - already in from PaPP
	)))

(defun write-core-terms (kb &optional (dest "obi:branches;core.owl"))
  (loop with queue = *core-terms*
       while queue
       for term = (pop queue)
       with supers = (make-hash-table)
     do
       (dolist (one (parents term kb))
	 (unless (#"matches" (localname one) "_.*")
	   (pushnew one (gethash term supers)))
	 (push one queue))
     finally 
       (return-from write-core-terms supers)
       ))

       
