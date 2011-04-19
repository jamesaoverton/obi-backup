Checking before making merged owl file for release
--------------------------------------------------

1. Unable to retrieve the labels and definitions of some imported terms, add manually in external_byHand.owl (see MIREOT_missing_terms.txt)

2. obi.owl quality check, details see OBIrelease-qualityCheck.txt

3. change IRI of Protein ontology terms
	from: http://purl.org/obo/owl/PRO#PRO_
	to:	  http://purl.obolibrary.org/obo/PR_

(idspace: PR http://purl.obolibrary.org/obo/PR_)

4. Manually assign the OBI id to annotation Proterty 'IEDB alternative term', replace 'IAO_0000118_1' with OBI_9991118

5. Assign IDs

# get OBI related files
svn co http://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/branches/ ~/obi/src/ontology/branches/ 
svn co http://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/external/ ~/obi/src/ontology/external/ 
svn co http://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/ ~/obi/src/tools/ 

# start LISP

in Helios server (Linux system):
~/obi/svn-lsw/trunk/bin/lsw --load ~/obi/load-obi.lisp

# First set some path variables according to where files are in your system

(setq path-to-obi "/home/jiezheng/obi/src/ontology/branches/obi.owl")
(setq path-to-text-mining-experiment "/home/jiezheng/obi/src/ontology/branches/text-mining-experiment.owl")
(setq path-to-new-obi "/home/jiezheng/obi/src/ontology/branches/obi-new.owl")

# create a mapping from temp ids to new ids
(setq map (get-uri-rewrites 
    (list path-to-obi "http://purl.obolibrary.org/obo/obi.owl") 
    (list path-to-text-mining-experiment "http://purl.obolibrary.org/obo/obi/text-mining-experiment.owl")))

# Then you apply the map to the file to create a new one
(rewrite-uris map path-to-obi path-to-new-obi (uri-full !obo:obi.owl))

# copy the old header
(rewrite-uris map "/home/jiezheng/obi/src/ontology/branches/obi.owl"
"/home/jiezheng/obi/src/ontology/branches/obi-new.owl" (uri-full !obo:obi.owl)
:with-header t)

6. Fix some issues after assigning IDs
	
- Carlo changes some axioms of services related classes
- One term indicated as obsolete term but not move to 'obsolete Class'
	details see SVN log



Create disjoints.owl and inferred_superclasses.owl for making merged file
-------------------------------------------------------------------------
NOTE: unable to generate assumed individual owl using the script written by Alan, ignore this file for this release, also ignored in the OBI release RC2


7. Generate disjoints.owl using lisp script written by Alan
	disjoint axioms will be added to all asserted classes but not defined classes. The disjoint axioms will be written in disjoints.owl file.

   Run bash file, named as OBIrelease-disjoint.sh in the Linux system
	It is part of the OBIrelease.sh. The bash file will check out the obi related files, set SVN revision number and generate disjoints.owl file.

Commands used in helios server
cd release
./OBIrelease-disjoint.sh


8. Check consistency after adding disjoint axioms

- open obi.owl using Protege 4.1
- manually import disjoints.owl
- reasoning using Hermit 1.3.3
    classified using Hermit, no conflicts were found and reasoning took 193 sec
    
    
9. create inferred-superclasses.owl using P4.1
    export inferred axioms of Subclasses, only check 'Subclasses' option in the 'Select axioms to export' pop-up window, not include asserted axioms
	(with disjoint.owl imported)
	set URL as http://purl.obolibrary.org/obo/obi/inferred-superclasses.owl
	the file format use 'RDF/XML'


10. remove the axioms that defined in obi.owl from inferred-superclasses.owl using the script (PruneSubClasses.java) written by Carlo
	need to change path to fit your installation
	The owl file contains only inferred superclass axioms is named as new-inferred-superclasses.owl 



Create merged owl file
-------------------------------------------------------------------------
11. merge the owl files 
	- open obi.owl using Protege 4.1
	- manually import disjoint.owl and new-inferred-superclasses.owl
	- delete '_defined_material', '_defined processes' and '_defined_output', choose delete the class only option
	- remove 'curator note' (go to Annotation Properties Tab, choose 'curator note' and hit delete icon)
	- go to Refactor menu, select 'Merge ontologies ...' option, merge following owl files
		obi.owl
		external.owl
		external-byhand.owl
		externalDerived.owl
		disjoint.owl
		new-inferred-superclasses.owl
	  The URL is http://purl.obolibrary.org/obo/obi/obi-merged.owl. Saving format is RDF/XML.
Hermit 1.3.3 Reasoning took 183 sec.

	- remove all import statements except protege-dc.owl and change ontology uri to obi.owl







I have created a merged-obi.owl for release. All related files have been 
committed to sourceforge under releases/2010-10-26.

For check out:
https://obi.svn.sourceforge.net/svnroot/obi/releases/2010-10-26

merged-obi.owl is under 2010-10-26/merged directory.

290 deprecated OBI classes before Philly release based on revision 2489 were removed.


Following are details of making the merged obi file:

1. make freshly check out of obi files

2. generate disjoint.owl using lisp script written by Alan

3. manually import disjoint.owl after open obi.owl using Protege 4.1
    classified using Hermit, no conflicts were found and reasoning took 163 sec

4. create inferred-superclasses.owl using P4.1
    only export inferred axioms of Subclasses and not check any options in the next pop-up window

5. merge the owl files 
	- open obi.owl using Protege 4.1
	- manually import disjoint.owl and inferred-superclasses.owl
	- delete '_defined_material', '_defined processes' and '_defined_output', choose delete the class only option
	- go to Refactor menu, select 'Merge ontologies ...' option, merge following owl files
		obi.owl
		external.owl
		external-byhand.owl
		externalDerived.owl
		disjoint.owl
		inferred-superclasses.owl
		bfo/1.1
		iao/iao-main.owl
		iao/ontology-metadata.owl
		iao/dev/external.owl
		iao/dev/externalDerived.owl
		iao/dev/externalByHand.owl
		ro/ro.owl		
	- remove all import statements except protege-dc.owl and change ontology uri to obi.owl
	
classified using Hermit, no conflicts were found and reasoning took 167 sec (no inferred superclasses too)

6. fix some known issues
	- remove obsolete IAO IDs
	- remove unused BFO terms
	- update some ChEBI terms label and definition	
	http://purl.obolibrary.org/obo/CHEBI_33697 ribonucleic acid (label + definition)
	High molecular weight, linear polymers, composed of nucleotides containing ribose and linked by phosphodiester bonds; RNA is central to the synthesis of proteins.
	http://purl.obolibrary.org/obo/CHEBI_16991 deoxyribonucleic acid (label)
	- fix http://purl.obolibrary.org/obo/OBI_0000066 investigation caused by imported to IAO
		remove duplicated definition
		remove empty annotation property
		remove 'imported from' annotation property

classified using Hermit, no conflicts were found and reasoning took 85 sec (no inferred superclasses too)

7. got svn log and saved as SVNlogs.txt under releases/2010-10-26/merged directory







Note: The quality checking of curation status and  editor preferred term 
properties have been done before creating the merged file.



Need to be fixed
================

- http://purl.obolibrary.org/obo/OBI_0000066 investigation

Issue: show duplicate definition, and displayed 'label' and 'editor preferred term' in iao/dev/externalDerived.owl instead of those defined in obi.owl
Reason: defined in OBI and imported into IAO


Question:
        <owl:imports rdf:resource="http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl"/>
        <owl:imports rdf:resource="http://purl.obolibrary.org/obo/iao/dev/iao.owl"/>
        <owl:imports rdf:resource="http://purl.org/obo/owl/ro_bfo_bridge1_1"/>
        <owl:imports rdf:resource="http://www.ifomis.org/bfo/1.1"/>
        <owl:imports rdf:resource="http://www.obofoundry.org/ro/ro.owl"/>

