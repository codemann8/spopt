#!/usr/bin/perl
use strict;

package main;
our $SUSTLIM = 255;

my $infile = shift @ARGV;
my $outfile = shift @ARGV;
if (@ARGV) { $SUSTLIM = shift @ARGV; }

print "Converting $infile to $outfile...\n";

## Read in the file
open MIDIFILE, $infile;
open OUTFILE, ">$outfile";
my $buf = "",
my @filearr = ();
while (1) {
    my $len = read MIDIFILE, $buf, 1024;
    last if $len == 0;
    my @a = unpack "V*", $buf;
    my $b = pack "N*", @a;
    print OUTFILE $b;
}
close MIDIFILE;
close OUTFILE;
