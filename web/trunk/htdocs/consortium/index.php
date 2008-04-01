<?php
include ("../../include/util.inc");
?>


<html>

<head>
 <link rel="STYLESHEET" href="../style.css" type="text/css">
 <title>OBI Consortium</title>
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
menu(consortium);
?>
  </div>

  <hr noshade size=2>
  <!-- sub menu -->
  <table bgcolor=#ffff99 border=0 style="border-right: 1px lightgrey; border-bottom: 1 px solid lightgrey;" cellpadding=3 align=right>
  <tr>
   <td>
  <div class=small align=right>Composition of the OBI Consortium:<br>
  <a href="#coordination" class menu>Coordination Committee</a>
  (<a href="#community" class menu>Community Representatives</a>, <a href="#coredevelopers" class menu>Core Developers</a>),
  <a href="#developers" class menu>Developers Working Group</a>
  </div>
   </td>
  </tr>
  </table>

   <br><br><br>

<div>
<b>The OBI Consortium</b><br>
The OBI project is an international, collaborative effort to build an ontology to be used for annotation of
Biomedical Investigations. The OBI Consortium is the name under which the OBI project authors its work. Membership is
detailed below.
<br><br>

</div>

<table bgcolor=#99CCFF border=0 style="border-right: 1px lightgrey; border-bottom: 1 px solid lightgrey;" cellpadding=3>
<tr><td>
<div class=small>
<a name="coordination"></a>
  <b>OBI Coordinating Committee</b> (<a href="#community" class menu>Community Representatives</a>,
  <a href="#coredevelopers" class menu>Core Developers</a>)<br>
  Please note that the starting date of a CC member is the date they started in the Coordinating Committee, and not
  the overall date of joining OBI, which could be earlier.
