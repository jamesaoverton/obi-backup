1. Assign IDs

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


2. update externalDerived.owl

Details instruction see: http://obi-ontology.org/page/Tutorials#MIREOT part 3.Generate externalDerived.owl

Need to check whether there are any issues to retrieve the labels and definitions of some imported terms. If so, add manually in external_byHand.owl.

(This time, there is no any problem.)


3. Quality Check, details see OBIrelease-qualityCheck.txt

All the SPARQL queries run in Protege 3.4.7 and Twinkle.

Fixed issues:
- add missing 'has curation status' which are required for the release
- add some 'definition source' and 'term editor' annotations which I know
- find one term has different value for 'editor preferred term' from rdfs:label, modify the 'editor preferred term'


4. Add missing 'editor preferred term' annotation property, which is required meta-data
- add the property and set the value as rdfs:label using Java program, will check in soon.

5. Generate disjoints.owl using lisp script written by Alan
	disjoint axioms will be added to all asserted classes but not defined classes. The disjoint axioms will be written in disjoints.owl file.
	SVN log will be written in SVNlogs.txt

   Run bash file, named as OBIrelease-SVN-disjoint.sh in the Linux system
	It is part of the OBIrelease.sh. The bash file will check out the obi related files, set SVN revision number and generate disjoints.owl file.

Commands used in the Linux system:
cd release
./OBIrelease-SVN-disjoint.sh

6. Create directory '2011-07-20' under obi/releases, check previous release version to copy the files needed und the directory

7. Check consistency after adding disjoint axioms

- open obi.owl using Protege 4.1
- manually import disjoints.owl
- reasoning using Hermit 1.3.4
    classified using Hermit, no conflicts were found and reasoning took 175 sec
    
8. create inferred-superclasses.owl using P4.1
    export inferred axioms of Subclasses, only check 'Subclasses' option in the 'Select axioms to export' pop-up window, not include asserted axioms
	(with disjoint.owl imported)
	set URL as http://purl.obolibrary.org/obo/obi/inferred-superclasses.owl
	the file format use 'RDF/XML'

9. remove the axioms that defined in obi.owl from inferred-superclasses.owl using the script (PruneSubClasses.java) written by Carlo

- if the axioms were defined using <owl:Class>, need to replace "owl:Class" with "rdf:Description" for making the script run correctly
- the file renamed as inferred-superclasses_mod.owl after modification
- change path in Java code to fit your installation
- The owl file contains only inferred superclass axioms is named as new_inferred-superclasses.owl 

10. Commit directory '2011-07-20' (including all files) under obi/releases



Create merged owl file
-------------------------------------------------------------------------
11. merge the owl files 
	- open obi.owl using Protege 4.1
	- manually import disjoint.owl and new_inferred-superclasses-p4.owl
	- delete '_defined_material', '_defined processes' and '_defined_output', choose delete the class only option
	- remove 'curator note' (go to Annotation Properties Tab, choose 'curator note' and hit delete icon)
	- go to Refactor menu, select 'Merge ontologies ...' option, merge following owl files
		disjoint.owl
		external.owl
		external-byhand.owl
		externalDerived.owl
		inferred-superclasses.owl
		obi.owl
	    (For duplicated name of imported ontologies, pick the second one.)

	  The URL is http://purl.obolibrary.org/obo/obi/merged-obi.owl. Saving format is RDF/XML. Need save twice, and removed those ontologies you don't want to change although they will be modified anyway. In this case, delete the files and check out from SVN again.
	  
12. Open merged-obi.owl and reasoning using Hermit 1.3.4, reasoning took 185 sec. The merge owl is consistent.


Some modifications need to make on the merged owl file
-------------------------------------------------------------------------
# Check out files to the Linux server:
svn co http://obi.svn.sourceforge.net/svnroot/obi/releases/2011-07-20/ ~/obi/releases/ 

13. Clean subclasses: Inferred parent classes of some classes are the subclass of their asserted ones. In this case, the classes need to be removed from their asserted parents

# Run Lisp script, current this command does not work, some functions are missing

