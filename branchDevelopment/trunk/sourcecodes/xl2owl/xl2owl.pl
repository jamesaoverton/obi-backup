#!/opt/local/bin/perl -w

# Author: Jason Greenbaum (jgbaum@gmail.com)
# Date: February 5, 2008
# Version: 0.1

# Descritpion
#
# This program will take the name of a csv file with terms and an OWL file
# in which to place them.  It will generate the OWL and insert it into the OWL
# file.  It will save a backup of the OWL file before it makes any
# modifications.  It will also perform the opposite conversion, OWL to CSV.

# TODO:
# 1. read in other OWL files to identify OBI terms & enforce auto_ID
# 2. write documentation
# 3. implement gui

use strict;
use Data::Dumper;
use Getopt::Long;
use Switch;
use File::Copy;
use XML::Simple qw(:strict);
use Encode;

my ($csvin_file,$csvout_file,$owlin_file,$owlout_file,$help);
my $delim = "\t";
my $action = "1";
GetOptions ("tabin|ti=s" => \$csvin_file,
	    "tabout|to=s" => \$csvout_file,
	    "owlin|oi=s"   => \$owlin_file,
	    "owlout|oo=s" => \$owlout_file,
	    "delimiter|d=s" => \$delim,
	    "action|a=i" => \$action,
	    "help|h" => \$help,
    );

my $USAGE = <<END;

SYNOPSIS

perl xl2owl.pl -a [options]


OPTIONS

    --action|-a     Action to perform. Options are:
                    1 - Add terms to OWL file from tab-delimited text
                    2 - Create tab-delimited text from OWL

    --tabin|-ti     tab-delimited input: Name of the tab-delimited file which to add/convert to 
                    OWL output file

    --tabout|-to    tab-delimited output: Name of the tab-delimited file to create from the OWL
                    input

    --owlin|-oi	    OWL input: Name of the OWL file from which terms/headers should be extracted

    --owlout|-oo    OWL output: Name of the OWL file to create or add terms to

    --delimiter|-d  Delimiter used in the tab-delimited file [defalut = TAB]

    --help|-h       Print this help screen


The user must always specify an action.  Following is a brief descritpion of each action and their
required and optional parameters.

1) Add terms to an OWL file from tab-delimed file
Required parameters: --tabin, --owlin, --owlout

2) Create a tab-delimited file from OWL
Required parameters: --owlin, --tabout


END

die $USAGE if ($help);


switch ($action) {
    case 1 { insert_terms_from_csv($csvin_file,$owlin_file,$owlout_file,$delim) }
    case 2 { create_csv_from_owl($owlin_file,$csvout_file) }
    else   { die " \
 Unknown action: $action \
 Please choose from the following actions:\
 1: Insert terms into an OWL file from a CSV\
 2: Extract terms from an OWL file to a CSV\n\n" }
}


# This will return an array containing classes represented in XML format
sub csv2xml {

    my ($file,$delim) = @_;

    my @csv_terms = read_delim( $file, $delim );
    my %csv_terms = array2hash( \@csv_terms, "label" );
    my @xml_terms;
    foreach my $key (keys %csv_terms) {
	push @xml_terms, term2xml($csv_terms{$key});
    }

    return @xml_terms;

}

# This will return a class object, suitable for inclusion in an XML object. It will take in an
# array of anonymous hashes that specify the attributes of the class
sub mk_class {

    my $specs = shift;
    my $term; # this is the class object that will be returned

    my $datatype = "http://www.w3.org/2001/XMLSchema#string";

    # iterating through the specifications to create the term
    foreach my $key (keys %$specs) {
	next if ($key eq "rdfs:subClassOf");
	foreach my $val (@{$specs->{$key}}) {
	    my $attr = mk_attribute((name => $key,content => $val, "rdf:datatype" => $datatype));
	    if ($key eq "rdf:about") {
		$attr = mk_attribute((name => $key,content => $val));
	    }
	    $term = add_attribute_to_term($term,$attr);
	}
    }

    # now taking care of subclassof
    if ($specs->{"rdfs:subClassOf"}) {
	foreach my $s (@{$specs->{"rdfs:subClassOf"}}) {
	   # my $subclassof = {
	#	"owl:Class" => [
	#	    {
	#		"rdf:about" => $s
	#	    }
	#	    ]
	#    };
	    my $subclassof = {
		"rdf:resource" => $s
	    };
	    push @{$term->{"rdfs:subClassOf"}}, $subclassof;
	}
    }
    
    return $term;
}