<table bgcolor=#FFFFFF border=0 style="border-right: 1px lightgrey; border-bottom: 1 px solid lightgrey;" cellpadding=3>
<tr><td>
<div class=small>
<a name="community"></a>
  <b>OBI Community Representatives</b>
  <br>
  The representives of the communities participating in the development of OBI.
  <table class=small>
  <tr><td class=gray>Community</td><td class=gray>Name</td><td class=gray>Community Affiliation</td><td class=gray>Institutional Affiliation</td><td class=gray>Start Date</td><td class=gray>End Date</td></tr>

  <!-- Bio-Imaging -->
  <tr><td class=gray rowspan="3">Bio-Imaging</td>
  <td><a href="http://www.nbirn.net/about/personnel.shtm">Jeff Grethe</a></td>
  <td><a href="http://www.nbirn.net">Biomedical Informatics Research Network (BIRN)</a> Coordinating Center</td>
  <td><a href="http://www.ucsd.edu/">University of California, San Diego</a></td>
  <td>Winter 2007</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.stanford.edu/~rubin/">Daniel Rubin</a></td>
  <td>Radiological Society of North America (RSNA)</td>
  <td><a href="http://bioontology.org/">National Center for Biomedical Ontology</a> at <a href="http://smi.stanford.edu">Stanford Medical Informatics</a> and the <a href="http://radiology.stanford.edu">Department of Radiology</a>, <a href="http://www.stanford.edu/">Stanford University</a></td>
  <td>Winter 2007</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://fireball.drexelmed.edu/neuroterrain/personnel/bbug/bbug.shtml">Bill Bug</a></td>
  <td><a href="http://www.nbirn.net">Biomedical Informatics Research Network (BIRN)</a></td>
  <td><a href="http://www.neuroterrain.org">Laboratory of Bioimaging and Anatomical Informatics</a>,
  in the <a href="http://neurobio.drexelmed.edu/">Department of Neurobiology and Anatomy</a>,
      <a href="http://www.drexelmed.edu/">Drexel University College of Medicine</a></td>
  <td>Spring 2006</td>
  <td>&nbsp;</td></tr>


  <!-- Cellular Assays -->
  <tr><td class=gray>Cellular Assays</td>
  <td><a href="http://www.dkfz.de/mga/home/wiemann/">Stefan Wiemann</a></td>
  <td>&nbsp;</td>
  <td><a href="http://www.dkfz.de/smp-cell/cell.org/groups.asp?siteID=7">DKFZ</a></td
  ><td>&nbsp; <!-- Unknown --></td>
  <td>&nbsp;</td></tr>


  <!-- Clinical Investigations -->
  <tr><td class=gray rowspan="3">Clinical Investigations</td>
  <td><a href="http://www.niehs.nih.gov/cebs-df/fostel.cfm">Jennifer Fostel</a></td>
  <td><a href="http://www.bioontology.org/wiki/index.php/CTO:Main_Page">Ontology for Clinical Investigations</a></td>
  <td><a href="http://www.niehs.nih.gov/cebs-df/twg.cfm">NIEHS, National Institute for Environmental Health Sciences</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>


  <td><a href="http://www.pharmgkb.org/home/team.jsp">Tina Hernandez-Boussard</a></td>
  <td>&nbsp; <!-- Unknown --></td>
  <td><a href="http://stanford.edu">Department of Genetics</a>, Stanford Medical School</td>
  <td>Fall 2007</td>
  <td>&nbsp;</td></tr>

  <td><a href="http://www8.utsouthwestern.edu/findfac/personal/0,2358,16416,00.html">Richard Scheuermann</a></td>
  <td><a href="http://www.bioontology.org/wiki/index.php/CTO:Main_Page">Ontology for Clinical Investigations</a></td>
  <td><a href="http://www.utsouthwestern.edu">University of Texas Southwestern Medical Center</a>, in
  in Department of Pathology and <a href="http://www.utsouthwestern.edu/utsw/cda/dept174769/files/327041.html">Division of Biomedical Informatics</a></td>
  <td>Winter 2007</td>
  <td>&nbsp;</td></tr>

  <!-- Crop Sciences -->
  <tr><td class=gray>Crop Sciences</td>
  <td><a href="http://www.irri.org/about/irridir/staffbio.asp#RichardBruskiewich">Richard Bruskiewich</a></td>
  <td><a href="http://www.generationcp.org">Generation Challenge Programme</a></td>
  <td><a href="http://www.irri.org">IRRI</a></td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>&nbsp;</td></tr>


  <!-- Electrophysiology -->
  <tr><td class=gray>Electrophysiology</td>
  <td><a href="http://www.cs.ncl.ac.uk/people/home.php?id=369">Frank Gibson</a></td>
  <td><a href="http://www.carmen.org.uk/">CARMEN</a></td>
  <td><a href="http://www.cs.ncl.ac.uk">School of Computing Science</a>,
      <a href="http://www.ncl.ac.uk/">Newcastle University</a></td>
  <td>Spring 2007</td>
  <td>&nbsp;</td></tr>


  <!-- Environmental Omics -->
  <tr><td class=gray><a href="http://www.mged.org/Workgroups/rsbi/rsbi.html">Environmental Omics</a></td>
  <td><a href="http://www.cs.manchester.ac.uk/bhig/people.php#normanmorrison">Norman Morrison</a></td>
  <td>&nbsp;</td>
  <td><a href="http://envgen.nox.ac.uk">NERC Environmental Bioinformatic Centre</a> and <a href="http://www.cs.manchester.ac.uk/">School of Computer Science, The University of Manchester</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>


  <!-- Flow Cytometry -->
  <tr><td class=gray><a href="http://flowcyt.sourceforge.net">Flow Cytometry</a></td>
  <td><a href="http://www.bccrc.ca/tfl/people_rbrinkman.html">Ryan Brinkman</a></td>
  <td><a href="http://www.isac.net">ISAC</a> and <a href="http://www.ficcs.org">FICCS</a></td>
  <td><a href="http://bccrc.ca">British Columbia Cancer Research Center</a> and <a href="http://www.ubc.ca">University of British Columbia</a> in the Department of Medical Genetics , Vancouver, BC, Canada</td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>


  <!-- Genomics/Metagenomics -->
  <tr><td class=gray rowspan="2">Genomics/Metagenomics</td>
  <td><a href="http://www.ceh.ac.uk/sections/meb/meb.html">Dawn Field</a></td>
  <td rowspan="2"><a href="http://www.genomics.ceh.ac.uk/genomecatalogue">Genome Catalogue</a></td>
  <td rowspan="2"><a href="http://www.ceh.ac.uk/">NERC Centre for Ecology and Hydrology</a></td>
  <td>Winter 2005</td>
  <td>&nbsp;</td></tr>

  <tr><td>Tanya Gray</a></td>
  <td>Winter 2005</td>
  <td>&nbsp;</td></tr>


  <!-- Immunology -->
  <tr><td class=gray rowspan="2">Immunology</td>
  <td><a href="http://www8.utsouthwestern.edu/findfac/personal/0,2358,16416,00.html">Richard Scheuermann</a></td>
  <td><a href="https://www.immport.org/immportWeb/home/home.do">ImmPort</a>, <a href="http://www.ficcs.org">FICCS</a>, BioHealthBase</td>
  <td><a href="http://www.utsouthwestern.edu">University of Texas Southwestern Medical Center</a>, in
  in Department of Pathology and <a href="http://www.utsouthwestern.edu/utsw/cda/dept174769/files/327041.html">Division of Biomedical Informatics</a></td>
  <td>Spring 2006</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.liai.org/pages/faculty-peters">Bjoern Peters</a></td>
  <td><a href="http://www.immuneepitope.org/">Immune Epitope Database and Analysis Resource</a></td>
  <td><a href="http://www.liai.org">La Jolla Institute for Allergy and Immunology</a></td>
  <td>Spring 2006</td>
  <td>&nbsp;</td></tr>


  <!-- In Situ Hybridization and Immunohistochemistry -->
  <tr><td class=gray>In Situ Hybridization and Immunohistochemistry</td>
  <td><a href="http://www.systemsbiology.org/scientists''and''research/Senior''Research''Scientists/Eric''Deutsch">Eric Deutsch</a></td>
  <td><a href="http://mged.sourceforge.net/misfishie/index.php">MISFISHIE</a></td>
  <td>&nbsp;</td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>&nbsp;</td></tr>


  <!-- Metabolomics -->
  <tr><td class=gray rowspan="2">Metabolomics</td>
  <td><a href="http://www.ebi.ac.uk/Information/Staff/person''maint.php?person''id=424">Susanna Sansone</a></td>
  <td rowspan="2"><a href="http://msi-ontology.sourceforge.net/">MSI</a>, </td>
  <td rowspan="2"><a href="http://www.ebi.ac.uk/net-project">The European Bioinformatics Institute EBI-EMBL, NET Project</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <td><a href="http://www.ebi.ac.uk/Information/Staff/person''maintx.php?person''id=734">Daniel Schober</a></td>
  <td>Spring 2006</td>
  <td>&nbsp;</td></tr>


  <!-- Neuroinformatics -->
  <tr><td class=gray rowspan="2"ks
  >Neuroinformatics</td>
  <td><a href="http://fireball.drexelmed.edu/neuroterrain/personnel/bbug/bbug.shtml">Bill Bug</a></td>
  <td><a href="http://www.nbirn.net">Biomedical Informatics Research Network (BIRN)</a></td>
  <td><a href="http://www.neuroterrain.org">Laboratory of Bioimaging and Anatomical Informatics</a>,
  in the <a href="http://neurobio.drexelmed.edu/">Department of Neurobiology and Anatomy</a>,
      <a href="http://www.drexelmed.edu/">Drexel University College of Medicine</a></td>
  <td>Spring 2006</td>
  <td>&nbsp;</td></tr>

  <td><a href="http://www.cs.ncl.ac.uk/people/home.php?id=369">Frank Gibson</a></td>
  <td><a href="http://www.carmen.org.uk/">CARMEN</a></td>
  <td><a href="http://www.cs.ncl.ac.uk">School of Computing Science</a>,
      <a href="http://www.ncl.ac.uk/">Newcastle University</a></td>
  <td>Spring 2007</td>
  <td>&nbsp;</td></tr>


  <!-- Nutrigenomics -->
  <tr><td class=gray>Nutrigenomics</td>
  <td><a href="http://www.ebi.ac.uk/Information/Staff/person''maintx.php?person''id=422 ">Philippe Rocca-Serra</a></td>
  <td><a href="http://www.mged.org/Workgroups/rsbi/rsbi.html">RSBI</a></td>
  <td><a href="http://www.ebi.ac.uk/net-project">The European Bioinformatics Institute EBI-EMBL, NET Project</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>


  <!-- Polymorphism -->
  <tr><td class=gray>Polymorphism</td>
  <td><a href="http://www.pharmgkb.org/home/team.jsp">Tina Hernandez-Boussard</a></td>
  <td><a href="http://www.pharmgkb.org">PharmGKB</a></td>
  <td><a href="http://stanford.edu">Department of Genetics</a>, Stanford Medical School</td>
  <td>Winter 2006</td>
  <td>Fall 2007</td></tr>


  <!-- Proteomics -->
  <tr><td class=gray rowspan="6">Proteomics</td>
  <td><a href="http://www.ebi.ac.uk/Information/Staff/person''maint.php?person''id=424">Susanna Sansone</a></td>
  <td rowspan="6"><a href="http://psidev.sourceforge.net/">PSI</a></td>
  <td rowspan="2"><a href="http://www.ebi.ac.uk/net-project">The European Bioinformatics Institute EBI-EMBL, NET Project</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.ebi.ac.uk/Information/Staff/person''maintx.php?person''id=734">Daniel Schober</a></td>
  <td>Spring 2006</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.ebi.ac.uk/Information/Staff/person''maintx.php?person''id=525">Luisa Montecchi</a></td>
  <td rowspan="2"><a href="http://www.ebi.ac.uk">The European Bioinformatics Institute EBI-EMBL</a></td>
  <td>Spring 2006</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.ebi.ac.uk/Information/Staff/person''maintx.php?person''id=437">Chris Taylor</a></td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://mged.sf.net">Trish Whetzel</a></td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <td><a href="http://www.cs.ncl.ac.uk/people/home.php?id=369">Frank Gibson</a></td>
  <td><a href="http://www.cs.ncl.ac.uk">School of Computing Science</a>,
      <a href="http://www.ncl.ac.uk/">Newcastle University</a></td>
  <td>Spring 2007</td>
  <td>&nbsp;</td></tr>


  <!-- Structural Biology / Structural Bioinformatics -->
  <tr><td class=gray>Structural Biology / Structural Bioinformatics</td>
  <td><a href="mailto:jwest@rcsb.rutgers.edu">John Westbrook</a></td>
  <td><a href="http://www.wwpdb.org">Worldwide Protein Data Bank (wwPDB)</a></td>
  <td>Department of Chemistry and Chemical Biology, <a href="http://www.rutgers.edu">Rutgers University</a></td>
  <td>Winter 2007/8</td>
  <td>&nbsp;</td></tr>

  <!-- Toxicogenomics -->
  <tr><td class=gray rowspan="2">Toxicogenomics</td>
  <td><a href="http://www.niehs.nih.gov/cebs-df/fostel.cfm">Jennifer Fostel</a></td>
  <td><a href="http://www.mged.org/Workgroups/rsbi/rsbi.html">Toxicogenomics</a></td>
  <td><a href="http://www.niehs.nih.gov/cebs-df/twg.cfm">NIEHS, National Institute for Environmental Health Sciences</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.ebi.ac.uk/Information/Staff/person''maint.php?person''id=424">Susanna Sansone</a></td>
  <td><a href="http://www.mged.org/Workgroups/rsbi/rsbi.html">RSBI</a> </td>
  <td><a href="http://www.ebi.ac.uk/net-project">The European Bioinformatics Institute EBI-EMBL, NET Project</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>


  <!-- Transcriptomics -->
  <tr><td class=gray rowspan="10">Transcriptomics</td>
  <td><a href="http://www.ebi.ac.uk/Information/Staff/person''maint.php?person''id=424">Susanna Sansone</a></td>
  <td rowspan="10"><a href="http://mged.sourceforge.net/ontologies">MGED</a> </td>
  <td rowspan="2"><a href="http://www.ebi.ac.uk/net-project">The European Bioinformatics Institute EBI-EMBL, NET Project</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.ebi.ac.uk/Information/Staff/person''maintx.php?person''id=422 ">Philippe Rocca-Serra</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://mged.sf.net">Trish Whetzel</a></td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.cbil.upenn.edu/~stoeckrt/home.html">Chris Stoeckert</a></td>
  <td><a href="http://pcbi.upenn.edu">Department of Genetics and Center for Bioinformatics</a>, <a href="http://www.upenn.edu/">University of Pennsylvania</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td>Gilberto Fragoso</td>
  <td><a href="http://ncicb.nci.nih.gov">NCI Center for Bioinformatics</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td>Joe White</td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://www.ebi.ac.uk/Information/Staff/person''maint.php?person''id=413">Helen Parkinson</a></td>
  <td><a href="http://www.ebi.ac.uk">The European Bioinformatics Institute EBI-EMBL</a></td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td>Mervi Heiskanen</td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>&nbsp; <!-- Unknown --></td>
  <td>&nbsp;</td></tr>

  <tr><td>Liju Fan</td>
  <td>Ontology Workshop, LLC, Columbia, MD, USA</td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>

  <tr><td><a href="http://wwwfom.sk.med.ic.ac.uk/medicine/people/helen.causton/">Helen Causton</a></td>
  <td>Imperial College</td>
  <td>Spring 2004</td>
  <td>&nbsp;</td></tr>


  <!--
  <tr><td class=gray></td>
  <td><a href=""></a></td>
  <td></td>
  <td></td>
  <td></td>
  <td>&nbsp;</td></tr>
   -->

  </table>
  </div>
