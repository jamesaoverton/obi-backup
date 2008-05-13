

#!/bin/sh

#starting configuration: create a directory containing the OBIrelease.sh script (e.g. obireleases)


######################################################## VARIABLES YOU NEED TO MODIFY ###############################################
#you need to have the OBITools.jar in your classpath and to download lsw
# let's get them from SVN and manage that for you


#get lsw
svn co http://mumble.net:8080/svn/lsw/ ./svn-lsw/
#get OBITools.jar
svn co https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/OBITools 


#######################################################################################################################################

############################################################## BASIC SETUP ########################################################




#the file where to write the merge
NEWFILEPATH="UncheckedMerge.owl"
#the file where to write the merge protege-friendly
NEWFILEPATHPROTEGE="UncheckedMergePROTEGE.owl"
#the path to your install of lsw
HERE=`pwd`
LSW_PATH=$HERE/svn-lsw/



export CLASSPATH=$HERE:$HERE/OBITools/OBITools.jar
echo $CLASSPATH

#we create a directory for this release - its name is the date
CUR_DATE=`date +%Y%m%d`
mkdir $CUR_DATE

#let's go there
cd $CUR_DATE

OBI_DIR_PATH=`pwd`/src/ontology/branches/
echo "OBI DIR PATH is set to" $OBI_DIR_PATH 

EXTERNAL_DIR_PATH=`pwd`/src/ontology/external/
echo "EXTERNAL DIR PATH is set to" $EXTERNAL_DIR_PATH 

OBI_TOOLS_PATH=`pwd`/src/tools/
echo "OBI TOOLS PATH is set to" $OBI_TOOLS_PATH 

OBI_CODE_PATH=`pwd`/src/tools/build/
echo "OBI CODE PATH is set to" $OBI_CODE_PATH 

OBI_BUILD_PATH=`pwd`/build/
echo "OBI BUILD PATH is set to" $OBI_BUILD_PATH 

mkdir $OBI_BUILD_PATH


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
    <owl:imports> <owl:Ontology  rdf:about=\"AnnotationProperty.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DataTransformation.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DigitalEntityPlus.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Biomaterial.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DataFormatSpecification.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/bfo11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/ro.owl\"/></owl:imports>
    <protege:defaultLanguage rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">en</protege:defaultLanguage>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/ro_bfo_bridge11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Role.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"InstrumentAndPart.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/protege.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"PlanAndPlannedProcess.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/protege-dc.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"TheRest.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Relations.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"OBI-Function.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Quality.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"external.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"externalDerived.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Obsolete.owl\"/></owl:imports>
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

############################################## ugly path hack - for whatever reason the get-revision-number.sh script doesn't like to be called at the root (maybe some problem with the size of svn...?)
cd $OBI_CODE_PATH
SVN_REVISION_NUMBER=`./get-svn-revision.sh`
echo "got SVN revision number" $SVN_REVISION_NUMBER
cd $HERE

perl -pi -e "s/<owl:versionInfo xml:lang=\"en\">(.*)<\/owl:versionInfo>/<owl:versionInfo xml:lang=\"en\">1.0.$SVN_REVISION_NUMBER<\/owl:versionInfo>/" $OBI_BUILD_PATH/newids/TheRest.owl
echo "revision number replaced in $OBI_BUILD_PATH/newids/TheRest.owl"
###################################################################################################################################


########################################################## DISJOINTS ###############################################################
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
    <owl:imports> <owl:Ontology  rdf:about=\"AnnotationProperty.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DataTransformation.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DigitalEntityPlus.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Biomaterial.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DataFormatSpecification.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/bfo11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/ro.owl\"/></owl:imports>
    <protege:defaultLanguage rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">en</protege:defaultLanguage>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/ro_bfo_bridge11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Role.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"InstrumentAndPart.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/protege.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"PlanAndPlannedProcess.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/protege-dc.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"TheRest.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Relations.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"OBI-Function.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Quality.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"external.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"externalDerived.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Obsolete.owl\"/></owl:imports>
  </owl:Ontology>
</rdf:RDF>" > $OBI_BUILD_PATH/newids/obil.owl

OBI_OWL_PATH_NEW=$OBI_BUILD_PATH/newids/obil.owl
echo "new OWL path set to " $OBI_OWL_PATH_NEW

#the following command launch abcl, load the necessary lisp scripts, and execute the function to produce the disjoints.owl file
perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load ${OBI_CODE_PATH}/add-disjoints.lisp --load owl/standard-ontologies.lisp --eval "(write-disjoints (load-kb-jena \"${OBI_OWL_PATH_NEW}\") \"${OBI_BUILD_PATH}/newids/disjoints.owl\")" --eval "(quit)"

echo "disjoints.owl created at $OBI_BUILD_PATH/newids/disjoints.owl"
###################################################################################################################################


########################################################## PURLS ###############################################################


perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load ${OBI_CODE_PATH}/write-purls.lisp --load owl/standard-ontologies.lisp --eval "(write-purls (load-kb-jena \"${OBI_OWL_PATH_NEW}\") (load-kb-jena \"http://purl.obofoundry.org/obo/obi.owl\") \"${OBI_BUILD_PATH}/list-purls.xml\")" --eval "(quit)"

echo "list-purls created at $OBI_BUILD_PATH/list-purls.xml"

###################################################################################################################################

########################################################## LSW ONTOLOGY REPORT ###############################################################


perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load owl/standard-ontologies.lisp --eval "(write-ontology-report (load-kb-jena \"${OBI_BUILD_PATH}/newids/obid.owl\") :fname \"${OBI_BUILD_PATH}/obi-lsw-report.html\")" --eval "(quit)"

echo "html report created at $OBI_BUILD_PATH/obi-lsw-report.html"

###################################################################################################################################


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
        cp $NEWFILEPATH ./OBI.owl
        md5sum ./OBI.owl >> md5.txt
        cp $NEWFILEPATHPROTEGE ./OBI-ProtegeFriendly.owl
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
## generate purls
## play with qc-queries

###################################################################################################################################



