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
&print_text_events();
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

sub print_text_events {
    my $mf = $SONG->midifile();
    my @a = $mf->gettrack(1);
    @a = grep { length($_->argstr()) > 1 } @a;
    foreach my $a (@a) {
	my $meas = $SONG->t2m($a->tick());
	printf "Meas:%8.4f  Eventstr:\%s Text:\%s\n", $meas, $a->eventstr(), $a->argstr();
    }
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

sub print_song {
    my $na = $SONG->notearr();
    my ($base,$basex2,$basex28) = (0,0,0);
    my ($play,$playx2,$playx28) = (0,0,0);
    my ($ghex,$ghexx2,$ghexx28) = (0,0,0);
    for my $i ( 0 .. @$na-1 ) {
	printf "%4d %8.4f %4d %6.3f %-3s %1d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d\n",
            $i,
            $na->[$i]->startMeas(),
            $na->[$i]->lenTick(),
            $na->[$i]->lenBeat(),
            $na->[$i]->notestr(),
            $na->[$i]->star(),
	    $na->[$i]->baseNoteScore(),
	    $na->[$i]->baseSustScore(),
	    $na->[$i]->baseTotScore(),
	    $na->[$i]->GHExNoteScore(),
	    $na->[$i]->GHExSustScore(),
	    $na->[$i]->GHExTotScore(),
	    $na->[$i]->playNoteScore(),
	    $na->[$i]->playSustScore(),
	    $na->[$i]->playTotScore(),
	    $na->[$i]->baseSpTick(),
	    $na->[$i]->totSpTick(),
	    $na->[$i]->squeezedSpTick();




	$base += $na->[$i]->baseTotScore();
	$ghex += $na->[$i]->GHExTotScore();
	$play += $na->[$i]->playTotScore();
    }
    print "\n";
    printf "Base Cutoffs: (%6d, %6d, %6d)\n", $base, 2*$base, int(2.8*$base+0.9);
    printf "GHEx Cutoffs: (%6d, %6d, %6d)\n", $ghex, 2*$ghex, int(2.8*$ghex+0.9);
    printf "Play Cutoffs: (%6d, %6d, %6d)\n", $play, 2*$play, int(2.8*$play+0.9);
    print "\n";
}
	