</td></tr>
</table>
<br>
<table bgcolor=#FFFFFF width="100%" border=0 style="border-right: 1px lightgrey; border-bottom: 1 px solid lightgrey;" cellpadding=3>
<tr><td>
<div class=small>
  <a name="coredevelopers"></a>
  <b>OBI Core Developers</b>
  <br>
  Core Developers are considered key to the evolution of the ontology, but may or may not be members of any single
  community.
  <table class=small>
  <tr><td class=gray>Name</td><td class=gray>Project Affiliations</td><td class=gray>Institutional Affiliation</td><td class=gray>Start Date in CD Role</td><td class=gray>End Date</td></tr>

    <tr><td>Melanie Courtot</td>
    <td><a href="http://flowcyt.sourceforge.net">Flow Cytometry</a>, <a href="http://www.ebi.ac.uk/sbo/">SBO</a>,
    <a href="http://www.ebi.ac.uk/biomodels/">BioModels</a></td>
    <td><a href="http://bccrc.ca">British Columbia Cancer Research Center</a> and <a href="http://www.ubc.ca">University of British Columbia</a> in the Department of Medical Genetics , Vancouver, BC, Canada</td>
    <td>Fall 2007</td>
    <td>&nbsp;</td></tr>

    <tr><td><a href="http://www.cs.ncl.ac.uk/people/home.php?id=452">Allyson Lister</a></td>
    <td><a href="http://www.mged.org/Workgroups/rsbi/rsbi.html">RSBI</a>,
    <a href="http://www.genomics.ceh.ac.uk/genomecatalogue">Genome Catalogue</a>,
    <a href="http://symba.sf.net">SyMBA</a>,
    <a href="http://fuge.sf.net">FuGE</a></td>
    <td><a href="http://www.cisban.ac.uk">CISBAN</a></td>
    <td>Summer 2007<!-- (Spring 2006 with OBI)--></td>
    <td>&nbsp;</td></tr>

    <tr><td><a href="http://sciencecommons.org/about/whoweare/ruttenberg/">Alan Ruttenberg</a></td>
    <td><a href="http://sw.neurocommons.org/">The Neurocommons</a></td>
    <td>Science Commons</td>
    <td>Fall 2007</td>
    <td>&nbsp;</td></tr>

    <tr><td><a href="http://www.ebi.ac.uk/Information/Staff/person_maint.php?s_person_id=734">Daniel Schober</a></td>
    <td>&nbsp;</td>
    <td><a href="http://www.ebi.ac.uk">EBI</a></td>
    <td>Fall 2007</td>
    <td>&nbsp;</td></tr>

    <tr><td><a href="http://www.ebi.ac.uk/Information/Staff/person_maintx.php?s_person_id=863">James Malone</a></td>
    <td><a href="http://www.microarray-quality.org/">EMERALD</a></td>
    <td><a href="http://www.ebi.ac.uk">EBI</a></td>
    <td>Fall 2007</td>
    <td>&nbsp;</td></tr>

  </table>
  Project Affiliations are associations of the developer to other projects relevant to OBI.
