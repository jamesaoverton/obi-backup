<?php
include("../../include/util.inc");
?>

<html>

<head>
 <link rel="STYLESHEET" href="../style.css" type="text/css">
 <title>OBI Ontology</title>
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
  <div class=small align=left>&nbsp;
<?php
menu(ontology);
?>
 </div>
  <hr noshade size=2>

  <!-- sub menu -->
  <table bgcolor=#ffff99 border=0 style="border-right: 1px solid lightgrey; border-bottom: 1px solid lightgrey;" 
  cellpadding=3 align=right>
  <tr>
   <td>
  <div class=small align=right>On this page:<br>
  <a href=#ontology class=menu>Ontology</a>,
  <a href=#designPrinciples class=menu>Design Principles</a>,
  <a href=#process class=menu>Development Process</a>

  </div>
   </td>
   </tr>
  </table>

   <br><br><br>

  <div class=small>

  <a name=ontology><b>OBI Ontology</b></a><br>

  The Ontology for Biomedical Investigations is designed as a resource for the annotation of 
  biomedical investigations and will provide terms that can be used to annotate the 
  investigation, protocols and instrumentation, material used in the investigation, and the 
  data generated and types of analysis performed on the data. A full description of the 
  purpose of the ontology can be viewed in the <a href=../index.php>Mission Statement</a>. 
  The ontology is being developed as an <a href="http://obofoundry.org" target="_blank">OBO Foundry</a> 
  ontology and also follows other ontology design best practices. 
  The <a href=#designPrinciples>Design Principles</a> followed are described below.

  <br><br>
	
  <b>Ontology Draft</b>
  <br>
  The ontology file (.owl) are available from the 
  <a href="http://obi.svn.sourceforge.net/viewvc/obi/ontology/trunk/OBI.owl?view=log">OBI SVN Repository.</a>  
  <br>
  <b>NOTE: This is a DRAFT VERSION and is subject to many more edits before being able to be used  
  in a production system or as as stable release suitable for extension for other domains without 
  needing further updates.</b><br> 
  <br>
  <b>Ontology Development Status</b> 
  <br>
The main area of focus at the Third OBI workshop (Feb, 2007) was to review the OBI classes extending
 directly from BFO, resulting in a set of OBI 'core' classes. In addition, a policy for further parallel, development from these 'core' classes 
was drafted and approved by the OBI Coordinators. The policy, <a href="https://www.cbil.upenn.edu/obiwiki/index.php/ObiBranches">ObiBranches</a>, lists the various branch groups and the responsibilities of those working to
 curate terms and develop, these branches. During this process, additional terms were identified to propose for inclusion in BFO, 
such as generically_dependent_continuant (currently represented as a sibling to the BFO continuant subclasses).<br>
A first set of information to capture using annotation properties, as listed on the <a href="http://obi.sourceforge.net/ontologyInformation/MinimalMetadata.html">metadata</a> page was also agreed upon.<br>
  <br>
  A new version of the ontology was generated following the second workshop (July, 2006). The 
  focus of this workshop was to refine the scope of OBI/FuGO in light of other OBO Foundry ontologies,
  review the current structure of OBI/FuGO and add definitions for terms. It was at this workshop that 
  the name Ontology for Biomedical Investigations (OBI) was proposed in order to better reflect the 
  scope of the project. The presentations and workshop report are available for download from the OBI File Release System in the Package titled
  <a href="http://sourceforge.net/project/showfiles.php?group_id=177891">Workshops</a>.  
  <br><br>
  Following the first workshop (Feb, 2006), a draft of the ontology was constructed. The focus 
  of the workshop was to identify the top level classes of OBI (then named FuGO) and test the 
  structure with domain specific terms (Proteomics). The presentations and workshop report can 
  be found in the OBI File Release System in the Package titled 
  <a href="http://sourceforge.net/project/showfiles.php?group_id=177891">Workshops</a>. 
  The first version of the ontology contains these top level classes as well as some terms that 
  are specific to Proteomics technology.<br>
<br>
  To follow or join in the development of OBI, subscribe to the mailing list at: 
  <a href="https://lists.sourceforge.net/lists/listinfo/obi-devel">OBI Developers</a>. 
  To propose new terms, go to the 
  <a href="http://sourceforge.net/tracker/?group_id=177891&atid=886178">OBI Term</a> tracker.

  <br>
 
  <hr class=lightgray>
  <br>
  
  <a name=designPrinciples><b>Ontology Design Principles</b></a>
  <br>
  The OBI developers will generate a document based on the proposed Ontology Best Practice   
  information containing the design principles, <a href="https://www.cbil.upenn.edu/obiwiki/index.php/NamingConventions">naming conventions</a> and ontology metadata that 
  will be used for the development of OBI. An agreed upon minimal list of annotation <a href="http://obi.sourceforge.net/ontologyInformation/MinimalMetadata.html">metadata</a> for representational units has been created.
  
  <hr class=lightgray>
  <br>
  
  <a name=process><b>Development Process</b></a>
  <br><br>
  <b>General Outline</b>
  <br>
  The development of OBI has consisted of the presentation of Use Cases from the Community 
  Representatives, the generation of Term Lists from the communities, the development of the top-level 
  of OBI and the addition of the the terms in the community Term Lists into the ontology. Generally 
  speaking, the work within the individual communities is proceeding in a bottom-up fashion while 
  the work within the larger OBI Developers Working Group is proceeding in a top-down fashion. The 
  within Community, bottom-up approach consists of the Use Cases, the generation of the Term Lists. 
  The top-down approach consists of extending a known upper level ontology to the level where 
  communities can then add terms from the Term Lists. More details on each of these processes 
  can be found below. 

  <br><br>
  <b>Use Cases</b>
  <br>
  In order to gain a better understanding of the Communities involved in the project, Community 
  Representatives are encouraged to submit Use Cases.  The Use Case will be presented by the Community
  Representative during a scheduled Developers Group conference call.  
  <br>

  <b>Download Selected Use Cases</b>
  <br>

  <ol>
  <li><a href="useCases/UseCaseEpitopes.pdf">Epitopes</a><br>
  <li><a href="useCases/FlowCytometry_UseCase.pdf">Flow Cytometry</a><br>
  <li>Reporting Structure for Biological Investigation (RSBI): &nbsp;
  <a href="useCases/RSBI-Use_cases_Tox_and_Nutr.doc">Toxicogenomics</a> &nbsp;|&nbsp;
  <a href="useCases/RSBI-Use_cases_Tox_and_Nutr.doc">Nutrigenomics</a>
  <li><a href="useCases/SNP_UseCase.doc">PharmGKB - SNP Use Case</a><br>
  <li><a href="useCases/Proteomics_UseCase.doc">Proteomics</a><br>
  </ol>

  <br>

  <a name=terms><b>Community Term Lists for OBI</b></a><br>
  Each Community has generated a Term List to indicate a sampling of the terms needed by their community. 
  Proposed terms lists are available for download in the downloads section: 
  <a href=./termList>TermLists</a><br>

  <br>
  <b>Top-level Structure of OBI</b>
  <br>
  The top-level structure is an extension of the <a href="http://www.ifomis.uni-saarland.de/bfo/home.php" target="_blank">Basic Formal Ontology</a> (BFO).

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
