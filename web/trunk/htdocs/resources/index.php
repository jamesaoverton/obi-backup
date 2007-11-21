<?php
include ("../../include/util.inc");
?>

<html>

<head>
 <link rel="STYLESHEET" href="../style.css" type="text/css">
 <title>Resources</title>
</head>

<body bgcolor=#99CCFF>
<br>

<!-- MAIN BODY TABLE -->
<table bgcolor=#ffffff border=0 cellpadding=12 cellspacing=5 width=75% align=center class=grayShadeOne>


<tr> <!-- banner row -->
<?php
title();
?>
</tr> <!-- end banner row -->

<tr valign=top>

 <td> 

  <!-- menu -->
  <div class=medium align=left>&nbsp;
  <?php
  menu(resources);
  ?>
  </div>

  <hr noshade size=2>
  <!-- sub menu -->
  <table bgcolor=#ffff99 border=0 style="border-right: 1px lightgrey; border-bottom: 1px solid k=lightgrey;" cellpadding=3 align=right>
  <tr>
  <td>
  <div class=small align=right>On this page:<br>
  <a href="#development" class=menu>Get Involved</a>,
  <a href="#pubs" class=menu>Publications</a>,
  <a href="#workshop" class=menu>Workshop Docs</a>,
  <a href="#presentations" class=menu>OBI Presentations</a>,
  <a href="#links" class=menu>Links</a>
  </div>
  </td>
  </tr>
  </table>  


  <br><br><br>

  <div class=small>


  <a name=development><b>Get involved with OBI!</b></a>
  <br><br>
  The OBI project has a number of mailing lists that you may subscribe or post to. Please see the list below to determine
  which is best forum for your query or suggestion.
  <ul>
  <li>OBI Developers. <a href="https://lists.sourceforge.net/lists/listinfo/obi-devel">Subscribe</a> | Post to obi-devel
   at lists.sourceforge.net. This list covers announcements of conference calls, the agenda and minutes in case you miss
   a call, and general topics of interest for all communites involved in the project.</li>
    <li>OBI Relations Branch. <a href="https://lists.sourceforge.net/lists/listinfo/obi-relations">Subscribe</a> |
    <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/ListOfRelationships">View Wiki</a> | Post
    to obi-relations at lists.sourceforge.net. This list covers the properties and relationships used within OBI.</li>
    <li>OBI DENRIE Branch. <a href="https://lists.sourceforge.net/lists/listinfo/obi-denrie-branch">Subscribe</a> |
    <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/DigitalEntityTerms">View Wiki</a> | Post
     to obi-denrie-branch at lists.sourceforge.net. It is an OBI Branch concerned with identifying entities and relations
      to describe information entities that can be interpreted by a computer or documented and communicated.</li>
    <li>OBI Function Branch. <a href="https://lists.sourceforge.net/lists/listinfo/obi-function-branch">Subscribe</a> |
    <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/FunctionTerms">View Wiki</a> | Post to obi-function-branch
    at lists.sourceforge.net. The list covers functions, which are end-directed activities manifested by specific continuants. 
    Functions typically provide a description of how a variety of continuants inter-relate in a particular context.</li>
    <li>OBI Role Branch. <a href="https://lists.sourceforge.net/lists/listinfo/obi-role-branch">Subscribe</a> |
    <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/RoleTerms">View Wiki</a> | Post to obi-role-branch at
    lists.sourceforge.net. The list covers terms for role / reagent / reporter / variable identified by different
    communities.</li>
    <li>OBI Data Transformation Branch. <a href="https://lists.sourceforge.net/lists/listinfo/obi-datatrfm-branch">Subscribe</a> |
    <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/DataTransformation">View Wiki</a> | Post to obi-datatrfm-branch
    at lists.sourceforge.net. The branch is concerned with identifying entities and relations to describe methods which
    perform some processing, manipulation or transformation upon input data to produce a transformed view(s) of 
    biomedical data.</li>
    <li>OBI Protocol Application Branch. <a href="https://lists.sourceforge.net/lists/listinfo/obi-protocol-application-branch">Subscribe</a> |
    <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/ProtocolApplicationBranch">View Wiki</a> | Post to
    obi-protocol-application-branch at lists.sourceforge.net. The list covers topics related to the specifica application
    of experimental protocols.</li>
    <li>OBI Plan Branch. <a href="https://lists.sourceforge.net/lists/listinfo/obi-plan-branch">Subscribe</a> |
    <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/PlanBranch">View Wiki</a> | Post to obi-plan-branch at
    lists.sourceforge.net. The scope of the branch is to identify essential entities to describe the intent and
    organizing steps of realizable entities such as an investigation (study/experiment), protocol or algorithm</li>
    <li>OBI Instrument Branch. <a href="https://lists.sourceforge.net/lists/listinfo/obi-instrument-branch">Subscribe</a> |
    <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/InstrumentTerms">View Wiki</a> | Post to
    obi-instrument-branch at lists.sourceforge.net. The list covers all instruments that fall within the scope of
    OBI.</li>
    <li>OBI Web Support. <a href="https://lists.sourceforge.net/lists/listinfo/obi-web-support">Subscribe</a> | Post to
    obi-web-support at lists.sourceforge.net. The list covers any questions that users may have about either the
    static web pages hosted on SourceForge, or the wiki pages.</li>
  </ul>
  <br>
  <hr class=lightgray>
  <br>

  <a name="pubs"><b>OBI Consortium Publications</b></a>
    <ul>
    <li><a href="http://www.nature.com/nbt/journal/v25/n11/full/nbt1346.html"> Nat Biotechnol. 2007 Nov;25(11):1251-1255.</a>
    "The OBO Foundry: coordinated evolution of ontologies to support biomedical data integration", Smith B, Ashburner
    M, Rosse C, Bard J, Bug W, Ceusters W, Goldberg LJ, Eilbeck K, Ireland A, Mungall CJ, The OBI Consortium,
    Leontis N, Rocca-Serra P, Ruttenberg A, Sansone SA, Scheuermann RH, Shah N, Whetzel PL, Lewis S.</li>
    </ul>
  
  <br>
  <hr class=lightgray>
  <br>

  <a name=workshop><b>OBI (formerly FuGO) Workshop Documents</b></a>
  <ul>
  <li><a href="http://sourceforge.net/project/showfiles.php?group_id=177891&package_id=209476&release_id=458979">1st Workshop (February 2006; Philadelphia, PA)</a>
  <li><a href="http://sourceforge.net/project/showfiles.php?group_id=177891&package_id=209476&release_id=458978">2nd Workshop (July 2006; Hinxton, UK)</a>
  <li><a href="http://sourceforge.net/project/showfiles.php?group_id=177891&package_id=209476&release_id=485800">3rd Workshop (February 2007; San Diego, CA)</a> 
  </ul>
  <br>
  <hr class=lightgray>
  <br>
  

  <a name=presentations><b>Posters, presentations and talks on OBI/FuGO</b></a>
  <br>

  <ul>
  <li><b>2006</b>
  <br><br>
  <b>April 21-23</b>
 
  <br>

  <a href="http://psidev.sourceforge.net/meetings/2006-04">HUPO PSI Spring Workshop</a>
  <br>  
  <ul type=circle>
  <li>Presentation: <a href="./presentations/PSI-Spring-2006_FuGO.ppt">FuGO Overview and Community Work Towards FuGO</a>
  <br> 
  This set of slides were presented at the PSI Spring Workshop as an introduction to FuGO and to show 
  how various communities are helping to develop FuGO.<br>
  </ul> 
  
  <br>

  <b>Jan 25-26th</b>
  <br>
  <a href="http://www.w3.org/2001/sw/hcls">W3C HCLS Meeting</a>
  <br>
  <ul type=circle>
  <li>Presentation: <a href="./FuGO-HCLS_Jan-2006.ppt">FuGO overview</a><br>
  </ul>
  
  <br>

  <b>Jan 9-10th</b>
  <br>
  <a href="http://www.mpdg.org/Metabomeeting2.htm">MetaboMeeting2</a>
  <ul type=circle> 
  <li>Presentation: <a href="./Sansone-MetabMeeting2-FuGO.ppt">FuGO and Metabolomics Society Ontology WG Overview</a><br>
  </ul>
  </ul>
  
  <!-- List 2005 Talks -->
  <br> 

  <ul>
  <li><b>2005</b></li><br>

  <b>Sep 14th</b>
  <br>
  <a href="http://www.cbu.uib.no/mged8/">MGED 8 meeting</a>
  <ul type=circle>
  <li>Presentation: <a href="./FuGO-MGED_2005.ppt">FuGO Workshop</a> (MGED Ontology Workshop - MO/FuGO Overview)
  <li><a href="./RSBI-FuGO-workshopv2.ppt">RSBI</a> (MGED Ontology Workshop - RSBI Overview)
  </ul>

  <br>
  <br>

  <b>Jun 24th</b>
  <br>
  <a href="http://bio-ontologies.man.ac.uk/">BioOntologies, 2005</a>
  <ul type=circle>
  <li><a href="./BioOntologies-2005.doc">Abstract</a> (BioOntologies FuGO Abstract)
  <li><a href="./BioOntologiesPoster-2005.ppt">Poster</a> (BioOntologies Poster)
  </ul>
  </div>

  <hr class=lightgray>
  
  <br>
  <div class=small>
  <a name=links><b>Links</b></a>
  <br> 
  <ul>
  <li><b>Software</b>
    <ul>
    <li><a href="http://protege.stanford.edu" target="_blank">Protege</a>
    <li><a href="http://geneontology.sourceforge.net" target="_blank">OBO Edit</a>
    </ul> 
  </ul>
  <ul>
  <li><b>Organizations</b>
    <ul>
    <li><a href="http://obofoundry.org" target="_blank">OBO Foundry</a>  
    <li><a href="http://www.bioontology.org" target="_blank">The National Center for Biomedical Ontology</a>
    </ul>
  </ul>
  
  </div>
  
  <hr class=lightgray> 
  <br>	
  <div class=small align=center>
  <?php
  obiFooter();
  ?>
  </div>

 </td>

</tr></table> <!-- END MAIN BODY TABLE -->

<br>

<div align=center>
<?php
sfLogo();
?>  

</div>


</body>

</html>
