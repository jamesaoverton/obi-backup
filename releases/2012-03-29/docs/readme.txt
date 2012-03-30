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


All the methods are in OBIrelease.java, but it can not run at same time due to memory issue, will separate the java file next time

7. create inferred-superclasses.owl using Java program (OBIrelease.java)
	merge external files to obi.owl (obi_merged.owl)
	create inferred version of OBI with super classes cleaned (obi_merged_inferred.owl)
	merge disjoint.owl to obi.owl (obi_disjoints.owl)
	merge IAO (obi_merged_iao.owl)

8. clean the merged file using Protege 4.1
	- open merged_obi.owl using Protege 4.1
	- delete '_defined_material', '_defined processes' and '_defined_output', choose delete the class only option
	- remove 'curator note' (go to Annotation Properties Tab, choose 'curator note' and hit delete icon)
	  Saving format is RDF/XML. The file named as cleaned_merged_obi.owl.
    - clean up some annotations of OBI terms that imported by IAO (investigation, planned process, study design, study design execution)

9. Open cleaned_merged_obi.owl and reasoning using Hermit 1.3.4, reasoning took 104 sec. The merge owl is consistent.


10. Summary counts of classes or properties in obi.owl

copy file cleaned_merged_obi.owl to /home/jiezheng/release/

# Start lisp
~/obi/svn-lsw/trunk/bin/lsw --load ~/obi/load-obi.lisp

# Run script
(entity-report (load-kb-jena "/home/jiezheng/release/cleaned_merged_obi.owl")) 

Results
===============================
Class   BFO 27
Class   OBI 1935
Class   NCBITaxon 1170
Class   GO 102
Class   CHEBI 53
Class   CL 19
Class   UBERON 20
Class   HP 1
Class   PR 15
Class   oboInOwl 5
Class   owl 3
Class   ENVO 3
Class   PATO 49
Class   OGMS 3
Class   SO 3
Class   CARO 5
Class   IAO 109
Class   VO 2
Class   UO 11
Class   GAZ 1
Property        OBI 39
Property        IAO 39
Property        BFO 38
Property        RO 7
Property        protege 1
Property        iao 1
Property        rdf-schema 3
Property        dc 15
Property        owl 2
===============================


11. Create IEDB view 

Run ExtractAnnotProp.java

cleaned_merged_obi_woIEDB.owl and other IEDB view related files

need to edit metadata of obi_IEDBview.owl, add version information and change obi.owl -> obi/obi_IEDBview.owl

12. Header modification
	- modifiy the meta-data of merged owl file based on previous released OBI owl one - can be done after clean up subclasses
	- add the doap instance (check doap.owl, need add the header in the merged obi file)
      need to add this namespace
     		xmlns:doap="http://usefulinc.com/ns/doap#"
	- add release name in the as rdfs:lable property of <doap:Version >
    - add following elements in the header too
    <owl:versionIRI rdf:resource="http://purl.obolibrary.org/obo/obi/2012-03-29/obi.owl"/>
    <owl:versionInfo rdf:datatype="http://www.w3.org/2001/XMLSchema#string">2012-03-29</owl:versionInfo> (2011-03-29 is the date of release, required by IIRC Bioportal)

cleaned_merged_obi_woIEDB_mod.owl


13. Add comments to the merged owl file

copy file cleaned_merged_obi.owl to /home/jiezheng/release/


# Start lisp in linux system
~/obi/svn-lsw/trunk/bin/lsw --load ~/obi/load-obi.lisp

# add comment lisp
(comment-ids-in-owl-file "/home/jiezheng/release/cleaned_merged_obi_woIEDB_mod.owl" "/home/jiezheng/release/merged-obi-comments.owl" (load-kb-jena "/home/jiezheng/release/cleaned_merged_obi_woIEDB_mod.owl")) 

merged-obi-comments.owl


Finalize release
-------------------------------------------------------------------------
- Send email for developers to review

- Prepare release notes, use previous release notes as template, contain following information
	a. New to this release - collected from OBI developers
	b. Count of terms in and used by OBI
	c. get new classes for this release
		check assigned ID tab files committed under docs directory
	d. Generate a list of new classes with links in HTML format using perl script: generateMappingHTML.pl under obi\src\tools\

	Link to Release notes page: http://obi-ontology.org/page/Releases/2012-03-29

- upload merged with comment obi owl file to purl and bioportal

- send email to inform the potential users

