

#!/bin/sh

#starting configuration: create a directory containing the compiled OBIReleaseClient.java (might be worth getting from SVN or adding a javac OBIReleaseClient.java) and the OBIrelease.sh script



######################################################## VARIABLES YOU NEED TO MODIFY ###############################################
#you need to have the OBITools.jar in your classpath and to download lsw
#TODO try and get them directly from SVN 

#the file where to write the merge
NEWFILEPATH="UncheckedMerge.owl"
#the file where to write the merge protege-friendly
NEWFILEPATHPROTEGE="UncheckedMergePROTEGE.owl"
#the path to your install of lsw
HERE=`pwd`
LSW_PATH=$HERE/svn-lsw/lsw

#get lsw
svn co http://mumble.net:8080/svn/lsw/ ./svn-lsw/
#get OBITools.jar
svn co https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/OBITools 
export CLASSPATH=$CLASSPATH:./OBITools/OBITools.jar
4. javac OBIReleaseClient.java
#######################################################################################################################################

############################################################## BASIC SETUP ########################################################


#we create a directory for this release - its name is the date
CUR_DATE=`date +%Y%m%d`
mkdir $CUR_DATE

#let's go there
cd $CUR_DATE
# we do a fresh svn checkout
svn co  https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/branches .
# we need the sourcecodes as well - these have been moved during SVN re organization
svn co  https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/ ./sourcecodes

#javac the client
javac ./sourcecodes/OBIReleaseClient.java
# we need the external files as well - these have been moved during SVN re organization
svn co  https://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/external ./external


#we need to copy obi.owl.template to obi.owl
#needed by modify-uris.pl
cp ./obi.owl.template ./obi.owl

############################################################### OBIL.OWL #########################################################
#we define the path to the ontology (local copy) for lisp to use
#basic building of an obil.owl file - could probably be moved somewhere else :-)

OBI_DIR_PATH=`pwd`


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
    <owl:imports> <owl:Ontology  rdf:about=\"./external/bfo11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/ro.owl\"/></owl:imports>
    <protege:defaultLanguage rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">en</protege:defaultLanguage>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/ro_bfo_bridge11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Role.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"InstrumentAndPart.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/protege.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"PlanAndPlannedProcess.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/protege-dc.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"TheRest.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Relations.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"OBI-Function.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Quality.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"external.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"externalDerived.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Obsolete.owl\"/></owl:imports>
  </owl:Ontology>
</rdf:RDF>" > ./obil.owl

#we need the initial obi branches to modify their URIs and IDs
OBI_OWL_PATH=${OBI_DIR_PATH}/obil.owl




###################################################################################################################################

############################################################### URI-REPORT #########################################################

#the following command launch abcl, load the necessary lisp scripts, and execute the function to produce the uri-report.txt file
perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load ${OBI_DIR_PATH}/sourcecodes/uri-report.lisp --load owl/standard-ontologies.lisp --eval "(list-obi-uris \"${OBI_DIR_PATH}/uri-report.txt\" (load-kb-jena \"${OBI_OWL_PATH}\"))" --eval "(quit)"


#we create the directory that will host the modified branch files
mkdir newids
#the modify-uris perl script will normalize OBI IDS, update curation_status strings to instances
#and write the result in the newids directory created above
perl ./sourcecodes/modify-uris.pl

###################################################################################################################################

################################################## OPTIONAL - NEWIDS CHECK #######################################################

#files needed to open the newids files in protege
#not required -but I like checking that the files I will commit will be ok for others
cp ./obi.owl ./newids/obi.owl
cp ./obi.repository.template ./newids/obi.repository
cp -R ./external ./newids/external
#cp -R ./bfo ./newids/bfo
#at this point you should be able to open $CUR_DATE/newids/obi.owl in protege (if you are under *nix system - otherwise you need the obi.repository.template.pc file and to modify it)
###################################################################################################################################

################################################## DATE AND REVISION NUMBER #######################################################
#note: we need to replace the date in TheRest.owl to do so, or we will get a consistency error from the reasoner

#we replace the date and the version number in TheRest.owl
TODAY=`date "+%G-%m-%d"`

perl -pi -e "s/<dc:date rdf:datatype=\"http:\/\/www.w3.org\/2001\/XMLSchema#date\">(.*)<\/dc:date>/<dc:date rdf:datatype=\"http:\/\/www.w3.org\/2001\/XMLSchema#date\">$TODAY<\/dc:date>/" TheRest.owl

SVN_REVISION_NUMBER=`./sourcecodes/get-svn-revision.sh`

perl -pi -e "s/<owl:versionInfo xml:lang=\"en\">(.*)<\/owl:versionInfo>/<owl:versionInfo xml:lang=\"en\">1.0.$SVN_REVISION_NUMBER<\/owl:versionInfo>/" TheRest.owl

###################################################################################################################################

########################################################### CHECKS ###############################################################
#we now want to load qc-queries.lisp and perform a few checks on the files


########################################################## DISJOINTS ###############################################################
#finally, we create the disjoints.owl file
#we want to create the disjoints on the newids files (otherwise we'll get old ids in there)

echo "<?xml version=\"1.0\"?>
<rdf:RDF
    xmlns=\"http://purl.obofoundry.org/obo/\"
    xmlns:protege=\"http://protege.stanford.edu/plugins/owl/protege#\"
    xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"
    xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
    xmlns:owl=\"http://www.w3.org/2002/07/owl#\"
    xml:base=\"file://$OBI_DIR_PATH/newids/\">
  <owl:Ontology rdf:about=\"http://purl.obofoundry.org/obo/\">
    <owl:imports> <owl:Ontology  rdf:about=\"AnnotationProperty.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DataTransformation.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DigitalEntityPlus.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Biomaterial.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"DataFormatSpecification.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/bfo11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/ro.owl\"/></owl:imports>
    <protege:defaultLanguage rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">en</protege:defaultLanguage>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/ro_bfo_bridge11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Role.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"InstrumentAndPart.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/protege.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"PlanAndPlannedProcess.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"./external/protege-dc.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"TheRest.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Relations.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"OBI-Function.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Quality.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"external.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"externalDerived.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"Obsolete.owl\"/></owl:imports>
  </owl:Ontology>
</rdf:RDF>" > $OBI_DIR_PATH/newids/obil.owl

OBI_OWL_PATH_NEW=${OBI_DIR_PATH}/newids/obil.owl

#the following command launch abcl, load the necessary lisp scripts, and execute the function to produce the disjoints.owl file
perl ${LSW_PATH}/trunk/abcl $*  --load scripts/lsw-startup.lisp --load ${OBI_DIR_PATH}/sourcecodes/add-disjoints.lisp --load owl/standard-ontologies.lisp --eval "(write-disjoints (load-kb-jena \"${OBI_OWL_PATH_NEW}\") \"${OBI_DIR_PATH}/newids/disjoints.owl\")" --eval "(quit)"

###################################################################################################################################

###################################################################################################################################
#                                     ALL FILES READY AND MODIFIED FOR MERGE AT THIS POINT                                        #
###################################################################################################################################
#everything is ready - let's merge
# run the java script
# the arguments are first the path to the new file to be created
# and second the physical location of the OBI files to be merged.

# we go back to the parent directory
cd ..


#launch the merger itself
#the jar needs to be in your classpath
RESULT=`java OBIReleaseClient $NEWFILEPATH $NEWFILEPATHPROTEGE $CUR_DATE/newids/`

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

#TODO: generate purls