~/obi/svn-lsw/trunk/bin/lsw --load ~/obi/load-obi.lisp

(clean-subclasses
"/home/jiezheng/obi/releases/merged/merged-obi.owl"
"/home/jiezheng/obi/releases/merged/merged-obi-cleaned-subclasses2.owl")


# The script ran by Alan. Got following error message in my computer:
# Debugger invoked on condition of type UNDEFINED-FUNCTION:
#  The function LOAD-ONTOLOGY is undefined.

14. Summary counts of classes or properties in obi.owl

# Start lisp
~/obi/svn-lsw/trunk/bin/lsw --load ~/obi/load-obi.lisp

# Run script
(entity-report (load-kb-jena "/home/jiezheng/obi/releases/merged/merged-obi-cleaned-subclasses.owl")) 

Results
===============================

Class   oboInOwl 6
Class   IAO 124
Class   GAZ 1
Class   UO 11
Class   OBI 1810
Class   PATO 49
Class   BFO 39
Class   NCBITaxon 1170
Class   FMA 12
Class   CHEBI 53
Class   SO 3
Class   GO 100
Class   UBERON 4
Class   CARO 3
Class   PR 15
Class   owl 2
Class   ENVO 2
Class   CL 19
Class   OGMS 3
Class   birnlex 1
Class   HP 1
Class   VO 2
Property        OBI 37
Property        IAO 39
Property        dc 15
Property        owl 1
Property        rdf-schema 3
Property        protege 1
Property        oboInOwl 23
Property        ro 18
Property        OBO_REL 7

===============================


15. Header modification
	- modifiy the meta-data of merged owl file based on previous released OBI owl one - can be done after clean up subclasses
	- add the doap instance (check doap.owl, need add the header in the merged obi file)
	- add release name in the as rdfs:lable property of <doap:Version >
    - add following elements in the header too
    <owl:versionIRI rdf:resource="http://purl.obolibrary.org/obo/obi/2011-07-20/obi.owl"/>
    <owl:versionInfo rdf:datatype="http://www.w3.org/2001/XMLSchema#string">2011-07-20</owl:versionInfo> (2011-07-20 is the date of release, required by IIRC Bioportal)


16. Consult with IAO people. We typically release a fixed IAO with OBI release.
	<owl:imports rdf:resource="http://purl.obolibrary.org/obo/iao/2011-08-04/iao.owl"/> (should put the date: 2011-08-04 of iao.owl release)

17. Add comments to the merged owl file

# Start lisp in linux system
~/obi/svn-lsw/trunk/bin/lsw --load ~/obi/load-obi.lisp

# add comment lisp
(comment-ids-in-owl-file "/home/jiezheng/obi/releases/merged/merged-obi-cleaned-subclasses.owl" "/home/jiezheng/obi/releases/merged/merged-obi-comments.owl" (load-kb-jena "/home/jiezheng/obi/releases/merged/merged-obi-cleaned-subclasses.owl")) 




Finalize release
-------------------------------------------------------------------------
- Send email for developers to review

- Prepare release notes, use previous release notes as template, contain following information
	a. New to this release - collected from OBI developers
	b. Count of terms in and used by OBI
	c. get new classes for this release, compare current merged obi file to last release by running 		
		("Bubastis" can be downloaded from EFO sourceforge.net website)

		Run commands:
			java -jar bubastis.jar -1 "file:C://JavaDev/compareOnt/obi_released.owl" -2 "file:C://JavaDev/compareOnt/merged_obi.owl" -t "C://JavaDev/compareOnt/diff.txt" -s
			java -jar bubastis.jar -1 "file:C://JavaDev/compareOnt/obi_released.owl" -2 "file:C://JavaDev/compareOnt/merged_obi.owl" -t "C://JavaDev/compareOnt/diff-long.txt"
	d. Generate a list of new classes with links in HTML format using perl script: generateMappingHTML.pl under obi\trunk\src\tools\

	Link to Release notes page: http://obi-ontology.org/page/Releases/2011-04-20 

- upload merged with comment obi owl file to purl and bioportal

- send email to inform the potential users

