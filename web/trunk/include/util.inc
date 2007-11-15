<?
function fugoLogo ()  {
	print "<a href='http://fugo.sf.net'><IMG src='http://fugo.sourceforge.net/images/FuGO-HomeLogo.jpg' border='0' alt='FuGO Home'/></a>";
printf ("<br><br>");
}

function title() {
  print ("<td class='logo-header' align=center><font face=arial size=5><b>Ontology for Biomedical Investigations</b></font></td>");
}


function fugoHeader($root,$title) { 
  print "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Strict//EN'  'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'> 
      <html>
      <head><title>$root | $title </title>
      <link href='/include/fugo.css' rel='stylesheet' type='text/css' /> 
      </head>
      <body>
      <font class='title' >$root | $title</font>
      <hr />\n";
}

function menu($location)  {
if ($location=="home") {
  print ("*Home &nbsp;|&nbsp;
  <a href=ontologyInformation/index.php class=menuNew>Ontology</a>&nbsp;|&nbsp;
  <a href=consortium/index.php class=menuNew>Consortium</a>&nbsp;|&nbsp;
  <a href=supportgroups/index.php class=menuNew>Supporting Groups</a>&nbsp;|&nbsp;
  <a href=resources/index.php class=menuNew>Resources</a>&nbsp;|&nbsp;
");
}
elseif ($location=="ontology") {
  print ("
  <a href=../index.php class=menuNew>Home</a>&nbsp;|&nbsp;
  *Ontology &nbsp;|&nbsp;
  <a href=../consortium/index.php class=menuNew>Consortium</a>&nbsp;|&nbsp;
  <a href=../supportgroups/index.php class=menuNew>Supporting Groups</a>&nbsp;|&nbsp;
  <a href=../resources/index.php class=menuNew>Resources</a>&nbsp;|&nbsp;
");
}
elseif ($location=="consortium"){
  print ("
  <a href=../index.php class=menuNew>Home</a>&nbsp;|&nbsp;
  <a href=../ontologyInformation/index.php class=menuNew>Ontology</a>&nbsp;|&nbsp;
  *Consortium &nbsp;|&nbsp;
  <a href=../supportgroups/index.php class=menuNew>Supporting Groups</a>&nbsp;|&nbsp;
  <a href=../resources/index.php class=menuNew>Resources</a>&nbsp;|&nbsp;
");
}
elseif ($location=="supportgroups"){
  print ("
  <a href=../index.php class=menuNew>Home</a>&nbsp;|&nbsp;
  <a href=../ontologyInformation/index.php class=menuNew>Ontology</a>&nbsp;|&nbsp;
  <a href=../consortium/index.php class=menuNew>Consortium</a>&nbsp;|&nbsp;
  *Supporting Groups&nbsp;|&nbsp;
  <a href=../resources/index.php class=menuNew>Resources</a>&nbsp;|&nbsp;
");
}
else {
  print ("
  <a href=../index.php class=menuNew>Home</a>&nbsp;|&nbsp;
  <a href=../ontologyInformation/index.php class=menuNew>Ontology</a>&nbsp;|&nbsp;
  <a href=../consortium/index.php class=menuNew>Consortium</a>&nbsp;|&nbsp;
  <a href=../supportgroups/index.php class=menuNew>Supporting Groups</a>&nbsp;|&nbsp;
  *Resources &nbsp;&nbsp;
");
}

}

//OLD
/**
function navBar() {
print "<table border=\"1\" bordercolor=\"#0000CC\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">	
<td bgcolor=\"#0000CC\"> <font color=\"#FFFFFF\" face=\"arial\"><b>&nbsp; 
<a href=\"/index.php\" style=\"text-decoration:none\"><font color=\"white\">HOME</a> &nbsp; :: &nbsp; 
<a href=\"/ontologyInfo/ontology.php\" style=\"text-decoration:none\"><font color=\"white\">ONTOLOGY</a> :: &nbsp; 
<a href=\"/lists/list.php\" style=\"text-decoration:none\"><font color=\"white\">MAILING LIST</a> &nbsp; :: &nbsp; 
<a href=\"/presentations/presentation.php\" style=\"text-decoration:none\"><font color=\"white\">PRESENTATIONS</a> &nbsp; :: &nbsp; 
<a href=\"/consortium/consortium.php\" style=\"text-decoration:none\"><font color=\"white\">COMMUNITY INVOLVEMENT</a> &nbsp; :: &nbsp;
<a href=\"/news/index.php\" style=\"text-decoration:none\"><font color=\"white\">NEWS</a>
</font></td>
</tr>
</table>";
}
*/

function obiFooter() {
  print("To report errors with the site, write to obi-web-support at lists.sourceforge.net<br>");
}

function sfLogo() {
  print ("<a href='http://sourceforge.net'><IMG src='http://obi.sf.net/images/sflogo-1.png' border=0 alt='Sourceforge.net Logo'></a>");
}

?>