# this takes a hash representation of a term and converts it to xml
sub term2xml {

    my ($term) = @_;

    # each term must have a class and rdfs label
    die "Term must have class" unless ( $term->{class} );
    #die "Term must have label" unless ( $term->{label} );

    my $class_def = {
	"rdf:about" => [ $term->{URI} . "#" . $term->{class}],
	#"rdfs:label" => [$term->{label}],
	#"rdfs:subClassOf" => [$term->{parent_URI} . "#" . $term->{parent_class}],
	};

    if ($term->{label}) {
	$class_def->{"rdfs:label"} = [$term->{label}];
    }

    if (($term->{parent_URI}) && ($term->{parent_class})) {
	$class_def->{"rdfs:subClassOf"} = [$term->{parent_URI} . "#" . $term->{parent_class}];
    }

    # now taking care of the remaining elments
    for ( my $i = 0 ; $i < @{ $term->{elements} } ; $i++ ) {
        my ( $key, $value ) = ( each %{ $term->{elements}->[$i] } );
	push @{$class_def->{$key}}, $value;
    }

    return mk_class($class_def);
}

# This will add an attribute to an XMLin-formatted term
sub add_attribute_to_term {

    my ($class,$attr) = @_;

    my $attr_name = $attr->{name};

    if (keys %{$attr->{values}} > 1) {
	push @{$class->{$attr_name}}, $attr->{values};
    } else {
	$class->{$attr_name} = $attr->{values}->{content};
    }
    
    return $class;

}

# This will take a filename as an argument and return an XMLin object
sub get_xml {

    my $file = shift;

    my $xs = XML::Simple->new(
	ForceArray => 1,
	KeyAttr => [],
	);

    return $xs->XMLin($file);

}

# this will add/change an attribute record to/of a particular class
sub add_attribute_to_xml {

    my ($xml,$uri,$id,$attr,$replace) = @_;

    # first we find the class
    foreach my $class (@{$xml->{"owl:Class"}}) {
	next unless ($class->{"rdf:about"} eq "$uri\#$id");    
	my ($attr_name) = $attr->{name};
	# if more than one value, then we mke an array with an anonymlous hash, otherwise, we just make the
	# hash
	if (keys %{$attr->{values}} > 1) {
	    if ($replace) {
		@{$class->{$attr_name}} = ();
		$class->{$attr_name}->[0] = $attr->{values};
	    } else {
		push @{$class->{$attr_name}},$attr->{values};
	    }
	} else {
	    if ($replace) {
		$class->{$attr_name} = $attr->{values}->{content};
	    } else {
		$class->{$attr_name}->[0] = $class->{$attr_name};
		push @{$class->{$attr_name}},$attr->{values}->{content};
	    }
	}
	last;
    }
    
    return 0;
}

# Attributes will be structured like so:
# 
# $attribute->{
#              name => "name",
#              values => {
#                        content => "content",
#                        something => "something",
#                        ....
#              }
# }
# this function will take in a hash containing the name and values for the attribute
# and return an attribute record
sub mk_attribute {
    my (%attr) = @_;

    my $attribute = {
	name => $attr{name}
    };

    foreach my $key (keys %attr) {
	next if $key eq "name";
	$attribute->{values}->{$key} = $attr{$key}
    }

    return $attribute;
}

# one of the following three subroutines should be called

# this will insert terms from a csv file into an owl file
sub insert_terms_from_csv {

    my ($csvin_file,$owlin_file,$owlout_file,$delim) = @_;

    # first we retrieve the terms from the csv file
    my @new_terms = csv2xml($csvin_file,$delim);

    # now we index the terms
    my %in_new = ();
    foreach my $term(@new_terms) {
	$in_new{$term->{"rdf:about"}} = 1;
    }

    # next we read in the terms from the owl file
    my @owl_classes;
    my $xml=get_xml($owlin_file);
    foreach my $class (@{$xml->{"owl:Class"}}) {
	push @owl_classes, $class;
    }

    # now iterate through existing terms and push them onto the new terms array,
    # unless there is a corresponding term in the array
    foreach my $term(@owl_classes) {
	next if ($in_new{$term->{"rdf:about"}});
	push @new_terms, $term;
    }
    $xml->{"owl:Class"} = \@new_terms;

    # now we copy to backup file before writing output
    my $backup_file = $owlout_file . ".bak";
    copy($owlout_file,$backup_file);

    my $xout = XMLout($xml,KeyAttr=>[],AttrIndent=>1,XMLDecl=>1,RootName=>"rdf:RDF");

    # we must encode the string as utf8
    $xout = encode("utf8",$xout);

    open (OUTF,">$owlout_file");
    print OUTF $xout;
    close OUTF;

    return 0;
}

