#!/usr/bin/perl5

use FindBin;
use lib "$FindBin::Bin/lib";
use strict;

use FileHandle;

use MidiEvent;
use MidiFile;
use Note;
use Pwl;
use Song;
use TempoEvent;
use TimesigEvent;
##use SongPainter;
##use Image::Magick;
use Optimizer;
use Activation;
use Solution;

use Getopt::Long;

autoflush STDOUT 1;

our $OUTFILENAME;
our $DIFFICULTY;
our $SONG;
our $OPTIMIZER;
our $SQUEEZE_PERCENT = 0;
our $SP_SQUEEZE_PERCENT = 0;
our $DEBUG = 0;
our $GAME;


#foreach $GAME (qw(gh-ps2 gh2-ps2 gh2-x360 ghrt80s-ps2)) {
foreach $GAME (qw(gh-ps2 ghrt80s-ps2)) {
    our $MIDIDIR  = "/home/Dave/gh/midi/$GAME";
    my @files = `/bin/ls $MIDIDIR | grep .mid`; chomp @files;
    foreach my $f (@files) {
	print "Reading GAME:$GAME FILE:$f...\n";
	my $mf = new MidiFile;
	$mf->file("$MIDIDIR/$f");
	$mf->maxtrack(2);
	$mf->read();

        my $mf2 = new Midifile;
	$mf2->file("$MIDIDIR/$f");
	$mf2->maxtrack(2);
	$mf2->read();
	my $song = new Song;
	$song->midifile($mf2);
	$song->diff("easy");
	$song->construct_song();


	my @me = $mf->gettrack(1);
	@me = grep { $_->eventstr() eq "noteon" or $_->eventstr() eq "noteoff" } @me;
	foreach my $note (qw(60 61 62 63 64 72 73 74 75 76 84 85 86 87 88 96 97 98 99 100)) {
	    my @nme = grep { $_->argint1() == $note } @me;
	    my $laststate = "noteoff";
	    my $lastnotetime = 0;
	    foreach my $n (@nme) {
		if ($laststate eq "noteon" and $n->eventstr() eq "noteon" and $lastnotetime != $n->tick()) {
		    printf "    BAD NOTE: time:$lastnotetime meas:%.3f note:$note\n", $song->t2m($lastnotetime);
		}
		$laststate = $n->eventstr();
		if ($laststate eq "noteon") { $lastnotetime = $n->tick(); }
	    }
	}
    }
}
