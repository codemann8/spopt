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
our $OUTFILENAME = "./junk.png";
our $DIFFICULTY;
our $SONG;
our $OPTIMIZER;
our $SQUEEZE_PERCENT = 0;
our $SP_SQUEEZE_PERCENT = 0;
our $DEBUG = 0;
our $PRINTSONG = 0;
our $WHAMMY_PERCENT = 1.00;
our $WHAMMY_DELAY   = 0.00;
our $SKIPPIC = 0;
our $GAME = "gh2";
our $MISSES = "";

## Main Programs
&get_clopt();
&read_song();
&print_song() if $PRINTSONG;
&optimize_song();
&paint_results() unless $SKIPPIC;
&print_results();

sub get_clopt {
    my $ret = &GetOptions( "out=s"     =>  \$OUTFILENAME,
                           "diff=s"    =>  \$DIFFICULTY,
			   "printsong" =>  \$PRINTSONG,
			   "skippic"   =>  \$SKIPPIC,
			   "misses=s"  =>  \$MISSES,
			   "sq=s"      =>  \$SQUEEZE_PERCENT,
			   "game=s"    =>  \$GAME,
			   "sp=s"      =>  \$SP_SQUEEZE_PERCENT,
                           "wp=s"      =>  \$WHAMMY_PERCENT,
                           "wd=s"      =>  \$WHAMMY_DELAY,
			   "debug=i"   =>  \$DEBUG );
    die "bad clopts" unless $ret;
}

sub read_song {
    my $mf = new MidiFile;
    $mf->file($FILENAME);
    ##$mf->maxtrack(2);
    ##$mf->debug(1);
    $mf->read();

    $SONG = new Song;
    $SONG->game($GAME);
    $SONG->diff($DIFFICULTY);
    $SONG->midifile($mf);
    $SONG->squeeze_percent($SQUEEZE_PERCENT);
    $SONG->sp_squeeze_percent($SP_SQUEEZE_PERCENT);
    $SONG->whammy_percent($WHAMMY_PERCENT);
    $SONG->whammy_delay($WHAMMY_DELAY);
    $SONG->construct_song();
    if (length($MISSES)>0) {
	$MISSES=~s/\s+//g;
	my @misses = split /,/, $MISSES;
	foreach my $miss (@misses) {
	    my ($aa,$bb) = split /-/, $miss;
	    $SONG->insert_misses($aa,$bb);
	}
    }
    $SONG->calc_unsqueezed_data();
    $SONG->calc_squeezed_data();
    $SONG->init_phrase_sp_pwls();
}

sub optimize_song {
    $OPTIMIZER = new Optimizer;
    $OPTIMIZER->game($GAME);
    $OPTIMIZER->song($SONG);
    $OPTIMIZER->gen_interesting_events();
    $OPTIMIZER->debug($DEBUG);
    $OPTIMIZER->optimize_me();
}

sub print_results {
    my $sumstr = $OPTIMIZER->get_summary();
    my @sol    = $OPTIMIZER->get_solutions();
    my $sum1   = $sol[0]->sprintme();
    my $sum2   = $sol[1]->sprintme();
    my $sum3   = $sol[2]->sprintme();
    print "Path Summary (KEY: C = \"Compressed\" (i.e. don't fully whammy), S = \"Skipped\", ES = \"End Skipped\")\n";
    print "------------------------------------------------------------------------------------------\n";
    print $sumstr;
    print "\n";
    print "Path Details\n";
    print "------------------------------------------------------------------------------------------\n";
    print "$sum1\n";
    print "$sum2\n";
    print "$sum3\n";
}

sub print_song { print  $SONG->sprintme(); }

sub paint_results {
    my $sumstr = $OPTIMIZER->get_summary();
    my @sol    = $OPTIMIZER->get_solutions();
    my $sp = new SongPainter;
    $sp->debug(0);
    $sp->song($SONG);
    $sp->filename($OUTFILENAME);
    $sp->greenbot(0);
    $sp->paintsol($sol[0]);
}

