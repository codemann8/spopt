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

open AAA, "ps2-expert-5star.txt";
while (<AAA>) {
    chomp; s/^\s+//; s/\s+$//;
    my @a = split /\s+/, $_;
    next unless @a == 2;
    my $proven_cutoff = $a[0];
    my $basefilename = $a[1];
    my $filename     = "/home/Dave/gh/midi/gh2-ps2/$basefilename";

    my $mf = new MidiFile;
    $mf->file($filename);
    $mf->maxtrack(2);
    $mf->read();

    my %cutoff;
    $cutoff{easy} = 0;
    $cutoff{medium} = 0;
    $cutoff{hard} = 0;
    $cutoff{expert} = 0;

    foreach my $diff (qw(easy medium hard expert)) {
	my $song = new Song;
        $song->diff($diff);
        $song->midifile($mf);
        $song->construct_song();
        $song->calc_unsqueezed_data();
	my $na = $song->notearr();
	foreach my $n (@$na) { $cutoff{$diff} += 2.8*$n->baseTotScore(); }
        $cutoff{$diff} = int($cutoff{$diff}+0.9+1e-7);
    }

    printf "%-25s E:%6d   M:%6d   H:%6d   X:%6d    WebX:%6d  Delta:%4d\n", $basefilename,
               $cutoff{easy}, $cutoff{medium}, $cutoff{hard}, $cutoff{expert}, $proven_cutoff, $proven_cutoff-$cutoff{expert};
}

