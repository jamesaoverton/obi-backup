#!/usr/bin/perl

##############
#  Usage: perl findLastID.pl inputFile outputFile minId maxId
#
# Author: Trish Whetzel
# Date: Wed Jun 20 12:47:51 EDT 2007
###############
use strict;
my $inputFile=shift;
my $outputFile=shift;
my $minId=shift;
my $maxId=shift;

my @idRange;
my @sorted;

#print "CLA:InputFile:$inputFile\tOUTPUTFILE:$outputFile\tMIN-ID:$minId\tMAX-ID:$maxId\n";

# get all lines that contain an OBI identifier
my $call="grep 'OBI_' $inputFile > $outputFile";
system ($call);

# read in file produced from above system call
open (FILE, "$outputFile");

while (<FILE>)   {
  chomp;
  
  # parse each line to get to the identifier value
  my $line = $_;
  my @items = split ('OBI_', $line);
  #print "LINE-ITEM:$items[1]\n";

  my ($id, $junk) = split ('\"', $items[1]);
  #print "ID:$id\n";

  
  # Collect all identifier values within range specified on command-line
  # NOTE: this range is specific for each ObiBranch. See wiki page for details.
  if ($id > $minId && $id < $maxId )  { 
    #print "ID:$id is WITHIN the specified range\n";
    push(@idRange, $id);
    #print "ID-RANGE:@idRange\n";
  }
  else {
    #print "\tID:$id is NOT WITHIN the specified range\n";
  }

  # sort array numerically descending, therefore largest value 
  # in the array will be the first value 
  @sorted = sort {$b <=> $a} @idRange;

}
#print "ID-RANGE:@idRange\n";
#print "SORTED:@sorted\n";
print "Last Used Identifier Within Specified Range:$sorted[0]\n";


