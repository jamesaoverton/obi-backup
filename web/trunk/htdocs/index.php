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
    <li>Create a valuable resource for the biomedical communities to provide a source of terms 
        for consistent annotation of investigations
   </ul>
  </font>

  </div>

  <hr class=lightgray>

  <br>

  <a name=organization><b>Project Organization</b></a>
  <br> 
  The <a href="consortium/index.php">OBI Consortium</a> contains:
  <ul>
  <li><a href="consortium/index.php#coordination">Coordination Committe</a>, consisting of:<br>
  <ul>
  <li><a href="consortium/index.php#community">Community Representatives</a>, those representing the communities
  participating in the development of OBI, and</li>
  <li><a href="consortium/index.php#coredevelopers">Core Developers</a>, those who are considered key to the
  evolution of the ontology, but who are not members of any single community.</li>
  </ul>
  </li>
  <li><a href="consortium/index.php#developers">Developers Working Group</a><br>
  The Developers Working Group consists of all developers within the communities collaborating
  in the development of OBI. To participate in the development of OBI, subscribe to the
  <a href="https://lists.sourceforge.net/lists/listinfo/obi-devel">OBI Developers</a> mailing list
  and join in the <a href="#call">conference calls</a>.
  </li>
   </ul>

The development of OBI is <a href="supportgroups/index.php">advised and supported</a> by:
<ul>
  <li>The OBI <a href="supportgroups/index.php#advisors">Advisors Group</a><br>
    The Advisors Group consists of individuals invited by the Coordination Committee to provide expert advice in areas
    such as ontology best practices and technical implementation issues.</li>
  <li><a href="supportgroups/index.php#supporters">Supporting Groups and Organizations</a><br>
  Various Supporting Groups and Organizations have encouraged their members to offer their time towards
  the development of OBI, often without recourse to supplementary funding.</li>
  </ul>
   
  If you represent a Community that would like to collaborate in the development of OBI, contact the 
  <a href="mailto:obi-coord@lists.sourceforge.net">Coordination Committee</a>.

  <br><br>
  Additionally, to keep up with the pace of development in OBI, an
  <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php?title=HomePage" target="_blank">OBI Wiki</a> has been set up to
  promote the quick release of new information to the public.
  <br><br>

  The full documentation on the scope and organization of the OBI project is available for 
  <a href="http://sourceforge.net/project/showfiles.php?group_id=177891">download</a>.

  <br><br> 

  <hr class=lightgray>

  <b>Conference Calls</b><br>
  Weekly Developer Working Group conference calls are held on Wednesdays from 11-12AM EST, 4-5PM GMT, with the exception
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

