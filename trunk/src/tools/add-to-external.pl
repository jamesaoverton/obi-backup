use strict;

sub usage ()
{ print "perl add-to-external.pl child parent [path to external.owl]\ne.g. perl add-to-external.pl PRO:000000001 CHEBI:23091" }

my $child = $ARGV[0];
my $parent = $ARGV[1];
my $branchpath = $ARGV[2];
if (!$branchpath)
{ $branchpath = `cd  \`dirname $0\`/../ontology/branches/; pwd` ;
  chomp $branchpath;
  $branchpath .= "/external.owl";
}
my @valid_externals = qw(PATO PRO FMA CHEBI GO CL NCBITaxon ENVO SO);

# format: id prefix, uri prefix, source ontology, id pattern
# add another line for each new ontology

my $externals_table = 
    [["PATO", "http://purl.org/obo/owl/PATO#PATO_", "http://purl.org/obo/owl/PATO", "\\d+"],
     ["PRO", "http://purl.org/obo/owl/PRO#PRO_", "http://purl.org/obo/owl/PRO","\\d+"],
     ["FMA", "http://purl.org/obo/owl/FMA#FMA_", "http://purl.org/obo/owl/FMA","\\d+"],
     ["CHEBI", "http://purl.org/obo/owl/CHEBI#CHEBI_", "http://purl.org/obo/owl/CHEBI","\\d+"],
     ["GO", "http://purl.org/obo/owl/GO#GO_", "http://purl.org/obo/owl/GO","\\d+"],
     ["CL", "http://purl.org/obo/owl/CL#CL_", "http://purl.org/obo/owl/CL","\\d+"],
     ["NCBITaxon", "http://purl.org/obo/owl/NCBITaxon#NCBITaxon_", "http://purl.org/obo/owl/NCBITaxon","\\d+"],
     ["ENVO", "http://purl.org/obo/owl/ENVO#ENVO_", "http://purl.org/obo/owl/ENVO","\\d+"],
     ["SO", "http://purl.org/obo/owl/ENVO#SO_", "http://purl.org/obo/owl/ENVO","\\d+"],
     ["VO", "http://purl.obolibrary.org/obo/VO_", "http://purl.obolibrary.org/obo/vo.owl","\\d+"],
     ["snap", "http://www.ifomis.org/bfo/1.1/snap#", "http://www.ifomis.org/bfo/1.1","\\S+"],
     ["span", "http://www.ifomis.org/bfo/1.1/span#", "http://www.ifomis.org/bfo/1.1","\\S+"],
     ["span", "http://purl.obolibrary.org/obo/VO_", "http://purl.obolibrary.org/obo/vo.owl","\\d+"],
     ["NIF-GrossAnatomy", "http://ontology.neuinfo.org/NIF/BiomaterialEntities/NIF-GrossAnatomy.owl#",
      "http://ontology.neuinfo.org/NIF/BiomaterialEntities/NIF-GrossAnatomy.owl","birnlex_\\d+"]];

my @valid_externals = map {$_->[0]} @{$externals_table};

sub findit 
  { my $term = @_[0];
    grep {my $re1=$_->[0].":".$_->[3];my $re2=$_->[1].$_->[3];($term=~/$re1/ || $term=~/$re2/)} @{$externals_table}
  }

findit($child) or die "child term '$child' doesn't look like a valid id. The term should be from one of the following ontologies: @valid_externals";

($parent =~ /OBI(:|_)\d+/ || findit($parent)) or die "parent term '$parent' doesn't look like a valid id. The term should be from one of the following ontologies: @valid_externals";

-e $branchpath or die "$branchpath doesn't exist";

my ($parenturi,$childuri);

if ($child =~ /(.*?):(.*)$/)
{ my ($ont,$id) = ($1,$2); 
  my @found = findit($child);
  $childuri= @found[0]->[1].$id;
}
else { $childuri =~ $child; }
$DB::single=1;
if ($parent =~ /^(OBI(:|_)\d+)$/)
{ $parenturi = "http://purl.obofoundry.org/obo/$1" }
elsif ($parent =~ /^http/)
{ $parenturi = $parent }
elsif( $parent =~ /(.*?):(.*)$/)
{ my ($ont,$id) = ($1,$2);
  my @found = findit($parent);
  $parenturi= @found[0]->[1].$id;
}

(($parent=~ /^OBI(_|:)/) || ($parent=~ /^(snap|span):/) || `grep '<owl:Class rdf:about="$parenturi">' $branchpath`) 
    or die "$parenturi not present. Please use this script to add it then try again.\n";

!`grep '<owl:Class rdf:about="$childuri">' $branchpath` 
    or die "$childuri already present, so not adding it again";

my $template =<<EOF
  <owl:Class rdf:about="_CHILD_">
    <rdfs:subClassOf rdf:resource="_PARENT_"/>
    <IAO_0000412 rdf:resource="_ONT_"/>
  </owl:Class>
EOF
    ;

my @found = findit($child);
my $onturi = @found[0]->[2];

$template =~ s/_ONT_/$onturi/e;
$template =~ s/_CHILD_/$childuri/e;
$template =~ s/_PARENT_/$parenturi/e;

print "child: $childuri\n"."parent: $parenturi\n"."ontology: $onturi\n";
print "adding to $branchpath:\n$template\n";

open EXTERNAL, "<$branchpath" or die "can't open $branchpath to read";
my @lines = <EXTERNAL>;
close EXTERNAL;
open EXTERNAL, ">$branchpath" or die "can't open $branchpath to write";
foreach (@lines)
{ if (/<\/rdf:RDF>/)
  { print EXTERNAL $template,"$_\n" }
  else 
  { print EXTERNAL $_}
}
close EXTERNAL;


