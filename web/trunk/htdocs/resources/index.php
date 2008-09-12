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
  <a href="#obiusers" class=menu>obi-users list</a>,
  <a href="#faq" class=menu>FAQ</a>,
  <a href="#purls" class=menu>OBI links</a>,
  <a href="#pubs" class=menu>Publications</a>,
  <a href="#links" class=menu>Links</a>
  </div>
  </td>
  </tr>
  </table>  


  <br><br><br>

  <div class=small>


<br>  <img src="http://groups.google.com/groups/img/3nb/groups_bar.gif"         height=26 width=132 alt="Google Groups"><br><a name=obiusers><b>Subscribe to obi-users</b></a>  <form action="http://groups.google.com/group/obi-users/boxsubscribe">  <input type=hidden name="hl" value="en">  Email: <input type=text name=email>  <input type=submit name="sub" value="Subscribe"><br></form>  <a href="http://groups.google.com/group/obi-users?hl=en">Visit this group</a><br>
<br>


  <a name=faq><b>OBI FAQ</b></a>
  <br>
  OBI maintains a <a href="https://wiki.cbil.upenn.edu/obiwiki/index.php/FAQ">Frequently Asked Questions</a> section on
  our Wiki Pages. 



  <br>
  <hr class=lightgray>
  <br>


  <a name=purls><b>OBI links</b></a>
  <br>
 Some OBI resources are permanently linked using PURL (Persistent Uniform Resource Locator):
<ul>
<li><a href="http://purl.obofoundry.org/obo/obi/">http://purl.obofoundry.org/obo/obi/</a>: this website</li>
<li><a href="http://purl.obofoundry.org/obo/obi/doc/">http://purl.obofoundry.org/obo/obi/doc/</a>: OBI documentation</li>
<li><a href="http://purl.obofoundry.org/obo/obi/tracker">http://purl.obofoundry.org/obo/obi/tracker</a>: Sourceforge tracker</li>
<li><a href="http://purl.obofoundry.org/obo/obi.owl">http://purl.obofoundry.org/obo/obi.owl</a>: the latest OWL version of OBI</li>
<li><a href="http://purl.obofoundry.org/obo/obi/release-notes.html">http://purl.obofoundry.org/obo/obi/release-notes.html</a>: release notes</li>
<li><a href="http://purl.obofoundry.org/obo/obi/protege/obi.owl">http://purl.obofoundry.org/obo/obi/protege/obi.owl</a>: OBI Protege friendly version 
<li><a href="http://purl.obofoundry.org/obo/obi/wiki/">http://purl.obofoundry.org/obo/obi/wiki/</a>: the OBI wiki (mostly used for development)</li>
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
  <ul>
  <li><b>OBI documents</b>
    <ul>
    <li><a href="./documents.php#workshop">OBI workshop documents</a>  
    <li><a href="./documents.php#presentations">OBI presentations</a>  
    <li><a href="./documents.php#logo">OBI logo</a>  
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
