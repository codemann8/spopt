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

## Main Programs
&get_clopt();
&read_song();
&print_midi();
##&print_stats();
## &print_results();
##&print_results();


sub get_clopt {

    my $ret = &GetOptions( "out=s"     =>  \$OUTFILENAME,
                           "diff=s"    =>  \$DIFFICULTY,
			   "sq=s"      =>  \$SQUEEZE_PERCENT,
			   "sp=s"      =>  \$SP_SQUEEZE_PERCENT,
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
    $SONG->squeeze_percent($SQUEEZE_PERCENT);
    $SONG->sp_squeeze_percent($SP_SQUEEZE_PERCENT);
    $SONG->construct_song();
    $SONG->calc_unsqueezed_data();
    $SONG->calc_squeezed_data();
    $SONG->init_phrase_sp_pwls();
}

sub print_midi {
    my $mf = $SONG->midifile();
    my @me = $mf->gettrack(1);
    my $diff = $DIFFICULTY;
    my $base = ($diff eq "easy" ? 60 : $diff eq "medium" ? 72 : $diff eq "hard" ? 84 : 96);
    foreach my $me (@me) {
	my $str = $me->eventstr();
	next unless $str eq "noteon" or $str eq "noteoff";
	my $note = $me->argint1();
	next unless $note >= $base;
	next unless $note <= $base+7;
	my $tick = $me->tick();
	printf "%8d %8.4f %-8s \%d \%d\n", $tick, $SONG->t2m($tick), $str, $note, $me->argint2();
    }
}

