#!/bin/sh

#starting configuration: create a directory containing the OBIrelease.sh script (e.g. obireleases)


######################################################## CHECKOUT THE TOOLS ###############################################
#you need to have the OBITools.jar in your classpath and to download lsw
# let's get them from SVN and manage that for you


#get lsw
svn co http://mumble.net:8080/svn/lsw/ ./svn-lsw/
#get OBITools.jar
svn co https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/OBITools 
#get binaries
svn co https://obi.svn.sourceforge.net/svnroot/obi/trunk/bin


#######################################################################################################################################

############################################################## BASIC SETUP ########################################################




#the file where to write the merge
NEWFILEPATH="UncheckedMerge.owl"
#the file where to write the merge protege-friendly
NEWFILEPATHPROTEGE="UncheckedMergePROTEGE.owl"
#the path to this directory
HERE=`pwd`
#the path to the LSW directory
LSW_PATH=$HERE/svn-lsw/


#set up the classpath for the jar 
export CLASSPATH=$HERE:$HERE/OBITools/OBITools.jar
echo $CLASSPATH

#we create a directory for this release - its name is the date
CUR_DATE=`date +%Y%m%d`
mkdir $CUR_DATE

#let's go there and do some work!
cd $CUR_DATE

############################################################# create the structure for the files

#the path to the branch files
OBI_DIR_PATH=`pwd`/src/ontology/branches/
echo "OBI DIR PATH is set to" $OBI_DIR_PATH 

#the path to the external files (bfo etc)
EXTERNAL_DIR_PATH=`pwd`/src/ontology/external/
echo "EXTERNAL DIR PATH is set to" $EXTERNAL_DIR_PATH 

#the path to the tools
OBI_TOOLS_PATH=`pwd`/src/tools/
echo "OBI TOOLS PATH is set to" $OBI_TOOLS_PATH 

#the path to the code
OBI_CODE_PATH=`pwd`/src/tools/build/
echo "OBI CODE PATH is set to" $OBI_CODE_PATH 

#the path to the build directory: will contain new branch files
OBI_BUILD_PATH=`pwd`/build/
echo "OBI BUILD PATH is set to" $OBI_BUILD_PATH 
#create the build directory 
mkdir $OBI_BUILD_PATH

#the path to the merged directory: will contain release files (merge, doc...)
OBI_MERGED_PATH=`pwd`/merged/
mkdir $OBI_MERGED_PATH
echo "OBI_MERGED_PATH is set to" $OBI_MERGED_PATH 

#the path to the subdirectory of the merged directory that will contain the protege specific files
OBI_MERGED_PATH_PROTEGE=`pwd`/merged/protege
mkdir $OBI_MERGED_PATH_PROTEGE
echo "OBI_MERGED_PATH_PROTEGE is set to" $OBI_MERGED_PATH_PROTEGE 

# we do a fresh svn checkout
# we need only the branches and external files
# we are not taking spreadsheets and others
svn co  https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/branches/ ./src/ontology/branches
svn co  https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/external/ ./src/ontology/external
# we need the sourcecodes as well 
svn co  https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/ ./src/tools/build
echo "SVN checked out"


#javac the client
javac $OBI_CODE_PATH/OBIReleaseClient.java 
echo "java client compiled"





#we need to copy obi.owl.template to obi.owl
#needed by modify-uris.pl
cp $OBI_DIR_PATH/obi.owl.template $OBI_DIR_PATH/obi.owl
echo "obi.owl.template copied to obi.owl"


