<?php
  include ("../include/util.inc");
?>

<html>

<head>
 <link rel="STYLESHEET" href="style.css" type="text/css">
 <title>Ontology for Biomedical Investigations (OBI) | Home</title>
</head>

<body bgcolor=#99CCFF>
<br>

<!-- MAIN BODY TABLE -->
<table bgcolor=#ffffff border=0 cellpadding=12 cellspacing=5 width=75% align=center class=grayShadeOne>
 

<tr> <!-- banner row -->

 <!--<td align=center><img src=images/fugo-banner.jpg border=0></td>-->
<?php
title();
?>
</tr> <!-- end banner row -->

<tr valign=top>

 <td> 

  <!-- menu -->
  <div class=small align=left>&nbsp;

<?php
menu(home);
?>
<!--	
  * Home &nbsp;|&nbsp;
  <a href=ontology/ontology.php class=menuNew>Ontology</a> &nbsp;|&nbsp;
  <a href=community/community.php class=menuNew>Community</a> &nbsp;|&nbsp;
  <a href=resources/resources.php class=menuNew>Resources</a>&nbsp;|&nbsp; 
  <a href=downloads/downloads.html class=menuNew>Downloads</a> &nbsp;&nbsp;
 -->
</div>

  <hr noshade size=2>

  <!-- sub menu -->
  <table bgcolor=#ffff99 border=0 style="border-right: 1px lightgrey; border-bottom: 1 px solid lightgrey;" cellpadding=3 align=right>
  <tr>
   <td>
  <div class=small align=right>On this page:<br>
  <a href="#statement" class menu>Mission Statement</a>,
  <a href="#organization" class menu>Project Organization</a>,
  <a href="#call">Conference Calls</a>
  </div>
   </td>
  </tr>
  </table>

 <br><br><br>

  <br>

  <div class=small>

  <a name=statement><b>MISSION STATEMENT</b></a>
  <br><br>

  <!--<div class=small align=justify>-->
  <div class=small>
  <!--<div class=sma>-->
  <font color=maroon>
   The Ontology for Biomedical Investigations (OBI) project is developing an integrated 
   ontology for the description of biological and medical experiments and investigations. This includes
   a set of 'universal' terms, that are applicable across various biological and technological domains, 
   and domain-specific terms relevant only to a given domain.  This ontology will support the 
   consistent annotation of biomedical investigations, regardless of the particular field of study. 
   The ontology will model the design of an investigation, the protocols and instrumentation 
   used, the material used, the data generated and the type analysis performed on it. This 
   project was formerly called the Functional Genomics Investigation Ontology (FuGO) project.

   <ul>
    <li>Develop an Ontology for Biomedical Investigations in collaboration with groups 
        representing different biological and technological domains involved in Biomedical
        Investigations
    <li>Make OBI compatible with other bio-ontologies 
    <li>Develop OBI using an open source approach
    <li>Open source 
    <li>Create a valuable resource for the biomedical communities to provide a source of terms 
        for consistent annotation of investigations
   </ul>
  </font>

  </div>

  <hr class=lightgray>

  <br>

  <a name=organization><b>Project Organization</b></a>
  <br> 
  The project consists of the Coordination Committe, the Developers Working Group and Advisors Group. The 
  Coordination Committee consists of the Community Representatives, those representing the communities 
  participating in the development of OBI, and the Core Developers. View the 
  <a href="../community/index.php">Community</a> page to see a listing of the participating communities. 
  If you represent a Community that would like to collaborate in the development of OBI, contact the 
  <a href="mailto:obi-coord@lists.sourceforge.net">Coordinators</a>.
  <br><br>
  The Developers Working Group consists of all developers within the communities collaborating 
  in the development of OBI. To participate in the development of OBI, subscribe to the
  <a href="https://lists.sourceforge.net/lists/listinfo/obi-devel">OBI Developers</a> mailing list 
  and join in the <a href="#call">conference calls</a>.
  <br><br>
  The Advisors Group consists of individuals invited by the Coordination Committee to provide
  expert advice in areas such as ontology best practices and technical implementation issues. A
  listing of the OBI Advisors is available on the <a href="../community/index.php">Community</a>
  page.   
  <br><br>
  The full documentation on the scope and organization of the OBI project is available for 
  <a href="http://sourceforge.net/project/showfiles.php?group_id=177891">download</a>. 

  <br><br> 

  <hr class=lightgray>

  <b>Conference Calls</b><br>
  Weekly developers conference calls are held on Wednesdays from 11-12AM EST, 4-5PM GMT, with the exception 
  of the second Wednesday of each month.  For more information on these calls, check the 
  <a href="https://www.cbil.upenn.edu/obiwiki/index.php/ConferenceCallAgenda" target="_blank">OBI Wiki</a>.  
 
  <br><br>

  <a name=call><b>Notes From Previous Conference Calls</b></a><br>
  <a href="./notes">View Notes</a>

  </div>

  <br>

  <hr class=lightgray>

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