</div>
</td></tr>
</table>
</div>
</td></tr>
</table>
<br>
<table bgcolor=#99CCFF border=0 style="border-right: 1px lightgrey; border-bottom: 1 px solid lightgrey;" cellpadding=3>
<tr><td>
<div class=small>
  <a name="developers"></a>
  <b>OBI Developers Working Group</b>
<table bgcolor=#FFFFFF border=0 style="border-right: 1px lightgrey; border-bottom: 1 px solid lightgrey;" cellpadding=3>
<tr><td>
<div class=small>
  The Developers Working Group consists of all developers within the communities collaborating
  in the development of OBI, at the discretion of current OBI Consortium members.
  <ul>
  <li>Kevin Clancy</li>
  <li>Christian Cocos</li>
  <li>Jay Greenbaum</li>
  <li>Chris Mungall</li>
  <li>Matthew Pocock</li>
  <li>Holger Stenzhorn</li>
  <li>Pierre Grenon</li>
  </ul>
</div>
</td></tr>
</table>
</table>
</div>
</td></tr>
</table>

<hr class=lightgrey>

         <div class=small align=center>
         <?php
         obiFooter();
         ?>
         </div>

</div>

</table> <!-- END MAIN BODY TABLE -->

<br>

<div align=center>
<?php
sfLogo();
?>
</div>

</body>
</html>
