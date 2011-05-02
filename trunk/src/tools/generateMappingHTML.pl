# According to given list of OBI classes, generate HTML
# add link to OBI terms
# targetFile: OBI classes text file (ID + Label)  
# outFile: OBI classes HTML file (ID + Label + link to ontoBee + link to Bioportal)

# command:
# perl generateMappingHTML.pl --targetFile newClasses.txt --outFile newClasses.html --title "Classes newly added to OBI between San Diego 2011 release and Vancouver 2010 release, RC2" --note "links to ontobee and bioportal should be working after May 9, 2011" 

use strict;
use Getopt::Long;
use IO::File;

my ($targetFile, $outFile, $title, $note);

&GetOptions('targetFile=s' => \$targetFile,
	    'outFile=s' => \$outFile,
	    'title=s' => \$title,
	    'note=s' => \$note
	   );

my $HTMLobjects;
my $bioPortal = "http://bioportal.bioontology.org/visualize/44899/?conceptid=obi%3A";

&textToHTML();
&writeFile();

sub textToHTML {
	my $fh = IO::File->new("<$targetFile") || die "Cannot read file '$targetFile': $!";
	
	
	while (my $line = <$fh>) {
		chomp($line);

		my @row = split(/\s*label:\s*/, $line);		
		my $uri = $row[0];
		my $id = substr($uri,31);		
		my $label = $row[1];

		my $object = "<TR class=\"d0\"><td>$id</td><td>$label</td><td><a href=\"$uri\"><i>ontobee</i></a> <td><a href=\"$bioPortal"."$id\"><i>bioportal</i></a></td></TR>";
		push(@{$HTMLobjects}, $object);
	}
	$fh->close();
}
	
	
# write HTML file
sub writeFile {
  	my $fh = IO::File->new(">$outFile") || die "Cannot write file '$outFile': $!";
	STDERR->print("Write HTML file: $outFile\n");

	$fh->print("<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n");
	$fh->print("<title>Newly Added Classes in This Release</title>\n");
	$fh->print("<style type=\"text/css\">\n");
	$fh->print("tr.d0 td {\nbackground-color: #EEEEEE; color: black;\n}\n</style>\n");
	$fh->print("<h2>$title</h2>\n");
	$fh->print("<i>Note: $note</i><br><br>\n");
	$fh->print("<table width=\"80%\" cellpadding=2>\n");
 	foreach my $line (@{$HTMLobjects}) {
  		$fh->print("$line\n");
  	}
  	$fh->print("</table>\n</html>\n");

  	$fh->close();
}