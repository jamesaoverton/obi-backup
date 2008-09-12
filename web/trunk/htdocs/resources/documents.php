<?php
include ("../../include/util.inc");
?>

<html>

<head>
 <link rel="STYLESHEET" href="../style.css" type="text/css">
 <title>Documents</title>
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
  <a href="#workshop" class=menu>Workshop Docs</a>,
  <a href="#presentations" class=menu>OBI Presentations</a>,
  <a href="#logo" class=menu>OBI logo</a>
  </div>
  </td>
  </tr>
  </table>  


  <br><br><br>

  <div class=small>



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
  <li>Presentation: <a href="presentations/PSI-Spring-2006_FuGO.ppt">FuGO Overview and Community Work Towards FuGO</a>
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
  <li>Presentation: <a href="presentations/FuGO-HCLS_Jan-2006.ppt">FuGO overview</a><br>
  </ul>
  
  <br>

  <b>Jan 9-10th</b>
  <br>
  <a href="http://www.mpdg.org/Metabomeeting2.htm">MetaboMeeting2</a>
  <ul type=circle> 
  <li>Presentation: <a href="presentations/Sansone-MetabMeeting2-FuGO.ppt">FuGO and Metabolomics Society Ontology WG Overview</a><br>
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
  <li>Presentation: <a href="presentations/FuGO-MGED_2005.ppt">FuGO Workshop</a> (MGED Ontology Workshop - MO/FuGO Overview)
  <li><a href="presentations/RSBI-FuGO-workshopv2.ppt">RSBI</a> (MGED Ontology Workshop - RSBI Overview)
  </ul>

  <br>
  <br>

  <b>Jun 24th</b>
  <br>
  <a href="http://bio-ontologies.man.ac.uk/">BioOntologies, 2005</a>
  <ul type=circle>
  <li><a href="presentations/BioOntologies-2005.doc">Abstract</a> (BioOntologies FuGO Abstract)
  <li><a href="presentations/BioOntologiesPoster-2005.ppt">Poster</a> (BioOntologies Poster)
  </ul>

</ul>





  <br>
  <hr class=lightgray>
  <br>
  <a name=logo><b>OBI logo</b></a>
  <br>
  Thanks to Tom Buhrman, Graphic/Web Designer, buhrman (at) niehs.nih.gov who designed our <a href="http://obi.sourceforge.net/images/obilogo.jpg">logo</a>.
  <br>  <br>



  </div>



  
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
