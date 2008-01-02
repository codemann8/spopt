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
&print_song();
&optimize_song();
&print_results();
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

sub optimize_song {
    $OPTIMIZER = new Optimizer;
    $OPTIMIZER->song($SONG);
    $OPTIMIZER->gen_interesting_events();
    $OPTIMIZER->debug(1);
    $OPTIMIZER->optimize_me();
}

sub print_results {
    my $sumstr = $OPTIMIZER->get_summary();
    my @sol    = $OPTIMIZER->get_solutions();
    my $sum1   = $sol[0]->sprintme();
    my $sum2   = $sol[1]->sprintme();
    my $sum3   = $sol[2]->sprintme();
    print "Path Summary\n";
    print "--------------------------------------------------------------------------------\n";
    print $sumstr;
    print "\n";
    print "Path Details\n";
    print "--------------------------------------------------------------------------------\n";
    print "$sum1\n";
    print "$sum2\n";
    print "$sum3\n";
}

sub print_song {
    my $na = $SONG->notearr();
    for my $i ( 0 .. @$na-1 ) {
	printf "%4d %8d %8d %8d %3d %7.3f %6.3f %1d %1d %1dx %-3s %4d %4d %4d %4d %4d %4d %4d\n",
            $i,
            $na->[$i]->leftStartTick(),
            $na->[$i]->startTick(),
            $na->[$i]->rightStartTick(),
            $na->[$i]->rightStartTick() - $na->[$i]->leftStartTick(),
            $na->[$i]->startMeas(),
            $na->[$i]->lenBeat(),
            $na->[$i]->sustain(),
            $na->[$i]->star(),
            $na->[$i]->mult(),
            $na->[$i]->notestr(),
	    $na->[$i]->baseNoteScore(),
	    $na->[$i]->baseSustScore(),
	    $na->[$i]->baseTotScore(),
	    $na->[$i]->multNoteScore(),
	    $na->[$i]->multSustScore(),
	    $na->[$i]->multTotScore(),
	    $na->[$i]->totSpTick();
    }
}

sub plot_song {
    my $sp = new SongPainter;
    $sp->debug(1);
    $sp->song($SONG);
    $sp->filename($OUTFILENAME);
    $sp->paintsong()
}