echo "<?xml version=\"1.0\"?>
<rdf:RDF
    xmlns=\"http://purl.obofoundry.org/obo/\"
    xmlns:protege=\"http://protege.stanford.edu/plugins/owl/protege#\"
    xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"
    xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
    xmlns:owl=\"http://www.w3.org/2002/07/owl#\"
    xml:base=\"file://$OBI_DIR_PATH/\">
  <owl:Ontology rdf:about=\"http://purl.obofoundry.org/obo/\">
    <owl:imports rdf:resource=\"AnnotationProperty.owl\"/>
    <owl:imports rdf:resource=\"DataTransformation.owl\"/>
    <owl:imports rdf:resource=\"DigitalEntityPlus.owl\"/>
    <owl:imports rdf:resource=\"Biomaterial.owl\"/>
    <owl:imports rdf:resource=\"DataFormatSpecification.owl\"/>
    <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/bfo11.owl\"/>
    <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/ro.owl\"/>
    <protege:defaultLanguage rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">en</protege:defaultLanguage>
    <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/ro_bfo_bridge11.owl\"/>
    <owl:imports rdf:resource=\"Role.owl\"/>
    <owl:imports rdf:resource=\"InstrumentAndPart.owl\"/>
    <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/protege.owl\"/>
    <owl:imports rdf:resource=\"PlanAndPlannedProcess.owl\"/>
    <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/protege-dc.owl\"/>
    <owl:imports rdf:resource=\"TheRest.owl\"/>
    <owl:imports rdf:resource=\"Relations.owl\"/>
    <owl:imports rdf:resource=\"OBI-Function.owl\"/>
    <owl:imports rdf:resource=\"Quality.owl\"/>
    <owl:imports rdf:resource=\"external.owl\"/>
    <owl:imports rdf:resource=\"externalDerived.owl\"/>
    <owl:imports rdf:resource=\"Obsolete.owl\"/>
  </owl:Ontology>
</rdf:RDF>" > ./src/ontology/branches/obil.owl

echo "obil.owl created"

#we need the initial obi branches to modify their URIs and IDs
OBI_OWL_PATH=${OBI_DIR_PATH}/obil.owl


###################################################################################################################################


############################################################### URI-REPORT #########################################################

#the following command launch abcl, load the necessary lisp scripts, and execute the function to produce the uri-report.txt file
perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load ${OBI_CODE_PATH}/uri-report.lisp --load owl/standard-ontologies.lisp --eval "(list-obi-uris \"${OBI_BUILD_PATH}/uri-report.txt\" (load-kb-jena \"${OBI_OWL_PATH}\"))" --eval "(quit)"

echo "uri-report.txt created"

echo `pwd`

perl  ./src/tools/build/modify-uris.pl



################################################## OPTIONAL - NEWIDS CHECK #######################################################

