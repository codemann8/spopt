#!/usr/bin/perl5

use FindBin;
use lib "$FindBin::Bin/../lib";
use strict;

use MidiEvent;
use MidiFile;
use QbFile;
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
our $QBDIR   = "/home/Dave/gh/qb";
our $OUTDIR  = "/cygdrive/c/Web/GuitarHero";
our ($game,$diff,$tier,$name,$file,$sustthresh) = @ARGV;
my %song = (tier => $tier, name => $name, file => $file, sustthresh => ($sustthresh or 255));

our %ALGORITHM;
$ALGORITHM{'blank'}           = {wp => 1.00, wd => 0.00, sq => 0.00, sp => 0.00 };

$ALGORITHM{'zero-zero'}       = {wp => 1.00, wd => 0.00, sq => 0.00, sp => 0.00 };
$ALGORITHM{'twenty-twenty'}   = {wp => 1.00, wd => 0.00, sq => 0.20, sp => 0.20 };
$ALGORITHM{'forty-forty'}     = {wp => 1.00, wd => 0.00, sq => 0.40, sp => 0.40 };
$ALGORITHM{'sixty-sixty'}     = {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.60 };
$ALGORITHM{'eighty-eighty'}   = {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.80 };

$ALGORITHM{'twenty-zero'}     = {wp => 1.00, wd => 0.00, sq => 0.20, sp => 0.00 };
$ALGORITHM{'forty-twenty'}    = {wp => 1.00, wd => 0.00, sq => 0.40, sp => 0.20 };
$ALGORITHM{'sixty-forty'}     = {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.40 };
$ALGORITHM{'eighty-sixty'}    = {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.60 };

$ALGORITHM{'forty-zero'}      = {wp => 1.00, wd => 0.00, sq => 0.40, sp => 0.00 };
$ALGORITHM{'sixty-twenty'}    = {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.20 };
$ALGORITHM{'eighty-forty'}    = {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.40 };

$ALGORITHM{'sixty-zero'}      = {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.00 };
$ALGORITHM{'eighty-twenty'}   = {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.20 };

$ALGORITHM{'eighty-zero'}     = {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.00 };
$ALGORITHM{'hundred-zero'}    = {wp => 1.00, wd => 0.00, sq => 1.00, sp => 0.00 };

$ALGORITHM{'lazy-whammy'}     = {wp => 1.00, wd => 0.50, sq => 0.00, sp => 0.00 };
$ALGORITHM{'no-squeeze'}      = {wp => 1.00, wd => 0.00, sq => 0.00, sp => 0.00 };
$ALGORITHM{'big-squeeze'}     = {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.00 };
$ALGORITHM{'bigger-squeeze'}  = {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.60 };
$ALGORITHM{'nearly-ideal'}    = {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.80 };
$ALGORITHM{'upper-bound'}     = {wp => 1.00, wd => 0.00, sq => 1.00, sp => 1.00 };


&readmidi($game,\%song);
if ($game eq "gh3-ps2") {
    foreach my $alg (qw(blank)) {
        &process_song($game,\%song,"easy",$alg,1);
        &process_song($game,\%song,"medium",$alg,1);
        &process_song($game,\%song,"hard",$alg,1);
        &process_song($game,\%song,"expert",$alg,1);
    }
}

##else {
##    foreach my $alg (qw(blank lazy-whammy no-squeeze big-squeeze bigger-squeeze nearly-ideal upper-bound)) {
##        &process_song($game,\%song,$diff,$alg,1);
##    }
##}



##foreach my $alg (qw( zero-zero
##                     twenty-twenty
##                     forty-forty
##                     sixty-sixty
##                     eighty-eighty
##                     twenty-zero
##                     forty-twenty
##                     sixty-forty
##                     eighty-sixty
##                     forty-zero
##                     sixty-twenty
##                     eighty-forty
##                     sixty-zero
##                     eighty-twenty
##                     eighty-zero ) ) {
##    if ($alg =~ /zero|twenty|forty|sixty|eighty/) { &process_song($game,\%song,$diff,$alg,0); }
##    else                                      { &process_song($game,\%song,$diff,$alg,1); }
##}

