use strict;

# Rewrite the old OBI namespace into new purls. Beware UGLY HACKS below

# Policy here. TBD.

my $idNamespace = "http://purl.obofoundry.org/obo/"; # conservative, but less elegant: http://purl.org/obo/OBI/. Current OBO practice: http://purl.org/obo/OBI#
my $namedclassNamespace = "http://purl.obofoundry.org/obo/";
my $propertyNamespace = "http://purl.obofoundry.org/obo/"; # can't stay at top level, since no OBI differentiation with OBI_
my $individualNamespace = "http://purl.obofoundry.org/obo/";

my $debug = 0;

# suck in obi.owl to know which files to process
open TOP, "<obi.owl" or die("can't find obi.owl");
my @lines = <TOP>;
close TOP;

my $copydir = "newids/"; # write the rewritten files here

my %used; # to record used numeric ids

# extract the names of the branches
my @obiParts = grep {/<owl:imports rdf:resource="http:\/\/obi.sourceforge.net\/ontology\/OBI\/(.*)\.owl"/;$1} @lines;
my @obiParts = map { s/.*\/([A-Za-z.-]*)\.owl.*/$1/;chomp $_ ; $_} @obiParts;


my %uriReplacements;
my %tagReplacements;

# Compute all rewrites Logic:
#  Read the uri report created by lisp, as that is the only safe way to determine which URIs are for properties,classes, etc.
#  Iterate over them, collecting rewrites, and postponing new numeric id allocation until we know which ids are already used.
#  Finally, allocate new ids for alphanumeric names that need an id.

