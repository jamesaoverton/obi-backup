1. Assign IDs

Run AssignOBIIDs.java


2. Quality Check, details see OBIrelease-qualityCheck.txt

All the SPARQL queries run in Protege 3.4.7 or Twinkle.

Fixed issues:
- add missing 'has curation status' which are required for the release (term: minimal inhibitory concentration)


3. Add missing 'editor preferred term' annotation property, which is required meta-data
	- add the property and set the value as rdfs:label

Run AddEditorPreferredTerms.java


4. Generate disjoints.owl using lisp script written by Alan

Since the code is not compatible with BFO 2, use the previous release of disjoint.owl file. Will write Java code and replace it in next release


5. Create directory '2012-03-29' under obi/releases, check previous release version to copy the files needed und the directory


6. Check consistency after adding disjoint axioms

- open obi.owl using Protege 4.1
- manually import disjoints.owl
- reasoning using Hermit 1.3.4
    classified using Hermit, no conflicts were found and reasoning took 118 sec





8. create inferred-superclasses.owl using Java program (OBIrelease.java)
	merge disjoint.owl to obi.owl and then create inferred version of OBI with super classes cleaned

9. merge files using Java program (OBIrelease.java)
    merge following files to inferred_obi.owl
		external.owl
		external-byhand.owl
		externalDerived.owl

10. clean the merged file using Protege 4.1
	- open merged_obi.owl using Protege 4.1
	- delete '_defined_material', '_defined processes' and '_defined_output', choose delete the class only option
	- remove 'curator note' (go to Annotation Properties Tab, choose 'curator note' and hit delete icon)
	  Saving format is RDF/XML. The file named as cleaned_merged_obi.owl.

11. Open cleaned_merged_obi.owl and reasoning using Hermit 1.3.4, reasoning took 174 sec. The merge owl is consistent. Can be opened in both 4.1 and 3.4.7 version


Some modifications need to make on the merged owl file
-------------------------------------------------------------------------
12. Summary counts of classes or properties in obi.owl

copy file cleaned_merged_obi.owl to /home/jiezheng/release/

# Start lisp
~/obi/svn-lsw/trunk/bin/lsw --load ~/obi/load-obi.lisp

# Run script
(entity-report (load-kb-jena "/home/jiezheng/release/cleaned_merged_obi.owl")) 

Results
===============================
Class   oboInOwl 6
Class   IAO 124
Class   GAZ 1
Class   UO 11
Class   OBI 1910
Class   PATO 49
Class   BFO 39
Class   NCBITaxon 1170
Class   CL 19
Class   CHEBI 53
Class   SO 3
Class   UBERON 19
Class   GO 102
Class   PR 15
Class   owl 2
Class   ENVO 2
Class   OGMS 3
Class   CARO 5
Class   HP 1
Class   VO 2
Property        OBI 39
Property        IAO 42
Property        dc 15
Property        owl 1
Property        rdf-schema 3
Property        protege 1
Property        iao 1
Property        oboInOwl 23
Property        ro 18
Property        OBO_REL 7
===============================

13. Create IEDB view 

Run ExtractAnnotProp.java











13. Header modification
	- modifiy the meta-data of merged owl file based on previous released OBI owl one - can be done after clean up subclasses
	- add the doap instance (check doap.owl, need add the header in the merged obi file)
	- add release name in the as rdfs:lable property of <doap:Version >
    - add following elements in the header too
    <owl:versionIRI rdf:resource="http://purl.obolibrary.org/obo/obi/2011-07-20/obi.owl"/>
    <owl:versionInfo rdf:datatype="http://www.w3.org/2001/XMLSchema#string">2011-07-20</owl:versionInfo> (2011-07-20 is the date of release, required by IIRC Bioportal)


14. Consult with IAO people. We typically release a fixed IAO with OBI release.
	<owl:imports rdf:resource="http://purl.obolibrary.org/obo/iao/2011-08-04/iao.owl"/> (should put the date: 2011-08-04 of iao.owl release)

15. Add comments to the merged owl file

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