# this will extract all of the terms from an OWL file and put them into csv format
sub create_csv_from_owl {

    my ($owl_file,$out_file) = @_;

    # first we read in the terms from the owl file
    my @owl_classes;
    my $xml=get_xml($owl_file);
    foreach my $class (@{$xml->{"owl:Class"}}) {
	push @owl_classes, $class;
    }

   array2csv(\@owl_classes,$out_file);

   return 0;
}

# this does the work for create_csv_from_owl
sub array2csv {

    my ($a_ref,$outfile) = @_;

    my %fields;

    foreach my $h_ref (@$a_ref) {
	my @headers = keys %$h_ref;
	my %row_fields;
	foreach my $h (@headers) {
	    # we skip over rdf:about since it is not an array
	    next if ($h eq "rdf:about");
	    next if ($h eq "rdf:ID");
	    next if ($h eq "rdfs:subClassOf");
	    $row_fields{$h} = @{$h_ref->{$h}};
	    if ($fields{$h}) {
		if ($row_fields{$h} > $fields{$h}) {
		    $fields{$h} = $row_fields{$h};
		}
	    } else {
		$fields{$h} = @{$h_ref->{$h}};
	    }
	}
    }

    # the @fields array holds the fields that make it into the CSV document
    # the @unique_fields array is identical to the @fields array, except it doesn't include redundant
    # field names
    my @fields = ("class","label","URI","parent_class","parent_label","parent_URI");
    my @unique_fields = ("class","label","URI","parent_class","parent_label","parent_URI");

    foreach my $f (keys %fields) {
	next if ($f eq "rdfs:subClassOf");
	next if ($f eq "rdfs:label");
	if ($fields{$f} > 1) {
	    push @fields, $f;
	    push @unique_fields, $f;
	    for (my $i=1; $i<$fields{$f}; $i++) {
		push @fields, $f;
	    }
	} else {
	    push @fields, $f;
	    push @unique_fields, $f;
	}
    }

    open (OUTF, ">$outfile") || die "Can't open file $outfile for writing";

    my $header_row = join "\t", @fields;
    print OUTF $header_row, "\n";

    my $inferred_classes;
    # Now lets go through and print each line
    foreach my $h_ref (@$a_ref) {

	my @line = ();
	my $parent_class_uri;	    
    
	my $classholder;
	if ($h_ref->{"rdf:about"}) {
	    $classholder = $h_ref->{"rdf:about"};
	} else {
	    $classholder = $h_ref->{"rdf:ID"};
	}

	# for each subclassof entry, we determine if it is a true subclass definition or some
	# funky owl
	foreach my $c (@{$h_ref->{"rdfs:subClassOf"}}) {
	    if ($c->{"rdf:resource"}) {
		$parent_class_uri = $c->{"rdf:resource"};
	    } elsif ($c->{"owl:Class"}) {
		if ($c->{"owl:Class"}->[0]->{"rdf:about"}) {
		    $parent_class_uri = $c->{"owl:Class"}->[0]->{"rdf:about"};
		} elsif ($c->{"owl:Class"}->[0]->{"rdf:ID"}) {
		    $parent_class_uri = $c->{"owl:Class"}->[0]->{"rdf:ID"};
		} else {
		    $c->{id} = $classholder;
		    push @{$inferred_classes->{"class"}}, $c;
		}
	    } else {
		# this means that there is some funky owl that cannot be represented as csv, so
		# we save these structures to another file (.xtra)
		$c->{id} = $classholder;
		push @{$inferred_classes->{"class"}}, $c;
	    }
	}

	my $uri = "";
	my $class = "";
	# now we take care of the static portion of the csv file
	if ($classholder =~ /\#/) {
	    ($uri,$class) = split(/\#/,$classholder);
	} else {
	    $class = $classholder;
	}
	my $label = "";
	if ($h_ref->{"rdfs:label"}) {
	    $label = $h_ref->{"rdfs:label"}->[0]->{content};
	}
	my $parent_uri = "";
	my $parent_class = "";
	if ($parent_class_uri) {
	    if ($parent_class_uri =~ /\#/) {
		($parent_uri,$parent_class) = split(/\#/,$parent_class_uri);
	    } else {
		$parent_class = $parent_class_uri;
	    }
	};
	push @line, ($class,$label,$uri,$parent_class,"",$parent_uri);

	# here we take care of the dynamic portion of the csv
	foreach my $f (@unique_fields[6..$#unique_fields]) {
	    for (my $i=0; $i<$fields{$f}; $i++) {
		if ($h_ref->{$f}->[$i]->{content}) {
		    my $value = $h_ref->{$f}->[$i]->{content};
		    #replacing newlines
		    $value =~ s/[\n\r]+/\\n/g;
		    push @line, $value;		    
		} else {
		    push @line, "";
		}
	    }
	}

	my $line = join "\t", @line;
	print OUTF $line, "\n";
    }

    # if we found any funky owl, it will be in the $inferred_classes hash in XMLin format
    if ($inferred_classes) {

	open (XTRA, ">$outfile.xtra");
	my $xout = XMLout($inferred_classes,KeyAttr=>[],AttrIndent=>1,XMLDecl=>1);
	
	$xout = encode("utf8",$xout);

	print XTRA $xout, "\n";
	close XTRA;

    }
    close OUTF;

    return 0;

}

# this will open both a csv & owl file, and output an OWL file containing the non-redundant
# terms
sub create_owl_from_csv {

    my ($csv_file,$owl_file,$delim) = @_;

    my $xml=get_xml($owl_file);

    my @new_terms = csv2xml($csv_file,$delim);

    # replacing whatever was in $xml->{owl:class} with the new terms
    $xml->{"owl:Class"} = \@new_terms;

    # determining if there was any funky owl that couldn't be incorporated in the csv file
    # here, we retrieve it an put it into the xml structure
    $xml = check_extra($xml,$csv_file);

    # now we copy to backup file before writing output
    my $backup_file = $owl_file . ".bak";
    copy($owl_file,$backup_file);

    my $xout = XMLout($xml,KeyAttr=>[],AttrIndent=>1,XMLDecl=>1,RootName=>"rdf:RDF");
    $xout = encode("utf8",$xout);

    open (OUTF,">$owl_file");
    print OUTF $xout;
    close OUTF;

    return 0;

}

# This will check for the existence of extra subclass declarations that couldn't
# be captured in csv format - they will exist in a file with a .xtra extension
sub check_extra {

    my ($xml, $csv_file) = @_;

    # here we check to see if there are extra subclasses defined
    my $xtra_file = $csv_file . ".xtra";
    if (-e $xtra_file) {
	my $xtra = get_xml($xtra_file);
	# iterating through each of the extra classes
	foreach my $sc (@{$xtra->{class}}) {
	    # iterating through each of the classes from the file
	    foreach my $c (@{$xml->{"owl:Class"}}) {
		#inserting the subclassof declarations if the id matches
		if ($c->{"rdf:about"} eq $sc->{id}) {
		    delete $sc->{id};
		    push @{$c->{"rdfs:subClassOf"}}, $sc;
		    last;
		}
	    }
	}
    }

    return $xml;

}


# this will convert the array to a hash
sub array2hash {

    my ( $array_ref, $index ) = @_;

    my %hash_rep;

    # the first six elements will be hash keys and the remaining elements will be stored
    # in an array of hashes, since there can be more than 1 per class

    foreach my $e (@$array_ref) {
        my @elements;
        for ( my $i = 6 ; $i < @$e ; $i++ ) {
            push @elements, $e->[$i];
        }
        $hash_rep{ $e->[0]->{class} } = {
            class         => $e->[0]->{class},
            label         => $e->[1]->{label},
            URI           => $e->[2]->{URI},
            parent_class  => $e->[3]->{parent_class},
            parent_label  => $e->[4]->{parent_label},
            parent_URI    => $e->[5]->{parent_URI},
            elements      => \@elements
        };
    }

    return %hash_rep;

}


# This function takes in a tab-delimited filename, reads in the file,
# and returns and array of records with fields corresponding to the
# headers in the file.  If no headers are present in the file, a reference
# to an array of headers can be passed.
sub read_delim {

    my ( $infile, $delim, $header_ref ) = @_;

    open( INF, "<$infile" ) || die("Cannot open file: $infile for reading\n");
    $/=undef;
    my $file=<INF>;
    $/="\n";
    my @lines=split /[\r\n]+/, $file;
    close INF;

    my @headers = ();

    if ($header_ref) {
        @headers = @$header_ref;
    }
    else {
        @headers = split( /$delim/, shift @lines );
    }

    # Here we strip the quotes from the text fields and replace
    # spaces with underscores
    for ( my $i = 0 ; $i < @headers ; $i++ ) {

        $headers[$i] =~ s/\"//g;
        $headers[$i] =~ s/\s+/\_/g;

    }

    my @records = ();
    my $index   = 0;
    foreach my $line (@lines) {

        my @fields = split( /$delim/, $line );

        # Here we strip the quotes from the text fields
        for ( my $i = 0 ; $i < @headers ; $i++ ) {
            if ( $fields[$i] ) {
                $fields[$i] =~ s/\"//g;
                $records[$index][$i] = { $headers[$i] => $fields[$i] };
            }
            else {
                $records[$index][$i] = { $headers[$i] => "" };
            }
        }
        $index++;

    }

    return @records;
}
