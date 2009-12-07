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

my $valid_child_pattern = "(http:\/\/purl.org\/obo\/owl\/"
    ."(".join("",map "$_#$_\_|", @valid_externals).")(\\d+)\$)|"
    ."(".join(":(\\d+)\$|", @valid_externals).")";

my $valid_parent_pattern = "(http:\/\/purl.org\/obo\/owl\/"
    ."(".join("",map "$_#$_\_|", @valid_externals).")(\\d+)\$)|"
    ."(".join(":(\\d+)\$|", @valid_externals).")|OBI_\\d+\$";

$child =~ /$valid_child_pattern/i or die "child term '$child' doesn't look like a valid id. The term should be from one of the following ontologies: @valid_externals";
$parent =~ /$valid_parent_pattern/i or die "parent term '$parent' doesn't look like a valid id. The term should be from one of the following ontologies: @valid_externals";
-e $branchpath or die "$branchpath doesn't exist";

my ($parenturi,$childuri);

if ($child =~ /(.*?):(.*)$/)
{ my ($ont,$id) = ($1,$2); 
  $childuri = "http://purl.org/obo/owl/".uc($ont)."#".uc($ont)."_".$id;
}
else { $childuri =~ $child; }

if ($parent =~ /^(OBI_\d+)$/)
{ $parenturi = "http://purl.obofoundry.org/obo/$1" }
elsif ($parent =~ /^http/)
{ $parenturi = $parent }
elsif( $parent =~ /(.*?):(.*)$/)
{ my ($ont,$id) = ($1,$2);
  $parenturi = "http://purl.org/obo/owl/".uc($ont)."#".uc($ont)."_".$id;
}

(($parent=~ /^OBI_/) || `grep '<owl:Class rdf:about="$parenturi">' $branchpath`) 
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

my $onturi = $childuri;
$onturi =~ s/#.*//;

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


