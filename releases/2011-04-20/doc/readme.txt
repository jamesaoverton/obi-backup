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

in the Linux system:
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
	SVN log will be written in SVNlogs.txt

   Run bash file, named as OBIrelease-SVN-disjoint.sh in the Linux system
	It is part of the OBIrelease.sh. The bash file will check out the obi related files, set SVN revision number and generate disjoints.owl file.

Commands used in the Linux system:
cd release
./OBIrelease-SVN-disjoint.sh


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

- if they axioms were defined using <owl:Class>, need to replace "owl:Class" with "rdf:Description" for making the script run correctly
- change path to fit your installation
- The owl file contains only inferred superclass axioms is named as new_inferred-superclasses.owl 
- open new_inferred-superclasses.owl in Protege 4.1 and saved for making nicely format named as new_inferred-superclasses-p4.owl (optional step for the release)


Create merged owl file
-------------------------------------------------------------------------
11. merge the owl files 
	- open obi.owl using Protege 4.1
	- manually import disjoint.owl and new_inferred-superclasses-p4.owl
	- delete '_defined_material', '_defined processes' and '_defined_output', choose delete the class only option
	- remove 'curator note' (go to Annotation Properties Tab, choose 'curator note' and hit delete icon)
	- go to Refactor menu, select 'Merge ontologies ...' option, merge following owl files
		obi.owl
		external.owl
		external-byhand.owl
		externalDerived.owl
		disjoint.owl
		new_inferred-superclasses-p4.owl
	  The URL is http://purl.obolibrary.org/obo/obi/merged-obi.owl. Saving format is RDF/XML. Need save twice, and removed those ontologies you don't want to change although they will be modified anyway. In this case, delete the files and check out from SVN again to avoid conflict.
	  (For duplicated name of imported ontologies, pick the second one.)
Hermit 1.3.3 Reasoning took 194 sec.


Missing two steps
-------------------------------------------------------------------------

1. script that remove the duplicated defined classes

2. script to add comments