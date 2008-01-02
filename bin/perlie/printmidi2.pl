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
##&print_midi();
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
    $mf->read();
    my $ra = $mf->getall();
    foreach my $event (@$ra) {
	my $tick     = $event->tick();
	my $track    = $event->track();
	my $eventstr = $event->eventstr();
	my $args = join " ", ($event->argstr(),
	                      $event->argint1(),
	                      $event->argint2(),
	                      $event->argint3(),
	                      $event->argint4()); 
	print "$track $tick $eventstr $args\n";
    }
}