#files needed to open the newids files in protege
#not required -but I like checking that the files I will commit will be ok for others
cp $OBI_DIR_PATH/obi.owl $OBI_BUILD_PATH/newids/obi.owl
cp $OBI_DIR_PATH/obi.repository.template $OBI_BUILD_PATH/newids/obi.repository
mkdir $OBI_BUILD_PATH/external/
echo "created $OBI_CODE_PATH/external/ directory"
cp  $EXTERNAL_DIR_PATH/* $OBI_BUILD_PATH/external/
echo "CHECKPOINT: you can check in Protege the newly created files: open $OBI_BUILD_PATH/newids/obi.owl"
#at this point you should be able to open $OBI_BUILD_PATH/newids/obi.owl in protege (if you are under *nix system - otherwise you need the obi.repository.template.pc file and to modify it)
###################################################################################################################################


################################################## DATE AND REVISION NUMBER #######################################################
#note: we need to replace the date in TheRest.owl to do so, or we will get a consistency error from the reasoner

#we replace the date and the version number in TheRest.owl
TODAY=`date "+%G-%m-%d"`

perl -pi -e "s/<dc:date rdf:datatype=\"http:\/\/www.w3.org\/2001\/XMLSchema#date\">(.*)<\/dc:date>/<dc:date rdf:datatype=\"http:\/\/www.w3.org\/2001\/XMLSchema#date\">$TODAY<\/dc:date>/" $OBI_BUILD_PATH/newids/TheRest.owl
echo "date replaced in $OBI_BUILD_PATH/newids/TheRest.owl"

############################################## ugly path hack - for whatever reason the get-revision-number.sh script doesn't like to be called at the root (maybe some problem with external...?)
cd $OBI_CODE_PATH
SVN_REVISION_NUMBER=`./get-svn-revision.sh`
echo "got SVN revision number" $SVN_REVISION_NUMBER
cd $HERE

perl -pi -e "s/<owl:versionInfo xml:lang=\"en\">(.*)<\/owl:versionInfo>/<owl:versionInfo xml:lang=\"en\">1.0.$SVN_REVISION_NUMBER<\/owl:versionInfo>/" $OBI_BUILD_PATH/newids/TheRest.owl
echo "revision number replaced in $OBI_BUILD_PATH/newids/TheRest.owl"
###################################################################################################################################


########################################################## DISJOINTS, PURLS AND INFERRED SUPERCLASSES ###############################################################
echo "<?xml version=\"1.0\"?>
<rdf:RDF
    xmlns=\"http://purl.obofoundry.org/obo/\"
    xmlns:protege=\"http://protege.stanford.edu/plugins/owl/protege#\"
    xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"
    xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
    xmlns:owl=\"http://www.w3.org/2002/07/owl#\"
    xml:base=\"file://$OBI_BUILD_PATH/newids/\">
  <owl:Ontology rdf:about=\"http://purl.obofoundry.org/obo/\">
     <owl:imports rdf:resource=\"AnnotationProperty.owl\"/>
     <owl:imports rdf:resource=\"DataTransformation.owl\"/>
    <owl:imports rdf:resource=\"DigitalEntityPlus.owl\"/>
     <owl:imports rdf:resource=\"Biomaterial.owl\"/>
     <owl:imports rdf:resource=\"DataFormatSpecification.owl\"/>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/bfo11.owl\"/>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/ro.owl\"/>
    <protege:defaultLanguage rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">en</protege:defaultLanguage>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/ro_bfo_bridge11.owl\"/>
    <owl:imports rdf:resource=\"Role.owl\"/>
     <owl:imports rdf:resource=\"InstrumentAndPart.owl\"/>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/protege.owl\"/>
     <owl:imports rdf:resource=\"PlanAndPlannedProcess.owl\"/>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/protege-dc.owl\"/>
     <owl:imports rdf:resource=\"TheRest.owl\"/>
     <owl:imports rdf:resource=\"Relations.owl\"/>
     <owl:imports rdf:resource=\"OBI-Function.owl\"/>
     <owl:imports rdf:resource=\"Quality.owl\"/>
     <owl:imports rdf:resource=\"external.owl\"/>
     <owl:imports rdf:resource=\"externalDerived.owl\"/>
     <owl:imports rdf:resource=\"Obsolete.owl\"/>
  </owl:Ontology>
</rdf:RDF>" > $OBI_BUILD_PATH/newids/obil.owl

OBI_OWL_PATH_NEW=$OBI_BUILD_PATH/newids/obil.owl
echo "new OWL path set to " $OBI_OWL_PATH_NEW





#the following command launches abcl, load the necessary lisp scripts, and execute the function to produce the disjoints.owl file
perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load ${OBI_CODE_PATH}/add-disjoints.lisp --load ${OBI_CODE_PATH}/write-purls.lisp --load ${OBI_CODE_PATH}/add-inferred-superclasses.lisp --load owl/standard-ontologies.lisp --eval "(write-disjoints (load-kb-jena \"${OBI_OWL_PATH_NEW}\") \"${OBI_BUILD_PATH}/newids/disjoints.owl\")" --eval "(write-purls (load-kb-jena \"${OBI_OWL_PATH_NEW}\") (load-kb-jena \"http://purl.obofoundry.org/obo/obi.owl\") \"${OBI_BUILD_PATH}/list-purls.xml\")"  --eval "(write-inferred-superclasses (load-kb-jena \"${OBI_BUILD_PATH}/newids/obid.owl\") \"${OBI_BUILD_PATH}/newids/inferred-superclasses.owl\")" --eval "(quit)"


echo "disjoints.owl created at $OBI_BUILD_PATH/newids/disjoints.owl"
echo "list-purls created at $OBI_BUILD_PATH/list-purls.xml"
echo "inferred-superclasses.owl created at $OBI_BUILD_PATH/newids/inferred-superclasses.owl"



############################################################### QC-QUERIES #########################################################
# preforms some check on the file
# currently:
# --- is there any rdfs:Class (instead of owl:Class)
# --- list of terms missing a curation status instance
# --- list of terms with extra curation instance (only one allowed per term)
# --- list of (OBI) terms with non OBI IDs
# --- list of terms missing a label
# --- list of classes that are asserted under a defined class
# writes the result of the queries in the merged directory, in the file qc-queries-report.txt
# TODO: add lost-terms (as soon as I understand the arguments ;-) )

perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load ${OBI_CODE_PATH}/qc-queries.lisp --load owl/standard-ontologies.lisp --eval "(rdfs-class-report (load-kb-jena \"${OBI_OWL_PATH_NEW}\"))"  --eval "(missing-curation (load-kb-jena \"${OBI_OWL_PATH_NEW}\"))" --eval "(extra-curation-status-instances (load-kb-jena \"${OBI_OWL_PATH_NEW}\"))" --eval "(untranslated-uris (load-kb-jena \"${OBI_OWL_PATH_NEW}\"))" --eval "(missing-label (load-kb-jena \"${OBI_OWL_PATH_NEW}\"))" --eval "(asserted-subclass-of-defined-class (load-kb-jena \"${OBI_OWL_PATH_NEW}\"))" --eval "(quit)" > $OBI_MERGED_PATH/qc-queries-report.txt

###################################################################################################################################



###################################################################################################################################
##### we need to create the new obid.owl which will include inferred-superclasses.owl
##### we can't create it before as inferred-superclasses don't exist yet

echo "<?xml version=\"1.0\"?>
<rdf:RDF
    xmlns=\"http://purl.obofoundry.org/obo/\"
    xmlns:protege=\"http://protege.stanford.edu/plugins/owl/protege#\"
    xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"
    xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
    xmlns:owl=\"http://www.w3.org/2002/07/owl#\"
    xml:base=\"file://$OBI_BUILD_PATH/newids/\">
  <owl:Ontology rdf:about=\"http://purl.obofoundry.org/obo/\">
     <owl:imports rdf:resource=\"AnnotationProperty.owl\"/>
     <owl:imports rdf:resource=\"DataTransformation.owl\"/>
    <owl:imports rdf:resource=\"DigitalEntityPlus.owl\"/>
     <owl:imports rdf:resource=\"Biomaterial.owl\"/>
     <owl:imports rdf:resource=\"DataFormatSpecification.owl\"/>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/bfo11.owl\"/>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/ro.owl\"/>
    <protege:defaultLanguage rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">en</protege:defaultLanguage>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/ro_bfo_bridge11.owl\"/>
    <owl:imports rdf:resource=\"Role.owl\"/>
     <owl:imports rdf:resource=\"InstrumentAndPart.owl\"/>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/protege.owl\"/>
     <owl:imports rdf:resource=\"PlanAndPlannedProcess.owl\"/>
     <owl:imports rdf:resource=\"$EXTERNAL_DIR_PATH/protege-dc.owl\"/>
     <owl:imports rdf:resource=\"TheRest.owl\"/>
     <owl:imports rdf:resource=\"Relations.owl\"/>
     <owl:imports rdf:resource=\"OBI-Function.owl\"/>
     <owl:imports rdf:resource=\"Quality.owl\"/>
     <owl:imports rdf:resource=\"external.owl\"/>
     <owl:imports rdf:resource=\"externalDerived.owl\"/>
     <owl:imports rdf:resource=\"Obsolete.owl\"/>
  <owl:imports rdf:resource=\"disjoints.owl\"/>
 <owl:imports rdf:resource=\"inferred-superclasses.owl\"/>
  </owl:Ontology>
</rdf:RDF>" > $OBI_BUILD_PATH/newids/obid.owl

echo "obid.owl created (includes disjoints and inferred superclasses)"


echo "CHECKPOINT: you can check in Protege the newly created files: open $OBI_BUILD_PATH/newids/obid.owl to see the inferred hierarchy including disjoints"

########################################################## LSW ONTOLOGY REPORT ###############################################################
#################### kept separated from other lisp calls as it is quite long and I often comment it out for testing :-) ) ###################

perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load owl/standard-ontologies.lisp --eval "(write-ontology-report (load-kb-jena \"${OBI_BUILD_PATH}/newids/obid.owl\") :fname \"${OBI_BUILD_PATH}/obi-lsw-report.html\")" --eval "(quit)"

echo "html report created at $OBI_BUILD_PATH/obi-lsw-report.html"

###################################################################################################################################


########################################################## SVN logs ###############################################################
######### we are interested only in the logs of the branch files, nothing else 
cd $OBI_DIR_PATH
svn log > $OBI_MERGED_PATH/SVNlogs.txt
echo "SVN logs created at $OBI_MERGED_PATH/SVNlogs.txt "
cd $HERE
####################







###################################################################################################################################
#                                     ALL FILES READY AND MODIFIED FOR MERGE AT THIS POINT                                        #
###################################################################################################################################
#everything is ready - let's merge
# run the java script
# the arguments are first the path to the new file to be created
# and second the physical location of the OBI files to be merged.

# we go back to the parent directory
cd $HERE


 cp $OBI_CODE_PATH/OBIReleaseClient.class .





#launch the merger itself
#the jar needs to be in your classpath
RESULT=`java OBIReleaseClient $NEWFILEPATH $NEWFILEPATHPROTEGE $OBI_BUILD_PATH/newids/`

# print out the result
echo "result is $RESULT"

# everything is ok, files are merged and consistency is good
if [ "$RESULT" == "true" ]
then
        echo "ok to commit"
	rm $OBI_MERGED_PATH/OBI.owl
	echo "$OBI_MERGED_PATH/OBI.owl deleted"

	rm $OBI_MERGED_PATH_PROTEGE/OBI-ProtegeFriendly.owl
	echo "$OBI_MERGED_PATH_PROTEGE/OBI-ProtegeFriendly.owl deleted"

	rm $OBI_MERGED_PATH/md5.txt
	echo "$OBI_MERGED_PATH/md5.txt deleted"

        cp $NEWFILEPATH $OBI_MERGED_PATH/OBI-nocomment.owl
	echo "$OBI_MERGED_PATH/OBI.owl created"


#add comments
perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load owl/standard-ontologies.lisp --load ${OBI_CODE_PATH}/comment-ids-in-owl-file.lisp --eval "(comment-ids-in-owl-file \"${OBI_MERGED_PATH}/OBI-nocomment.owl\" \"${OBI_MERGED_PATH}/OBI.owl\" (load-kb-jena \"${OBI_MERGED_PATH}/OBI-nocomment.owl\"))" --eval "(quit)"

echo "OBI.owl now includes xml comments"


        md5 $OBI_MERGED_PATH/OBI.owl >> $OBI_MERGED_PATH/md5.txt
	echo "$OBI_MERGED_PATH/md5.txt created"

        cp $NEWFILEPATHPROTEGE $OBI_MERGED_PATH_PROTEGE/OBI-ProtegeFriendly.owl
	echo "$OBI_MERGED_PATH_PROTEGE/OBI-ProtegeFriendly.owl created"
        
        cp $OBI_BUILD_PATH/list-purls.xml $OBI_MERGED_PATH/list-purls.xml
	echo "list-purls copied to $OBI_MERGED_PATH "
	rm $OBI_BUILD_PATH/list-purls.xml
	cp $OBI_BUILD_PATH/obi-lsw-report.html $OBI_MERGED_PATH/obi-lsw-report.html 
	echo "obi-lsw-report copied to $OBI_MERGED_PATH"
	rm $OBI_BUILD_PATH/obi-lsw-report.html

	#the merge went through - we should commit the newids files at this point
exit 1
fi

# there has been a problem and we don't commit
if [ "$RESULT" == "false" ]
then
        echo "bouhouhouhouhou"
exit 1
fi

########################################################   TODO    #############################################################

## #  qc-queries: TODO: add lost-terms (as soon as I understand the arguments ;-) )
## #  replace repetitive calls to lisp with perl obi-lisp-eval (as soon as I manage with the paths ;-) )

###################################################################################################################################



