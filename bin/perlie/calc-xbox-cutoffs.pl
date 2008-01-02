#!/usr/bin/perl5

use FindBin;
use lib "$FindBin::Bin/lib";
use strict;

use MidiEvent;
use MidiFile;
use Note;
use Pwl;
use Song;
use TempoEvent;
use TimesigEvent;
use SongPainter;
use Image::Magick;
use Optimizer;
use Activation;
use Solution;

use Getopt::Long;

our $FILENAME = pop @ARGV;
our $OUTFILENAME;
our $DIFFICULTY;
our $SONG;
our $OPTIMIZER;
our $SQUEEZE_PERCENT = 0;
our $SP_SQUEEZE_PERCENT = 0;
our $DEBUG = 0;

our $XBDIR = "/home/Dave/gh/midi/gh2-x360";

my @filelist = ();
open AAA, "gh2-x360.list";
our %cutoff;
while (<AAA>) {
    chomp; s/^\s+//; s/\s+$//;
    my $basefilename = $_;
    my $filename     = "$XBDIR/$basefilename";
    next unless -f $filename;

    $cutoff{$basefilename}{4}{easy} = 0;
    $cutoff{$basefilename}{4}{medium} = 0;
    $cutoff{$basefilename}{4}{hard} = 0;
    $cutoff{$basefilename}{4}{expert} = 0;
    $cutoff{$basefilename}{5}{easy} = 0;
    $cutoff{$basefilename}{5}{medium} = 0;
    $cutoff{$basefilename}{5}{hard} = 0;
    $cutoff{$basefilename}{5}{expert} = 0;

    my $mf = new MidiFile;
    $mf->file($filename);
    $mf->maxtrack(2);
    $mf->read();
    
    foreach my $diff (qw(easy medium hard expert)) {
        my $song = new Song;
	$song->diff($diff);
	$song->midifile($mf);
	$song->construct_song();
	$song->calc_unsqueezed_data();
    	my $na = $song->notearr();
    	foreach my $n (@$na) {
	    $cutoff{$basefilename}{4}{$diff} += 2.0*$n->baseTotScore(); 
	    $cutoff{$basefilename}{5}{$diff} += 2.8*$n->baseTotScore(); 
	}
	$cutoff{$basefilename}{5}{$diff} = int($cutoff{$basefilename}{5}{$diff} + 0.9);
    }
    printf "%-20s 4E:%6d 4M:%6d 4H:%6d 4X:%6d   5E:%6d 5M:%6d 5H:%6d 5X:%6d\n",
        $basefilename,
	$cutoff{$basefilename}{4}{easy},
	$cutoff{$basefilename}{4}{medium},
	$cutoff{$basefilename}{4}{hard},
	$cutoff{$basefilename}{4}{expert},
	$cutoff{$basefilename}{5}{easy},
	$cutoff{$basefilename}{5}{medium},
	$cutoff{$basefilename}{5}{hard},
	$cutoff{$basefilename}{5}{expert};
}
