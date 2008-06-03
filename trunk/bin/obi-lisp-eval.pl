#!/usr/bin/perl

use LWP::Simple;

# perl run-lsw.pl '(print (multiple-value-list (check (load-kb-jena "obi:branches;obil.owl"))))
my $eval = shift(@ARGV);

if (!lispeval(1))
{
    if ($ENV{ABCL_WD}) { $here = $ENV{ABCL_WD} }
    else {
	$here = `dirname $0`;
	chomp $here;
	$here = $here."/../lib/external/lsw/";
    }

    chdir $here;
    $here = `pwd`;
    chop $here;
    $here.="/";

    my $childpid = fork;

    if (!$childpid)
    { 
	close(STDOUT);
	close(STDERR);
	close(STDIN);
	open(STERR,">>/tmp/lswerr");
	open(STDOUT,">>/tmp/lswout");
	system("./abcl --no-init --load $here/scripts/lsw-server-startup.lisp");
    }
    else
    {
	$|=1;
	while (!lispeval(1))
	{ print ".";sleep 1; }
	my $obidir = "../../../src/tools/build/";
	chdir $obidir; $obidir = `pwd`;chop $obidir;
	my $obiasd = "$obidir/obi.asd";
	lispeval("(load \"$obiasd\")");
	lispeval("(asdf::oos 'asd::load-op 'obi)");
	print lispeval($eval),"\n"; 
    }
}
else
{
    print lispeval($eval),"\n"; 
}

sub lispeval 
  {  my $eval = shift @_;
     $eval =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;
     get "http://127.0.0.1:6666/eval?eval=$eval"; 
  }

