use strict;


open TOP, "<obi.owl" or die("can't find obi.owl");
my @lines = <TOP>;
close TOP;

# extract the names of the branches
my @obiParts = grep {/<owl:imports rdf:resource="http:\/\/obi.sourceforge.net\/ontology\/OBI\/(.*)\.owl"/;$1} @lines;
my @obiParts = map { s/.*\/([A-Za-z.-]*)\.owl.*/$1/;chomp $_ ; $_} @obiParts;

# extract the other import statementsn
my @otherImports = grep {/<owl:imports rdf:resource="(.*?)"/;my $it=$1; if ($_=~/obi\.sourceforge\.net/) {undef} else {$it}} @lines;

my @all;

sub findnames 
  {
    foreach my $part ( @obiParts) {
      next if ($part=~/Relation/); 
      my $path = "$part".".owl";
      open PART, "<$path" or die("Trouble loading $path");
      my $copy;
      while (<PART>) {
	if (/<\/owl:Ontology>/) { $copy = 1; next } # don't start copying until after the <ontology> section
	if (/<\/rdf:RDF>/) { $copy = 0 } # but don't copy the closing tag
	if ($copy) 
	  { 
	    my @names = $_ =~ /rdf:(about|id|resource)=(".*?")/g;
	    my %them  = @names;
	    @all = (grep {/obi\.sourceforge/ && !/OBI_/} (values %them),@all);
	    print OUT $_ 
	  }
      }
      close PART;
    }
  }

  findnames();

my %all;
foreach my $name(@all) { $all{$name}=1}

print join("\n",keys %all);