sub computeReplacements
{ open URILIST, "<uri-report.txt";
  my @todo;
  while (<URILIST>)
  { /(\S+)\s+(\S+)/;
    my ($type,$uri) = ($1,$2);
    my $rewrite = maybeRewriteURI($type,$uri);
    if (defined $rewrite)
    { if ($rewrite)
      { $uriReplacements{$uri}=$rewrite; }
      else { push @todo,$uri };
    }
    else {$debug && print "don't bother ",$uri,"\n"}
  }
  close URILIST;
  foreach (@todo)
  { my $newid = allocateNewId();
    $uriReplacements{$_} = $idNamespace."OBI_".$newid;
    s/.*[\/#]//;
    $tagReplacements{$_}="OBI_".$newid;
    $debug && print $_,"=>",$uriReplacements{$_},"\n";
  }
}

# Rewrite one URI Logic:
#  If we already are an OBI_\d+ then rewrite to $idNamespace but normalize to 7 digits with leading 0s and return new.
#  If we are a class and don't currently have an OBI_\d+, return 0. Caller will allocate new id.
#  If we are a property and not an OBI_\d+ then rewrite to $propertyNamespace and return new.
#  If we are an individual and not an OBI_\d+ then rewrite to $individualNamespace and return new.
#  Otherwise leave alone (return undef)

sub maybeRewriteURI
{ my ($type,$uri) = @_;
  $debug && print "in: $type $uri\n";
  if ($type =~ /Class|Property|Individual/)
  {if ($uri =~ /http:\/\/obi\.sourceforge\.net\/ontology\/OBI.owl#(.*)/)
   { my $localname = $1;
     if ( $localname =~ /OBI_(\d+)/)
     { if (length($1)>7) { return 0 } # too long - allocate new id
       my $newnum = sprintf("%07d",$1);
       if ($used{$newnum}) # collision, allocate new id
       { return 0 }
       else
       { $used{$newnum} = 1;
	 return($idNamespace."OBI_".$newnum)
       }
     }
#     elsif ($localname =~ /CurationStatus|EnumerationClass/)
#     { return $namedclassNamespace.$localname }
     else
     { return(0) }
   }
   else {return undef}
  }
  elsif ($type =~ /Property/)
  { if ($uri =~ /http:\/\/obi\.sourceforge\.net\/ontology\/OBI.owl#(.*)/)
    { if ($1 =~ /OBI_\d+/)
      { $uri = $idNamespace.$1; }
      else
      { $uri = $propertyNamespace.$1 }
    }
    else
    { return (undef) }
  }
  elsif ($type =~ /Individual/)
  { if ($uri =~ /http:\/\/obi\.sourceforge\.net\/ontology\/OBI.owl#(.*)/)
    { if ($1 =~ /OBI_\d+/)
      { $uri = $idNamespace.$1; }
      else
      { $uri = $individualNamespace.$1 }
    }
    else
    { return (undef) }
  }
}

# Allocated a new id Logic:
#  Use the next numeric id that hasn't already been used. 
my $count=1;
sub allocateNewId
{ my $test;
  for ($test = sprintf("%07d",$count); $used{$test}; $count++) {$test = sprintf("%07d",$count)}
  $used{$test}=1;
  $test;
}

sub replacenames
{ my $count=1;
  foreach my $part ( @obiParts) {
      my $path = "$part".".owl";
      open PART, "<$path" or die("Trouble loading $path");
      my $copypath = $copydir.$part.".owl";
      open PARTCOPY, ">$copypath" or die ("Trouble writing $path");
      my $copy;
      while (<PART>) {
	  s/\s*xmlns=.*/   xmlns="$propertyNamespace"/;
	  s/\s*xmlns:obi=.*/   xmlns:obi="$idNamespace"/;
	  s/\s*xml(ns){0,1}:(.+?)="http:\/\/obi.source.*\/(.*)/   xml$1:$2="$idNamespace\obi\/$3/;
	  my $pre = "curation_status><CurationStatus rdf:about=\"http://obi.sourceforge.net/ontology/OBI.owl";
	  s/curation_status\s*xml:lang="en"\s*>ready_for_release</$pre#ready_for_release\"\/></;
	  s/curation_status\s*xml:lang="en"\s*>metadata_incomplete</$pre#metadata_incomplete\"\/></;
	  s/curation_status\s*xml:lang="en"\s*>metadata_complete</$pre#metadata_complete\"\/></;
	  s/curation_status\s*xml:lang="en"\s*>uncurated</$pre#uncurated\"\/></;
	  s/curation_status\s*xml:lang="en"\s*>pending_final_vetting</$pre#pending_final_vetting\"\/></;
	  s/curation_status\s*xml:lang="en"\s*>definition_incomplete.*?</$pre#metadata_incomplete\"\/></;
#	  s/\s*xml:base=.*\/(.*)/   xml:base="$idNamespace\obi\/$1"/;
	  s/rdf:(about|id|resource)="(.*?)"/"rdf:".$1."=\"".($uriReplacements{$2}||$2)."\""/ge;
	  s/(<\/{0,1})([A-Za-z0-9_]*)/$1.($tagReplacements{$2}||$2)/ge; 
	  # UGLY HACK UGLY HACK. We have a few instances currently, and the logic above doesn't handle them so clobber!
	  s/(<\/{0,1})OBI_187/$1\obi:OBI_0000187/g;
	  # And don't forget that bit in externalderived.owl - Uncle: I admit that RDF/XML is an abomination 
	  s/xmlns:ns0pred="http:\/\/obi.sourceforge.net\/ontology\/OBI.owl#"/xmlns:ns0pred="$propertyNamespace"/;
	  s/(\/{0,1}ns0pred:)([A-Za-z0-9_]*)\s*xmlns:ns0pred="$propertyNamespace/$1.($tagReplacements{$2}||$2)." xmlns:ns0pred=\"$propertyNamespace"/sge;
	  s/(\/ns0pred:)([A-Za-z0-9_]*)/$1.($tagReplacements{$2}||$2)/sge;
	  # UGLY HACK UGLY HACK.
	  print PARTCOPY $_; 
      }
      close PART;
      close PARTCOPY;
  }
}

computeReplacements();
replacenames();

$DB::single=1;1;

$debug && print join("\n",keys %uriReplacements);
