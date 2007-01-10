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
  <br>
  <ul>
  <li>The OBI project contains a developers group that is open for all to participate.  To get involved, 
  subscribe to the 
  <a href="https://lists.sourceforge.net/lists/listinfo/obi-devel">OBI Developers</a> mailing list.   
  The list will cover the announcement of conference calls, the agenda and minutes in case you miss a 
  call, and general topics of interest for all communites involved in the project.  
  <br><br>
  Check out the <a href="http://obi.sourceforge.net/community/index.php">Community page</a> to 
  see what communities are involved with this project.
  </ul>
  <br>
  <hr class=lightgray>
  <br>

  <a name=workshop><b>OBI (formerly FuGO) Workshop Documents</b></a> 
  <ul>
  <li><a href="http://sourceforge.net/project/showfiles.php?group_id=177891&package_id=209476&release_id=458979">1st Workshop (February 2006; Philadelphia, PA)</a>
  <li><a href="http://sourceforge.net/project/showfiles.php?group_id=177891&package_id=209476&release_id=458978">2nd Workshop (July 2006; Hinxton, UK)</a>
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
