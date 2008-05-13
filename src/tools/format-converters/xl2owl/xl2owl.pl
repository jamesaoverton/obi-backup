#!/usr/bin/perl

# Author: Jason Greenbaum (jgbaum@gmail.com)
# Web interface available at: http://purl.oclc.org/NET/jgbaum/xl2owl
# username & password: OBI

# Release Notes
# 
# Version 0.3 - May 13, 2008
# * Fixed handling of OBI_0000281 - curation_status instances
#
# Version 0.2 - April 25, 2008
# * Fixed URI handling for purls
# * URL in delimited text format now includes the entire URL, including the class ID
# * now handles owl:equivalentClass tags by placing them in a separate text file with
#   a .equiv extension - these will be read in during conversion back to owl and placed under
#   their respective class
#
# Version 0.1 - February 25, 2008
# * Initial release

# Descritpion
#
# This program will take the name of a csv file with terms and an OWL file
# in which to place them.  It will generate the OWL and insert it into the OWL
# file.  It will save a backup of the OWL file before it makes any
# modifications.  It will also perform the opposite conversion, OWL to CSV.

# TODO:
# 1. read in other OWL files to identify OBI terms & enforce auto_ID
# 2. write documentation
# 3. Include option to specify the minimal metadata to be included in each class
# 4. Keep track of BFO class, in case OBI class disappears

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Switch;
use File::Copy;
use XML::Simple qw(:strict);
use Encode;
use URI;

# We must set this environment variable to XML::Parser, so that the .xtra files are
# parsed without an error ("undedeclared prefix").
$XML::Simple::PREFERRED_PARSER = "XML::Parser";

my (
    $csvin_file, $csvout_file, $owlin_file, $owlout_file,
    $help,       $replace,     $del_empty
);
my $delim  = "\t";
my $action = "1";

my $base_uri;

GetOptions(
    "tabin|ti=s"    => \$csvin_file,
    "tabout|to=s"   => \$csvout_file,
    "owlin|oi=s"    => \$owlin_file,
    "owlout|oo=s"   => \$owlout_file,
    "delimiter|d=s" => \$delim,
    "action|a=i"    => \$action,
    "del_empty|r"   => \$del_empty,
    "replace"       => \$replace,
    "help|h"        => \$help,
);

my $USAGE = <<END;

xl2owl - Version 0.2

Performs 2-way conversion between OWL format and tab-delimited text
(for import into spreadsheet).

PURL: http://purl.oclc.org/NET/jgbaum/xl2owl

There is a web server implementing this tool at the above address.  This is the preferred
method of use.

SYNOPSIS

Running from the source code:

perl xl2owl.pl -a [1:2] [options]

Running an executable:

xl2owl[.exe] -a [1:2] [options]


OPTIONS

    --action|-a     Action to perform. Options are:
                    1 - Add terms to OWL file from tab-delimited text
                    2 - Create tab-delimited text from OWL

    --tabin|-ti     tab-delimited input: Name of the tab-delimited file which
                    to add/convert to OWL output file

    --tabout|-to    tab-delimited output: Name of the tab-delimited file to
                    create from the OWL input

    --owlin|-oi	    OWL input: Name of the OWL file from which terms/headers
                    should be extracted

    --owlout|-oo    OWL output: Name of the OWL file to create or add terms to

    --delimiter|-d  Delimiter used in the tab-delimited file [defalut = TAB]

    --del_empty|-r  Do not include annotation properties that are empty in the
                    owl output file

    --replace       Replace all classes in OWL file with those from tab-delimited file

    --help|-h       Print this help screen

END

die $USAGE if ($help);

switch ($action) {
    case 1 {
        insert_terms_from_csv( $csvin_file, $owlin_file, $owlout_file, $delim,
            $replace );
    }
    case 2 { create_csv_from_owl( $owlin_file, $csvout_file ) }
    else {
        die " \
 Unknown action: $action \
 Please choose from the following actions:\
 1: Insert terms into an OWL file from a CSV\
 2: Extract terms from an OWL file to a CSV\n\n";
    }
}

