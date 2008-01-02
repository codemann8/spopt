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

use Getopt::Long;

our $FILENAME = pop @ARGV;
our $OUTFILENAME;
our $DIFFICULTY;
our $SONG;
our $DEBUG = 0;

## Main Programs
&get_clopt();
&read_song();
&print_song();
&plot_song();


sub get_clopt {

    my $ret = &GetOptions( "out=s"     =>  \$OUTFILENAME,
                           "diff=s"    =>  \$DIFFICULTY,
			   "debug=i"   =>  \$DEBUG );
    die "bad clopts" unless $ret;
}

sub read_song {
    my $mf = new MidiFile;
    $mf->file($FILENAME);
    $mf->maxtrack(2);
    ##$mf->debug(1);
    $mf->read();

    $SONG = new Song;
    $SONG->diff($DIFFICULTY);
    $SONG->midifile($mf);
    $SONG->construct_song();
    $SONG->calc_unsqueezed_data();
}

sub print_song {
    my $na = $SONG->notearr();
    for my $i ( 0 .. @$na-1 ) {
	printf "%4d %8d %7.3f %6.3f %1d %1d %1dx %-3s\n",
            $i,
            $na->[$i]->startTick(),
            $na->[$i]->startMeas(),
            $na->[$i]->lenBeat(),
            $na->[$i]->sustain(),
            $na->[$i]->star(),
            $na->[$i]->mult(),
            $na->[$i]->notestr();
    }
}

sub plot_song {
    my $sp = new SongPainter;
    $sp->debug(1);
    $sp->song($SONG);
    $sp->filename($OUTFILENAME);
    $sp->paintsong()
}


