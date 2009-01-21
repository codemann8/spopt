#!/usr/bin/env perl
# $Id: generateCharts.pl,v 1.10 2009-01-21 08:54:53 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/generateCharts.pl,v $
#
# spopt wrapper script. based on original "doit.pl" written by debr with modifications by tma.

use strict;
use warnings;

use Config::General;
use File::Basename;
use File::Path qw(mkpath);

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

my $version = do { my @r=(q$Revision: 1.10 $=~/\d+/g); sprintf '%d.'.'%d'x$#r,@r };

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

my %games = 
(
    'gh-ps2'            => { 'optimizer' => 'gh',  'whammyrate' => 7.5,  'filetype' => 'midi' },
    'gh2-ps2'           => { 'optimizer' => 'gh2', 'whammyrate' => 7.5,  'filetype' => 'midi' },
    'gh2-x360'          => { 'optimizer' => 'gh2', 'whammyrate' => 7.5,  'filetype' => 'midi' },
    'ghrt80s-ps2'       => { 'optimizer' => 'gh2', 'whammyrate' => 7.5,  'filetype' => 'midi' },
    'gh3-ps2'           => { 'optimizer' => 'gh3', 'whammyrate' => 7.75, 'filetype' => 'qb'   },
    'gh3-dlc'           => { 'optimizer' => 'gh3', 'whammyrate' => 7.75, 'filetype' => 'qb'   },
    'gh3-aerosmith'     => { 'optimizer' => 'gh3', 'whammyrate' => 7.75, 'filetype' => 'qb'   },
    'ghwt'              => { 'optimizer' => 'gh3', 'whammyrate' => 7.75, 'filetype' => 'qb'   },
);

my @diffs = qw(easy medium hard expert);
my %charts = (
    'guitar' => 'Guitar',
    'rhythm' => 'Bass/Rhythm',
    'guitarcoop' => 'Guitar CO-OP',
    'rhythmcoop' => 'Bass/Rhythm CO-OP',
    'drum' => 'Drums',
    'aux' => 'Auxilary',
);

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

my $GAME_REGEX  = defined $config{'GAME_REGEX'}  ? $config{'GAME_REGEX'}  : qw{.*};
my $DIFF_REGEX  = defined $config{'DIFF_REGEX'}  ? $config{'DIFF_REGEX'}  : qw{.*};
my $TIER_REGEX  = defined $config{'TIER_REGEX'}  ? $config{'TIER_REGEX'}  : qw{.*};
my $FILE_REGEX  = defined $config{'FILE_REGEX'}  ? $config{'FILE_REGEX'}  : qw{.*};
my $ALG_REGEX   = defined $config{'ALG_REGEX'}   ? $config{'ALG_REGEX'}   : qw{.*};
my $OUTPUT_DIR  = defined $config{'OUTPUT_DIR'}  ? $config{'OUTPUT_DIR'}  : qw{.};
my $WHAMMY_RATE = defined $config{'WHAMMY_RATE'} ? $config{'WHAMMY_RATE'} : 0;
my $CHART_REGEX = defined $config{'CHART_REGEX'} ? $config{'CHART_REGEX'} : '^guitar$';
my $NOTE_PRESET = defined $config{'NOTE_PRESET'} ? $config{'NOTE_PRESET'} : 'guitar';
my $NOTE_ORDER  = defined $config{'NOTE_ORDER'}  ? $config{'NOTE_ORDER'}  : '';
my $DEBUG       = defined $config{'DEBUG'}       ? $config{'DEBUG'}       : 0;
my $TIMING      = defined $config{'TIMING'}      ? $config{'TIMING'}      : 0;

## Loop through all of the songs
my $sl = SongLib->new();
foreach my $game ( keys %games ) {
    my @songarr = $sl->get_songarr_for_game( $game );
    foreach my $song ( @songarr ) {
        for my $chart ( keys %charts ) {
            foreach my $diff ( reverse @diffs ) {
                my $tier  = $song->{tier};
                my $title = $song->{name};
                my $file  = $song->{file};

                next unless $game =~ /$GAME_REGEX/;
                next unless $diff =~ /$DIFF_REGEX/;
                next unless $tier =~ /$TIER_REGEX/;
                next unless $file =~ /$FILE_REGEX/;
                next unless $chart =~ /$CHART_REGEX/;

                do_song( $game, $diff, $tier, $title, $file, $chart );
            }
        }
    }
}

exit;

## SUBROUTINES

sub do_song {
    my ($game,$diff,$tier,$title,$file,$chart) = @_;
    my %song = (tier => $tier, name => $title, file => $file, chart => $chart);

    ## This should keep some of the leaks down
    %SONGDB = ();
    %RESULTSDB = ();

    readmidi($game,\%song);

    if ( $game =~ /^gh3.*/ || $game =~ /^ghwt/ ) {
        foreach my $alg (qw(blank lazy-whammy no-squeeze twenty-zero forty-zero sixty-zero eighty-zero hundred-zero)) {
            if ($ALG_REGEX) { next unless $alg =~ /$ALG_REGEX/; }
            process_song($game,\%song,$diff,$alg,1);
        }
    }
    else {
        foreach my $alg (qw(blank lazy-whammy no-squeeze big-squeeze bigger-squeeze nearly-ideal upper-bound)) {
            if ($ALG_REGEX) { next unless $alg =~ /$ALG_REGEX/; }
            process_song($game,\%song,$diff,$alg,1);
        }
    }
}

sub readmidi {
    my ($game,$rsong) = @_;
    my $basefilename = $rsong->{file};
    my $tier = $rsong->{tier};
    my $title = $rsong->{'name'};
    print "Reading game:$game midi:$basefilename title:$title...\n";

    if ( $games{$game}->{'filetype'} eq 'qb' ) {
        my $filename = "$QBDIR/$game/$basefilename.qb";
        if ( -f "$filename.xen" ) {
            $filename .= '.xen';
        }
        elsif ( -f "$filename.ps2" ) {
            $filename .= '.ps2';
        }
        else {
            print STDERR "ERROR: Couldn't find file '$filename'\n";
            return 1;
        }
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
    my $chart = $rsong->{chart};
    my $sp = $ALGORITHM{$alg}{sp};
    my $sq = $ALGORITHM{$alg}{sq};
    my $wp = $ALGORITHM{$alg}{wp};
    my $wd = $ALGORITHM{$alg}{wd};

    my $diffdir = "$OUTPUT_DIR/$game/$chart/$diff";
    mkpath( $diffdir ) unless -d $diffdir;

    my $song = new Song;
    $song->game( $games{$game}->{'optimizer'} );
    $song->filetype( $games{$game}->{'filetype'} );
    $song->diff($diff);
    $song->chart($chart);
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
        print "Generating blank chart for $game:$mfkey:$chart:$diff\n";

        ## Make the blank notechart
        my $painter = new SongPainter;
        $painter->debug( $DEBUG );
        $painter->timing( $TIMING );
        $painter->song($song);
        $painter->filename("$diffdir/$songkey.blank.png");
        $painter->note_order( $NOTE_PRESET, $NOTE_ORDER );
        $painter->title($title);
        $painter->subtitle("$charts{$chart} $diff");
        $painter->outline_only(0);
        highlight_blank_phrases($song,$painter);
        $painter->paintsong();

    }
    else {
        print "Generating $alg algorithm chart for $game:$mfkey:$chart:$diff\n";

        my ($dum1,$dum2,$dum3,$perfect) = $song->estimate_scores();
        $RESULTSDB{$game}{$mfkey}{$diff}{"no-sp"}{best}{score} = $perfect; 

        my $optimizer = new Optimizer;
        $optimizer->song($song);
        $optimizer->gen_interesting_events();
        $optimizer->debug(0);
        $optimizer->game( $games{$game}->{'optimizer'} );
        if ( $WHAMMY_RATE ) {
            $optimizer->whammy_per_quarter_bar( $WHAMMY_RATE );
        }
        else {
            $optimizer->whammy_per_quarter_bar( $games{$game}->{'whammyrate'} );
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
            if ( $WHAMMY_RATE ) {
                $painter->whammy_per_quarter_bar( $WHAMMY_RATE );
            }
            else {
                $painter->whammy_per_quarter_bar( $games{$game}->{'whammyrate'} );
            }
            $painter->debug(0);
            $painter->song($song);
            $painter->filename("$diffdir/$songkey.$alg.best.png");
            $painter->note_order( $NOTE_PRESET, $NOTE_ORDER );
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