sub readmidi {
    my ($game,$rsong) = @_;
    my $basefilename = $rsong->{file};
    print "Reading game:$game midi:$basefilename...\n";
    if ($game eq "gh3-ps2") {
        my $filename = "$QBDIR/$game/$basefilename.qb.ps2";
        print STDERR "ERROR: Couldn't find file '$filename'\n" unless -f $filename;
        my $mf = new QbFile;
	my $sustthresh = $rsong->{sustthresh};
        $mf->file($filename);
        $mf->sustainthresh($sustthresh);
        ##$mf->maxtrack(2);
        $mf->read();
        $SONGDB{$game}{$basefilename} = $mf;
    }

    else {
        my $filename = "$MIDIDIR/$game/$basefilename";
        print STDERR "ERROR: Couldn't find file '$filename'\n" unless -f $filename;
        my $mf = new MidiFile;
        $mf->file($filename);
        ##$mf->maxtrack(2);
        $mf->read();
        $SONGDB{$game}{$basefilename} = $mf;
    }
}

sub process_song {
    my ($game,$rsong,$diff,$alg,$pic) = @_;
    my $title = $rsong->{name};
    my $mfkey = $rsong->{file};
    my $songkey = $mfkey; $songkey =~ s/.mid$//;
    my $tier = $rsong->{tier};
    my $sp = $ALGORITHM{$alg}{sp};
    my $sq = $ALGORITHM{$alg}{sq};
    my $wp = $ALGORITHM{$alg}{wp};
    my $wd = $ALGORITHM{$alg}{wd};

    my $gamedir = "$OUTDIR/$game";
    my $diffdir = "$OUTDIR/$game/$diff";
    mkdir($gamedir,0777) unless -d $gamedir;
    mkdir($diffdir,0777) unless -d $diffdir;

    my $song = new Song;
    if ($game eq "gh-ps2")  { $song->game("gh"); }
    if ($game eq "gh3-ps2") {
	$song->game("gh3");
	$song->filetype("qb");
    }
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

    if ($alg eq "blank") {
        ## Make the blank notechart
        my $painter0 = new SongPainter;
        $painter0->debug(0);
        $painter0->song($song);
        $painter0->filename("$diffdir/$songkey.blank.gif");
        $painter0->greenbot(0);
        $painter0->title($title);
        $painter0->subtitle("$diff");
        $painter0->outline_only(1);
        &highlight_blank_phrases($song,$painter0);
        $painter0->paintsong();
    }

    else {
        my ($dum1,$dum2,$dum3,$perfect) = $song->estimate_scores();
        $RESULTSDB{$game}{$mfkey}{$diff}{"no-sp"}{best}{score} = $perfect; 

        my $optimizer = new Optimizer;
        $optimizer->song($song);
        $optimizer->gen_interesting_events();
        $optimizer->debug(0);
        if ($game eq "gh-ps2")  { $optimizer->game("gh"); }
        if ($game eq "gh3-ps2") {
	    $optimizer->game("gh3");
	    $optimizer->whammy_per_quarter_bar(7.75);
	}
        $optimizer->optimize_me();

        my $optreport = &get_optimizer_report($optimizer);
        my @sol    = $optimizer->get_solutions();
        my $totscore = $sol[0]->totscore();
        my $pathstr  = $sol[0]->pathstr();

        open AAA, ">$diffdir/$songkey.$alg.summary.html";
        print AAA "<HTML><body><code>\n";
        my @rpt = split /\n/, $optreport;
        foreach my $r (@rpt) { chomp $r; print AAA "$r<br>\n"; }
        print AAA "</code></body></HTML>\n";
        close AAA;

	if ($pic) {
            my $painter = new SongPainter;
            if ($game eq "gh3-ps2") { $painter->whammy_per_quarter_bar(7.75); }
            $painter->debug(0);
            $painter->song($song);
            $painter->filename("$diffdir/$songkey.$alg.best.png");
            $painter->greenbot(0);
            $painter->title($title);
            $painter->paintsol($sol[0]);
	}

        printf "$game %-25s %-8s %-20s score:%6s path:$pathstr\n", $mfkey, $diff, $alg, $totscore;

        $RESULTSDB{$game}{$mfkey}{$diff}{$alg}{best}{score}    = $totscore; 
        $RESULTSDB{$game}{$mfkey}{$diff}{$alg}{best}{txtfile}  = "$songkey.$alg.summary.html";
        $RESULTSDB{$game}{$mfkey}{$diff}{$alg}{best}{pngfile}  = "$songkey.$alg.best.png";
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

sub highlight_blank_phrases {
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

