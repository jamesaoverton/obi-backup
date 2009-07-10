#!/usr/bin/perl
my $here = `dirname $0`;
chomp $here;
my $abcldir = $here."/../lib/external/lsw/";
my $thisdir = `pwd`;
chomp $thisdir;
chdir $abcldir;
$ARGV[2] || usage();
system("./abcl --eval \'(let ((*load-verbose* nil)(*compile-verbose* nil)(*suppress-compiler-warnings* (not *load-verbose*)))(asdf::oos (quote asdf::load-op) (quote owl) :verbose nil)(load \"$here/../src/tools/build/add-inferred-superclasses.lisp\") (write-inferred-superclasses (load-kb-jena \"$thisdir/$ARGV[0]\") \"$thisdir/$ARGV[1]\") (quit))\'");

sub usage 
{ print "create-superclasses.pl <ontology path> <output file>\ne.g. in the branches directory created-superclasses.pl obil.owl superclasses.owl\n";
    exit();
}