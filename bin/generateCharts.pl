#!/usr/bin/env perl
# $Id: generateCharts.pl,v 1.2 2008-09-14 14:41:41 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/generateCharts.pl,v $
#
# spopt wrapper script. based on original "doit.pl" written by debr with modifications by tma.

use strict;
use warnings;

use Config::General;
use File::Basename;

use FindBin;
use lib "$FindBin::Bin/../lib";

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
use SongLib;

my $version = do { my @r=(q$Revision: 1.2 $=~/\d+/g); sprintf '%d.'.'%d'x$#r,@r };

my $GHROOT = "$FindBin::Bin/..";
my $QBDIR   = "$GHROOT/qb";
my $MIDIDIR = "$GHROOT/midi";
my %SONGDB;
my %RESULTSDB;

my %ALGORITHM =
(
    'blank'           => {wp => 1.00, wd => 0.00, sq => 0.00, sp => 0.00 },

    'zero-zero'       => {wp => 1.00, wd => 0.00, sq => 0.00, sp => 0.00 },
    'twenty-twenty'   => {wp => 1.00, wd => 0.00, sq => 0.20, sp => 0.20 },
    'forty-forty'     => {wp => 1.00, wd => 0.00, sq => 0.40, sp => 0.40 },
    'sixty-sixty'     => {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.60 },
    'eighty-eighty'   => {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.80 },

    'twenty-zero'     => {wp => 1.00, wd => 0.00, sq => 0.20, sp => 0.00 },
    'forty-twenty'    => {wp => 1.00, wd => 0.00, sq => 0.40, sp => 0.20 },
    'sixty-forty'     => {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.40 },
    'eighty-sixty'    => {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.60 },

    'forty-zero'      => {wp => 1.00, wd => 0.00, sq => 0.40, sp => 0.00 },
    'sixty-twenty'    => {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.20 },
    'eighty-forty'    => {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.40 },

    'sixty-zero'      => {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.00 },
    'eighty-twenty'   => {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.20 },

    'eighty-zero'     => {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.00 },
    'hundred-zero'    => {wp => 1.00, wd => 0.00, sq => 1.00, sp => 0.00 },

    'lazy-whammy'     => {wp => 1.00, wd => 0.50, sq => 0.00, sp => 0.00 },
    'no-squeeze'      => {wp => 1.00, wd => 0.00, sq => 0.00, sp => 0.00 },
    'big-squeeze'     => {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.00 },
    'bigger-squeeze'  => {wp => 1.00, wd => 0.00, sq => 0.60, sp => 0.60 },
    'nearly-ideal'    => {wp => 1.00, wd => 0.00, sq => 0.80, sp => 0.80 },
    'upper-bound'     => {wp => 1.00, wd => 0.00, sq => 1.00, sp => 1.00 },
);

my @games = qw(gh-ps2 gh2-ps2 gh2-x360 ghrt80s-ps2 gh3-ps2 gh3-dlc gh3-aerosmith);
my @diffs = qw(easy medium hard expert);

sub usage {
    my $filename = basename( $0 );
    print <<END;
$filename v$version

USAGE: $filename <config_file>
END
    exit;
}

my $configFile = shift;
&usage unless defined $configFile;
unless ( -f $configFile && -r $configFile ) {
    print "Configuration file does not exist or is not readable.\n";
    exit 1;
}

my %config = new Config::General( $configFile )->getall;

my $GAME_REGEX = defined $config{'GAME_REGEX'} ? $config{'GAME_REGEX'} : qw{.*};
my $DIFF_REGEX = defined $config{'DIFF_REGEX'} ? $config{'DIFF_REGEX'} : qw{.*};
my $TIER_REGEX = defined $config{'TIER_REGEX'} ? $config{'TIER_REGEX'} : qw{.*};
my $FILE_REGEX = defined $config{'FILE_REGEX'} ? $config{'FILE_REGEX'} : qw{.*};
my $ALG_REGEX  = defined $config{'ALG_REGEX'}  ? $config{'ALG_REGEX'}  : qw{.*};
my $OUTPUT_DIR = defined $config{'OUTPUT_DIR'} ? $config{'OUTPUT_DIR'} : qw{.};

## Loop through all of the songs
my $sl = SongLib->new();
foreach my $game ( @games ) {
    my @songarr = $sl->get_songarr_for_game( $game );
    foreach my $song ( @songarr ) {
        foreach my $diff ( reverse @diffs ) {
	    my $tier  = $song->{tier};
	    my $title = $song->{name};
	    my $file  = $song->{file};

            next unless $game =~ /$GAME_REGEX/;
            next unless $diff =~ /$DIFF_REGEX/;
            next unless $tier =~ /$TIER_REGEX/;
            next unless $file =~ /$FILE_REGEX/;

	    &do_song( $game, $diff, $tier, $title, $file );
	}
    }
}

exit;

## SUBROUTINES

sub do_song {
    my ($game,$diff,$tier,$title,$file) = @_;
    my %song = (tier => $tier, name => $title, file => $file);

    ## This should keep some of the leaks down
    %SONGDB = ();
    %RESULTSDB = ();

    &readmidi($game,\%song);

    if ($game eq "gh3-ps2" or $game eq 'gh3-x360' or $game eq 'gh3-dlc') {
        foreach my $alg (qw(blank lazy-whammy no-squeeze twenty-zero forty-zero sixty-zero eighty-zero hundred-zero)) {
            if ($ALG_REGEX) { next unless $alg =~ /$ALG_REGEX/; }
            &process_song($game,\%song,$diff,$alg,1);
        }
    }
    
    else {
        foreach my $alg (qw(blank lazy-whammy no-squeeze big-squeeze bigger-squeeze nearly-ideal upper-bound)) {
            if ($ALG_REGEX) { next unless $alg =~ /$ALG_REGEX/; }
            &process_song($game,\%song,$diff,$alg,1);
        }
    }
}

sub readmidi {
    my ($game,$rsong) = @_;
    my $basefilename = $rsong->{file};
    my $tier = $rsong->{tier};
    my $title = $rsong->{'name'};
    print "Reading game:$game midi:$basefilename title:$title...\n";
    if ($game eq "gh3-ps2" or $game eq 'gh3-x360' or $game eq 'gh3-dlc' ) {
        my $filename = $tier == 10 ? "$QBDIR/$game/$basefilename.qb.xen" : "$QBDIR/$game/$basefilename.qb.ps2"; 
        print STDERR "ERROR: Couldn't find file '$filename'\n" unless -f $filename;
        my $mf = new QbFile;
        $mf->file($filename);

	##my $sustthresh = $rsong->{sustthresh};
        ##if ($sustthresh > 0) { $mf->sustainthresh($sustthresh); }
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

    my $gamedir = "$OUTPUT_DIR/$game";
    my $diffdir = "$OUTPUT_DIR/$game/$diff";
    mkdir($gamedir,0777) unless -d $gamedir;
    mkdir($diffdir,0777) unless -d $diffdir;

    my $song = new Song;
    if ($game eq "gh-ps2")  { $song->game("gh"); }
    if ($game eq "gh3-ps2" or $game eq 'gh3-x360' or $game eq 'gh3-dlc' ) {
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
        $painter0->filename("$diffdir/$songkey.blank.png");
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
        if ($game eq "gh3-ps2" or $game eq 'gh3-x360' or $game eq 'gh3-dlc' ) {
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
            if ($game eq "gh3-ps2" or $game eq 'gh3-x360' or $game eq 'gh3-dlc') { $painter->whammy_per_quarter_bar(7.75); }
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




