#!/bin/sh

#######################################################################################################################################

######################################################## CHECKOUT #####################################################################
# let's get all needed files for release from SVN
#
# In the release directory, 
#		check out 'lsw' under 'svn-lsw' // not do this now, the latest version did not work in my system
#		check out lisp source_codes under 'current_date/src/tools/build'
#		check out 'obi' related files under 'current_date/src/ontology', need both the branches and external files


# release directory
HERE=`pwd`

# check out OBI
##############################################################

# we create a directory for this release - its name is the date
CUR_DATE=`date +%Y%m%d`
mkdir $CUR_DATE
cd $CUR_DATE

# branches and external files
svn co  http://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/branches/ ./src/ontology/branches/
svn co  http://obi.svn.sourceforge.net/svnroot/obi/trunk/src/ontology/external/ ./src/ontology/external/

# source code files 
svn co  http://obi.svn.sourceforge.net/svnroot/obi/trunk/src/tools/build/ ./src/tools/build/

echo "SVN checked out"
#######################################################################################################################################





#######################################################################################################################################

############################################################## PATH SETUP #############################################################

# release/current_date directory
HERE=`pwd`


# path to the branch files
#############################################################
OBI_DIR_PATH=`pwd`/src/ontology/branches
echo "OBI DIR PATH is set to" $OBI_DIR_PATH 

# path to the external files (bfo etc)
#############################################################
EXTERNAL_DIR_PATH=`pwd`/src/ontology/external
echo "EXTERNAL DIR PATH is set to" $EXTERNAL_DIR_PATH 

#the path to the lisp/perl codes
#############################################################
OBI_CODE_PATH=`pwd`/src/tools/build
echo "OBI CODE PATH is set to" $OBI_CODE_PATH 

# create directory to store files for release and set path to it
#############################################################

OBI_BUILD_PATH=`pwd`/build
mkdir $OBI_BUILD_PATH
mkdir $OBI_BUILD_PATH/newids

echo "OBI BUILD PATH is set to" $OBI_BUILD_PATH

# create merged directory: will contain release files (merge, doc...) and set path to it
#############################################################
OBI_MERGED_PATH=`pwd`/merged
mkdir $OBI_MERGED_PATH

echo "OBI_MERGED_PATH is set to" $OBI_MERGED_PATH


############################################################ LSW PATH #####################
#the path to the LSW directory
####################################UPDATE THIS WITH THE LOCATION OF YOUR INSTALLATION ####################################
LSW_TRUNK_PATH=~/release/svn-lsw/trunk
LSW_PATH=${LSW_TRUNK_PATH}/abcl
LSW_STARTUP_PATH=${LSW_TRUNK_PATH}/scripts

# set the ABCL_WD variable based on the above
export ABCL_WD=~/release/svn-lsw/trunk
export ABCL_RAM=2048
#######################################################################################################################################





#######################################################################################################################################

########################################################### COPY OBI FILES ############################################################
# assign IDs to new added terms using separate process, copy the files to build directory

cp $OBI_DIR_PATH/*.template $OBI_BUILD_PATH/newids/
cp $OBI_DIR_PATH/*.owl $OBI_BUILD_PATH/newids/
cp $OBI_DIR_PATH/*.xml $OBI_BUILD_PATH/newids/
#######################################################################################################################################


##################################################### DATE AND REVISION NUMBER ########################################################
# replace the date and the version number in obi.owl

TODAY=`date "+%G-%m-%d"`

perl -pi -e "s/<dc:date rdf:datatype=\"http:\/\/www.w3.org\/2001\/XMLSchema#date\">(.*)<\/dc:date>/<dc:date rdf:datatype=\"http:\/\/www.w3.org\/2001\/XMLSchema#date\">$TODAY<\/dc:date>/" $OBI_BUILD_PATH/newids/obi.owl
echo "date replaced in $OBI_BUILD_PATH/newids/obi.owl $TODAY"

############################################## ugly path hack - for whatever reason the get-revision-number.sh script doesn't like to be called at the root (maybe some problem with external...?)
cd $OBI_CODE_PATH
SVN_REVISION_NUMBER=`./get-svn-revision.sh`
echo "got SVN revision number" $SVN_REVISION_NUMBER
cd $HERE

perl -pi -e "s/<owl:versionInfo xml:lang=\"en\">(.*)<\/owl:versionInfo>/<owl:versionInfo xml:lang=\"en\">1.0.$SVN_REVISION_NUMBER<\/owl:versionInfo>/" $OBI_BUILD_PATH/newids/obi.owl
echo "revision number replaced in $OBI_BUILD_PATH/newids/obi.owl"
#######################################################################################################################################






#######################################################################################################################################

################################## CREATE obil.owl for DISJOINTS and ASSUMED INDIVIDUALS #####################################
echo "<?xml version=\"1.0\"?>
<rdf:RDF
    xmlns=\"http://purl.obofoundry.org/obo/\"
    xmlns:protege=\"http://protege.stanford.edu/plugins/owl/protege#\"
    xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"
    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema#\"
    xmlns:rdfs=\"http://www.w3.org/2000/01/rdf-schema#\"
    xmlns:owl=\"http://www.w3.org/2002/07/owl#\"
    xml:base=\"file://$OBI_BUILD_PATH/newids/\">
  <owl:Ontology rdf:about=\"http://purl.obolibrary.org/obo/\">
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/bfo11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/ro.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/ro_bfo_bridge11.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/protege.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/protege-dc.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"obi.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"external.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"externalDerived.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"external-byhand.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/iao/IAO.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/iao/ontology-metadata.owl\"/></owl:imports>
    <owl:imports> <owl:Ontology  rdf:about=\"$EXTERNAL_DIR_PATH/iao/obsolete.owl\"/></owl:imports>    
    <protege:defaultLanguage rdf:datatype=\"http://www.w3.org/2001/XMLSchema#string\">en</protege:defaultLanguage>
  </owl:Ontology>
</rdf:RDF>" > $OBI_BUILD_PATH/newids/obil.owl


############################################################ DISJOINTS ################################################### 

OBI_OWL_PATH_NEW=$OBI_BUILD_PATH/newids/obil.owl
echo "new OWL path set to " $OBI_OWL_PATH_NEW

#the following command launches abcl, load the necessary lisp scripts, and execute the function to produce the disjoints.owl file
perl ${LSW_PATH} $*  --load ${LSW_STARTUP_PATH}/lsw-startup.lisp --load ${OBI_CODE_PATH}/obi.asd --eval "(asdf::oos 'asdf::load-op :obi)" --eval "(write-disjoints (load-kb-jena \"${OBI_OWL_PATH_NEW}\") \"${OBI_BUILD_PATH}/newids/disjoints.owl\")"  --eval "(quit)"
echo "disjoints.owl created at $OBI_BUILD_PATH/newids/disjoints.owl"
###################################################################################################################################





###################################################################################################################################
########################################################## SVN logs ###############################################################
######### we are interested only in the logs of the branch files, nothing else 
cd $OBI_DIR_PATH
svn log > $OBI_BUILD_PATH/SVNlogs.txt
echo "SVN logs created at $OBI_BUILD_PATH/SVNlogs.txt "