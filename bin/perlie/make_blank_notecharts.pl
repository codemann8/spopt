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

our %SONGS = ();
our %RESULTSDB = ();
our %SONGDB = ();
our %TIER_TITLE = ();
our $MIDIDIR = "/home/Dave/gh/midi";
our $OUTDIR  = "/cygdrive/c/Web/GuitarHero/Blank";
our ($game,$diff,$tier,$name,$file,) = @ARGV;
my %song = (tier => $tier, name => $name, file => $file);

our %ALGORITHM;
$ALGORITHM{'lazy-whammy'}   = {wp => 1.00, wd => 0.50, sq => 0.00, sp => 0.00 };
$ALGORITHM{'no-squeeze'}    = {wp => 1.00, wd => 0.00, sq => 0.00, sp => 0.00 };
$ALGORITHM{'big-squeeze'}   = {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.00 };
$ALGORITHM{'nearly-ideal'}  = {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.80 };
$ALGORITHM{'upper-bound'}   = {wp => 1.00, wd => 0.00, sq => 1.00, sp => 1.00 };


&readmidi($game,\%song);
foreach my $alg (qw(no-squeeze)) {
    &process_song($game,\%song,$diff,$alg);
}

sub readmidi {
    my ($game,$rsong) = @_;
    my $basefilename = $rsong->{file};
    print "Reading game:$game midi:$basefilename...\n";
    my $filename = "$MIDIDIR/$game/$basefilename";
    print STDERR "ERROR: Couldn't find file '$filename'\n" unless -f $filename;
    my $mf = new MidiFile;
    $mf->file($filename);
    ##$mf->maxtrack(2);
    $mf->read();
    $SONGDB{$game}{$basefilename} = $mf;
}

sub process_song {
    my ($game,$rsong,$diff,$alg) = @_;
    my $title = $rsong->{name};
    my $mfkey = $rsong->{file};
    my $songkey = $mfkey; $songkey =~ s/.mid$//;
    my $tier = $rsong->{tier};
    my $sp = $ALGORITHM{$alg}{sp};
    my $sq = $ALGORITHM{$alg}{sq};
    my $wp = $ALGORITHM{$alg}{wp};
    my $wd = $ALGORITHM{$alg}{wd};


    my $song = new Song;
    $song->diff($diff);
    $song->midifile($SONGDB{$game}{$mfkey});
    $song->squeeze_percent($sq);
    $song->sp_squeeze_percent($sp);
    $song->whammy_delay($wd);
    $song->whammy_percent($wp);
    $song->construct_song();
    $song->calc_unsqueezed_data();
    $song->calc_squeezed_data();
    $song->init_phrase_sp_pwls();


    ##my ($dum1,$dum2,$dum3,$perfect) = $song->estimate_scores();
    ##$RESULTSDB{$game}{$mfkey}{$diff}{"no-sp"}{best}{score} = $perfect; 

    ##my $optimizer = new Optimizer;
    ##$optimizer->song($song);
    ##$optimizer->gen_interesting_events();
    ##$optimizer->debug(0);
    ##$optimizer->optimize_me();

    ##my $optreport = &get_optimizer_report($optimizer);
    ##my @sol    = $optimizer->get_solutions();
    ##my $totscore = $sol[0]->totscore();
    ##my $pathstr  = $sol[0]->pathstr();

    my $gamedir = "$OUTDIR/$game";
    my $diffdir = "$OUTDIR/$game/$diff";
    mkdir($gamedir,0777) unless -d $gamedir;
    mkdir($diffdir,0777) unless -d $diffdir;

    ##open AAA, ">$diffdir/$songkey.$alg.summary.html";
    ##print AAA "<HTML><body><code>\n";
    ##my @rpt = split /\n/, $optreport;
    ##foreach my $r (@rpt) { chomp $r; print AAA "$r<br>\n"; }
    ##print AAA "</code></body></HTML>\n";
    ##close AAA;

    my $painter = new SongPainter;
    $painter->debug(0);
    $painter->song($song);
    $painter->filename("$diffdir/$songkey.blank.png");
    $painter->greenbot(0);
    $painter->title($title);
    $painter->subtitle("$diff");
    $painter->outline_only(1);
    &highlight_phrases($song,$painter);
    $painter->paintsong();

    ##printf "$game %-25s %-8s %-12s score:%6s path:$pathstr\n", $mfkey, $diff, $alg, $totscore;

    ##$RESULTSDB{$game}{$mfkey}{$diff}{$alg}{best}{score}    = $totscore; 
    ##$RESULTSDB{$game}{$mfkey}{$diff}{$alg}{best}{txtfile}  = "$songkey.$alg.summary.html";
    ##$RESULTSDB{$game}{$mfkey}{$diff}{$alg}{best}{pngfile}  = "$songkey.$alg.best.png";
}

sub highlight_phrases {
    my ($song,$painter) = @_;
    my $na = $song->notearr();
    my $spa = $song->sparr();
    foreach my $rsp (@$spa) {
	my ($l,$r) = @$rsp;
	my $left  = $na->[$l]->startMeas();
	my $right = $na->[$r]->endMeas();
	my $diff = $right-$left;
	$left  -= 1/64.00;
	$right += 1/64.00;
	$painter->add_unrestricted($left,$right);
    }
}

sub get_optimizer_report {
    my $optimizer = shift;
    my $sumstr = $optimizer->get_summary();
    my @sol    = $optimizer->get_solutions();
    my $sum1   = $sol[0]->sprintme();
    my $sum2   = $sol[1]->sprintme();
    my $sum3   = $sol[2]->sprintme();
    my $out = "";
    $out .=  "Path Summary (KEY: C = \"Compressed\" (i.e. don't fully whammy), S = \"Skipped\", ES = \"End Skipped\")\n";
    $out .=  "------------------------------------------------------------------------------------------\n";
    $out .=  $sumstr;
    $out .=  "\n";
    $out .=  "Path Details\n";
    $out .=  "------------------------------------------------------------------------------------------\n";
    $out .=  "$sum1\n";
    $out .=  "$sum2\n";
    $out .=  "$sum3\n";
    return $out;
}