# This will return an array containing classes represented in XML format
sub csv2xml {

    my ( $file, $delim ) = @_;

    my @csv_terms = read_delim( $file, $delim );
    my %csv_terms = array2hash( \@csv_terms, "label" );
    my @xml_terms;
    foreach my $key ( keys %csv_terms ) {
        push @xml_terms, term2xml( $csv_terms{$key} );
    }

    return @xml_terms;

}

# This will return a class object, suitable for inclusion in an XML object. It will take in an
# array of anonymous hashes that specify the attributes of the class
sub mk_class {

    my $specs = shift;
    my $term;    # this is the class object that will be returned

#    my $datatype = "http://www.w3.org/2001/XMLSchema#string";

    # iterating through the specifications to create the term
    foreach my $key ( keys %$specs ) {
        next if ( $key eq "rdfs:subClassOf" );
        foreach my $val ( @{ $specs->{$key} } ) {
            my $attr;
            if ( $key eq "rdf:about" ) {
                $attr = mk_attribute( ( name => $key, content => $val ) );
            } elsif ($key eq "OBI_0000281") {
		# first lets test if the value is defined.  If not, we advance to the next value
		# Note that handling of this should be much cleaner
		#print Dumper $val;
		#print qq/$key,$val->{"rdf:resource"},/;
		if ($val->{"rdf:resource"}) {
		    #print "in\n";
		    $attr = mk_attribute( (name => $key, "rdf:resource" => $val ));
		} else {
		    next;
		}
            } else {
               $attr = mk_attribute(
                ( name => $key, content => $val, "xml:lang" => "en" )
            );
                
            }
            # OBI curation status requires special consideration
            #if ( $key eq "OBI_0000281" ) {
            ##    $attr = mk_attribute(( name => "OBI_0000281", "rdf:resource" => $val));
            #}            
            $term = add_attribute_to_term( $term, $attr );
        }
    }

    # now taking care of subclassof
    if ( $specs->{"rdfs:subClassOf"} ) {
        foreach my $s ( @{ $specs->{"rdfs:subClassOf"} } ) {

            # my $subclassof = {
            #	"owl:Class" => [
            #	    {
            #		"rdf:about" => $s
            #	    }
            #	    ]
            #    };
            my $subclassof = { "rdf:resource" => $s };
            push @{ $term->{"rdfs:subClassOf"} }, $subclassof;
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
        "rdf:about" => [ $term->{URI} ],

      #"rdfs:label" => [$term->{label}],
      #"rdfs:subClassOf" => [$term->{parent_URI} . "#" . $term->{parent_class}],
    };

    if ( $term->{label} ) {
        $class_def->{"rdfs:label"} = [ $term->{label} ];
    }

    if ( $term->{parent_URI} ) {
        $class_def->{"rdfs:subClassOf"} = [ $term->{parent_URI} ];
    }

    #print Dumper $term;

    # now taking care of the remaining elments
    for ( my $i = 0 ; $i < @{ $term->{elements} } ; $i++ ) {
        my ( $key, $value ) = ( each %{ $term->{elements}->[$i] } );
        if ($key eq "OBI_0000281") {
            push @{$class_def->{OBI_0000281}}, {"rdf:resource" => $value};
            #print "$value\n"     
        } else {
            push @{ $class_def->{$key} }, $value;
        }
    }

    #print Dumper $class_def;

    return mk_class($class_def);
}

# This will add an attribute to an XMLin-formatted term
sub add_attribute_to_term {

    my ( $class, $attr ) = @_;

    my $attr_name = $attr->{name};

    if ( keys %{ $attr->{values} } > 1 ) {
        push @{ $class->{$attr_name} }, $attr->{values};
       
    } elsif ($attr->{name} eq "OBI_0000281") {
        $class->{$attr_name} = $attr->{values}->{"rdf:resource"};
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
        KeyAttr    => [],
    );

    return $xs->XMLin($file);

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

    my $attribute = { name => $attr{name} };

    foreach my $key ( keys %attr ) {
        next if $key eq "name";
        $attribute->{values}->{$key} = $attr{$key};
    }

    return $attribute;
}

# one of the following three subroutines should be called

# this will insert terms from a csv file into an owl file
sub insert_terms_from_csv {

    my ( $csvin_file, $owlin_file, $owlout_file, $delim, $replace ) = @_;

    # first we retrieve the terms from the csv file
    my @new_terms = csv2xml( $csvin_file, $delim );

    # now we index the terms
    my %in_new = ();
    foreach my $term (@new_terms) {
        $in_new{ $term->{"rdf:about"} } = 1;
    }

    # next we read in the owl file
    my $xml = get_xml($owlin_file);

    # unless we are supposed to replace all of the classes, we will read in the
    # terms from the owl file
    unless ($replace) {
        my @owl_classes;
        foreach my $class ( @{ $xml->{"owl:Class"} } ) {
            push @owl_classes, $class;
        }

    # now iterate through existing terms and push them onto the new terms array,
    # unless there is a corresponding term in the array
        foreach my $term (@owl_classes) {
            next if ( $in_new{ $term->{"rdf:about"} } );
            push @new_terms, $term;
        }
    }

    #Here we go through each term and remove any annotation properties that are
    # empty
    if ($del_empty) {
        delete_empty( \@new_terms );
    }

    $xml->{"owl:Class"} = \@new_terms;

    # here, we retrieve it an put it into the xml structure
    $xml = check_extra( $xml, $csvin_file );

    # here , we look for equivalent classes
    #$xml = check_equiv( $xml, $csvin_file );

    # now we copy to backup file before writing output
    my $backup_file = $owlout_file . ".bak";
    copy( $owlout_file, $backup_file );

    my $xout = XMLout(
        $xml,
        KeyAttr    => [],
        AttrIndent => 1,
        XMLDecl    => 1,
        RootName   => "rdf:RDF"
    );

    # we must encode the string as utf8
    $xout = encode( "utf8", $xout );

    open( OUTF, ">$owlout_file" );
    print OUTF $xout;
    close OUTF;

    return 0;
}

# this will go through each term and delete any annotation properties that are empty
sub delete_empty {

    my ($classes_ref) = @_;

    # iterating through each of the terms
    foreach my $term (@$classes_ref) {

        # iterating over the annotation properties
        foreach my $key ( keys %$term ) {

            #print Dumper $term->{$key};
            #delete $term->{$key} unless $term->{$key};

            next if ( ref( $term->{$key} ) ne "ARRAY" );

            # iterating through each element of the annotation property array
            for ( my $i = 0 ; $i < @{ $term->{$key} } ; $i++ ) {

                # first we get the keys of the hash
                my @keys = keys %{ $term->{$key}->[$i] };
                my %keys;

                # next we index them
                foreach my $k (@keys) {
                    $keys{$k} = 1;
                }

    # finally, we skip over the element if it does not contain a "content" field
                next unless $keys{content};

                # deleting the annotation property if the content is empty
                delete $term->{$key}->[$i]
                  unless $term->{$key}->[$i]->{content};
            }

            # completely deleting the annotation property if the array is empty
            delete $term->{$key} unless @{ $term->{$key} };
        }

        #print Dumper $term;

    }

}

# this will extract all of the terms from an OWL file and put them into csv format
sub create_csv_from_owl {

    my ( $owl_file, $out_file ) = @_;

    # first we read in the terms from the owl file
    my @owl_classes;
    my $xml = get_xml($owl_file);

    #print Dumper $xml;
    $base_uri = $xml->{"xml:base"};
    unless ($base_uri) {
        warn("no base URI specified in header\n");
    }

    #print "$base_uri\n";
    foreach my $class ( @{ $xml->{"owl:Class"} } ) {

        #print Dumper $class;
        push @owl_classes, $class;
    }

    array2csv( \@owl_classes, $out_file );

    return 0;
}

# this does the work for create_csv_from_owl
sub array2csv {

    my ( $a_ref, $outfile ) = @_;

    my %fields;

    foreach my $h_ref (@$a_ref) {
        my @headers = keys %$h_ref;
        my %row_fields;
        foreach my $h (@headers) {

            # we skip over rdf:about since it is not an array
            next if ( $h eq "rdf:about" );
            next if ( $h eq "rdf:ID" );
            next if ( $h eq "rdfs:subClassOf" );
            next if ( $h eq "owl:equivalentClass" );
            $row_fields{$h} = @{ $h_ref->{$h} };
            if ( $fields{$h} ) {
                if ( $row_fields{$h} > $fields{$h} ) {
                    $fields{$h} = $row_fields{$h};
                }
            } else {
                $fields{$h} = @{ $h_ref->{$h} };
            }
        }
    }

# the @fields array holds the fields that make it into the CSV document
# the @unique_fields array is identical to the @fields array, except it doesn't include redundant
# field names
    my @fields =
      ( "class", "label", "URI", "parent_class", "parent_label", "parent_URI" );
    my @unique_fields = @fields;

    foreach my $f ( keys %fields ) {
        next if ( $f eq "rdfs:subClassOf" );
        next if ( $f eq "rdfs:label" );
        next if ( $f eq "owl:equivalentClass" );
        next if ( $f eq "owl:disjointWith" );
        if ( $fields{$f} > 1 ) {
            push @fields,        $f;
            push @unique_fields, $f;
            for ( my $i = 1 ; $i < $fields{$f} ; $i++ ) {
                push @fields, $f;
            }
        } else {
            push @fields,        $f;
            push @unique_fields, $f;
        }
    }

    open( OUTF, ">$outfile" ) || die "Can't open file $outfile for writing";

    my $header_row = join "\t", @fields;
    print OUTF $header_row, "\n";

    my $inferred_classes;
    my $equivalent_classes;
    my $disjoint_classes;

    # Now lets go through and print each line
    foreach my $h_ref (@$a_ref) {

        my @line = ();

        my $uri_string;
        if ( $h_ref->{"rdf:about"} ) {
            $uri_string = $h_ref->{"rdf:about"};
        } else {
            $uri_string = $h_ref->{"rdf:ID"};
        }

        my $uri = URI->new($uri_string);

     # here we assume that if there is no scheme, we should use the base uri
     # however, if no base_uri is found in the file, we will throw a warning and
     # not append anything

        # if the uri doesn't include the full path
        unless ( $uri->scheme ) {

            #rint "not valid uri\n";
            $base_uri =~ s/\/$//;
            $uri        = URI->new( $base_uri . "/" . $uri_string );
            $uri_string = $uri->as_string;
        }

        #print $uri->as_string;

        my $parent_class_uri_string = "";

# for each subclassof entry, we determine if it is a true subclass definition or some
# funky owl
        foreach my $c ( @{ $h_ref->{"rdfs:subClassOf"} } ) {
            if ( $c->{"rdf:resource"} ) {
                $parent_class_uri_string = $c->{"rdf:resource"};
            } elsif ( $c->{"owl:Class"} ) {
                if ( $c->{"owl:Class"}->[0]->{"rdf:about"} ) {
                    $parent_class_uri_string =
                      $c->{"owl:Class"}->[0]->{"rdf:about"};
                } elsif ( $c->{"owl:Class"}->[0]->{"rdf:ID"} ) {
                    $parent_class_uri_string =
                      $c->{"owl:Class"}->[0]->{"rdf:ID"};
                } else {
                    $c->{id} = $uri_string;
                    push @{ $inferred_classes->{"class"} }, $c;
                }
            } else {

 # this means that there is some funky owl that cannot be represented as csv, so
 # we save these structures to another file (.xtra)
                $c->{id} = $uri_string;
                push @{ $inferred_classes->{"class"} }, $c;
            }
        }

        # now taking care of the equivalent classes
        foreach my $c ( @{ $h_ref->{"owl:equivalentClass"} } ) {
            $c->{id} = $uri_string;
            push @{ $equivalent_classes->{"class"} }, $c;
        }

        # now taking care of the disjoint classes
        foreach my $c ( @{ $h_ref->{"owl:disjointWith"} } ) {
            $c->{id} = $uri_string;
            push @{ $disjoint_classes->{"class"} }, $c;
        }

        my $class = "";

        # now we take care of the static portion of the csv file

        my @path = $uri->path_segments;

        if ( $uri->fragment ) {
            $class = $uri->fragment;
        } else {
            $class = $path[-1];
        }
        my $label = "";
        if ( ref( $h_ref->{"rdfs:label"} ) eq "ARRAY" ) {
            if ( !ref( $h_ref->{"rdfs:label"}->[0] ) ) {
                $label = $h_ref->{"rdfs:label"}->[0];
            } else {
                $label = $h_ref->{"rdfs:label"}->[0]->{content};
            }
        }

        # Here we deal with empty label fields...we set them to the empty string
        # instead of undef
        unless ($label) {
            $label = "";
        }

        my $parent_class     = "";
        my $parent_class_uri = URI->new($parent_class_uri_string);

        if ($parent_class_uri_string) {

         # if the uri doesn't include the full path, we will append the base_uri
            unless ( $parent_class_uri->scheme ) {

                #print "p: $parent_class_uri_string\n";
                #rint "not valid uri\n";
                $base_uri =~ s/\/$//;
                $parent_class_uri =
                  URI->new( $base_uri . "/" . $parent_class_uri_string );
                $parent_class_uri_string = $parent_class_uri->as_string;
            }

            my @ppath = $parent_class_uri->path_segments;

            if ( $parent_class_uri->fragment ) {
                $parent_class = $parent_class_uri->fragment;
            } else {
                $parent_class = $ppath[-1];
            }
        }
        push @line,
          (
            $class, $label, $uri_string, $parent_class, "",
            $parent_class_uri_string
          );

        #print Dumper $h_ref;

        # here we take care of the dynamic portion of the csv
        foreach my $f ( @unique_fields[ 6 .. $#unique_fields ] ) {
            for ( my $i = 0 ; $i < $fields{$f} ; $i++ ) {
                my $value = "";

            # first we check if it is the curation_status field as this requires
            # special consideration
                if ( $f eq "OBI_0000281" ) {
                    $value = $h_ref->{$f}[$i]{"rdf:resource"} ? $h_ref->{$f}[$i]{"rdf:resource"} : "";
                } elsif ( $h_ref->{$f}->[$i] ) {
                    if ( ref( $h_ref->{$f}->[$i] ) ne "HASH" ) {
                        $value = $h_ref->{$f}->[$i];
                    } elsif ( $h_ref->{$f}->[$i]->{content} ) {
                        $value = $h_ref->{$f}->[$i]->{content};
                    } else {    
                        $value = $h_ref->{$f}->[$i];
                    }
                }
                $value =~ s/[\n\r]+/\\n/g;
                push @line, $value;
            }
        }

        #print "----------------\n";
        #print Dumper @line;
        my $line = join "\t", @line;

        #print OUTF $line, "\n";
        print OUTF encode( "utf8", $line . "\n" );
    }

    close OUTF;

    mk_extra( $outfile, $inferred_classes, $equivalent_classes,
        $disjoint_classes );

    return 0;

}

# This will create the .xtra file containing the restrictions, equivalent classes, & disjoints
sub mk_extra {

    my ( $prefix, $r, $e, $d ) = @_;

    return unless ( $r || $e || $d );

    # first, lets create the hash references
    my $xml;

    if ($r) {
        $xml->{Restrictions}->[0] = $r;
    }

    if ($e) {
        $xml->{Equivalents}->[0] = $e;
    }

    if ($d) {
        $xml->{Disjoints}->[0] = $d;
    }

    # now we encode it in XML
    my $xout = XMLout(
        $xml,
        KeyAttr    => [],
        AttrIndent => 1,
        XMLDecl    => 0
    );

    $xout = encode( "utf8", $xout );

    open( XTRA, ">$prefix.xtra" );
    print XTRA $xout, "\n";
    close XTRA;

}

# This will check for the existence of extra subclass declarations that couldn't
# be captured in csv format - they will exist in a file with a .xtra extension
sub check_extra {

    my ( $xml, $csv_file ) = @_;

    # here we check to see if there are extra subclasses defined
    my $xtra_file = $csv_file . ".xtra";
    if ( -e $xtra_file ) {

        my $xtra = get_xml($xtra_file);

        # If there are disjoints
        if ( $xtra->{Disjoints}[0] ) {
            my $disj = $xtra->{Disjoints}[0];

            # iterating through each of the extra classes
            foreach my $sc ( @{ $disj->{class} } ) {

                # iterating through each of the classes from the file
                foreach my $c ( @{ $xml->{"owl:Class"} } ) {

                    #inserting the subclassof declarations if the id matches
                    if ( $c->{"rdf:about"} eq $sc->{id} ) {
                        delete $sc->{id};
                        push @{ $c->{"owl:disjointWith"} }, $sc;
                        last;
                    }
                }
            }

        }

        # If there are equivalents
        if ( $xtra->{Equivalents}[0] ) {
            my $equiv = $xtra->{Equivalents}[0];

            # iterating through each of the extra classes
            foreach my $sc ( @{ $equiv->{class} } ) {

                # iterating through each of the classes from the file
                foreach my $c ( @{ $xml->{"owl:Class"} } ) {

                    #inserting the subclassof declarations if the id matches
                    if ( $c->{"rdf:about"} eq $sc->{id} ) {
                        delete $sc->{id};
                        push @{ $c->{"owl:equivalentClass"} }, $sc;
                        last;
                    }
                }
            }

        }

        # If there are restrictions
        if ( $xtra->{Restrictions}[0] ) {

            my $rest = $xtra->{Restrictions}[0];

            # iterating through each of the extra classes
            foreach my $sc ( @{ $rest->{class} } ) {

                # iterating through each of the classes from the file
                foreach my $c ( @{ $xml->{"owl:Class"} } ) {

                    #inserting the subclassof declarations if the id matches
                    if ( $c->{"rdf:about"} eq $sc->{id} ) {
                        delete $sc->{id};
                        push @{ $c->{"rdfs:subClassOf"} }, $sc;
                        last;
                    }
                }
            }

        }
    }

    return $xml;

}

# This will check for the existence of equiv subclass declarations that couldn't
# be captured in csv format - they will exist in a file with a .equiv extension
sub check_equiv {

    my ( $xml, $csv_file ) = @_;

    # here we check to see if there are extra subclasses defined
    my $xtra_file = $csv_file . ".equiv";
    if ( -e $xtra_file ) {
        my $xtra = get_xml($xtra_file);

        # iterating through each of the extra classes
        foreach my $sc ( @{ $xtra->{class} } ) {

            # iterating through each of the classes from the file
            foreach my $c ( @{ $xml->{"owl:Class"} } ) {

                #inserting the subclassof declarations if the id matches
                if ( $c->{"rdf:about"} eq $sc->{id} ) {
                    delete $sc->{id};
                    push @{ $c->{"owl:equivalentClass"} }, $sc;
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
            class        => $e->[0]->{class},
            label        => $e->[1]->{label},
            URI          => $e->[2]->{URI},
            parent_class => $e->[3]->{parent_class},
            parent_label => $e->[4]->{parent_label},
            parent_URI   => $e->[5]->{parent_URI},
            elements     => \@elements
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
    $/ = undef;
    my $file = <INF>;
    $/ = "\n";
    my @lines = split /[\r\n]+/, $file;
    close INF;

    my @headers = ();

    if ($header_ref) {
        @headers = @$header_ref;
    } else {
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
            } else {
                $records[$index][$i] = { $headers[$i] => "" };
            }
        }
        $index++;

    }

    return @records;
}
