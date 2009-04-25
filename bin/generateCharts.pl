#!/usr/bin/env perl
# $Id: generateCharts.pl,v 1.15 2009-04-25 23:25:12 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/generateCharts.pl,v $
#
# spopt wrapper script. based on original "doit.pl" written by debr with modifications by tma.

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Spopt;

use Config::General;
use File::Basename;
use File::Path qw(mkpath);
use IO::File;

use Image::Magick;

my $version = do { my @r=(q$Revision: 1.15 $=~/\d+/g); sprintf '%d.'.'%d'x$#r,@r };

my $GHROOT = "$FindBin::Bin/..";

my $GLOBAL_CONFIG_FILE = "$GHROOT/cfg/spoptGlobalSettings.cfg";
my %GLOBAL_CONFIG = new Config::General( $GLOBAL_CONFIG_FILE )->getall
    or die "Could not open global config file: $!\n";

my $GAMEFILEROOT = join '/', $GHROOT,$GLOBAL_CONFIG{'ASSETS'},$GLOBAL_CONFIG{'GAMEFILES'};

my %ALGORITHM = %{ $GLOBAL_CONFIG{'ALGORITHM'} };
my %GAME = %{ $GLOBAL_CONFIG{'GAME'} };
my %CHART = %{ $GLOBAL_CONFIG{'CHART'} };

sub usage {
    my $self = basename( $0 );
    print <<END;
$self v$version by tma 2009

USAGE: $self <config_file>
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

$OUTPUT_DIR = glob $OUTPUT_DIR;
unless ( -d $OUTPUT_DIR ) {
    print "Output directory ($OUTPUT_DIR) not found!\n";
    exit 1;
}

my %SONGDB = ();
my %RESULTSDB = ();

my $songInfo = new Spopt::SongInfo;

## Loop through all of the songs
for my $game ( keys %GAME ) {
    next unless $game =~ /$GAME_REGEX/;

    my @songs      = $songInfo->get_songarr_for_game( $game );
    my @charts     = makeConfigArray( $GAME{ $game }->{'chart'} );
    my @diffs      = makeConfigArray( $GAME{ $game }->{'diff'} );
    my @algorithms = makeConfigArray( $GAME{ $game }->{'algorithm'} );

    my $gamePath = join '/', $GAMEFILEROOT, $GAME{ $game }->{'path'}, $GAME{ $game }->{'platform'};

    for my $song ( @songs ) {
        my $songFilename     = $song->{'file'};
        next unless $songFilename =~ /$FILE_REGEX/;

        my $songTitle        = $song->{'name'};
        my $songFullFilename = join '/', $gamePath, $songFilename;

        print "reading $songFullFilename\n";
        my $songH = readGamefile( $songFullFilename, $game );
        next unless defined $songH;

        for my $chart ( @charts ) {
            next unless $chart =~ /$CHART_REGEX/;

            for my $diff ( reverse @diffs ) {
                next unless $diff =~ /$DIFF_REGEX/;

                # TODO - modify SongPainter to accept pre-generated "blank" chart
                ## generate blank chart here
                
                for my $algorithm ( 'blank', @algorithms ) {
                    next unless $algorithm =~ /$ALG_REGEX/;

                    process_song(
                        { 
                            'game'      => $game,
                            'filename'  => $songFilename,
                            'title'     => $songTitle,
                            'handle'    => $songH,
                            'chart'     => $chart,
                            'diff'      => $diff,
                            'algorithm' => $algorithm,
                            'draw'      => 1,
                        }
                    );
                }
            }
        }
    }
}

exit;

## SUBROUTINES

# converts a single entry in config into an array, if not already one
sub makeConfigArray {
    my $item = shift;
    ref $item eq 'ARRAY' ?
    return @$item        :
    return ( $item )     ;
}

sub readGamefile {
    my $filename = shift;
    my $game = shift;
    if ( ! -f $filename || ! -r $filename ) {
        print "$filename is not readable or does not exist\n";
        return undef;
    }

    my $object;
    if    ( $filename =~ m/\.mid\.qb(\.ps2|\.xen)?$/ ) {
        $object = new Spopt::QbFile;
        if ( $GAME{$game}->{'optimizer'} eq 'ghwt' ) {
            my $sectionfile = $filename;
            $sectionfile =~ s/mid.qb/mid_text.qb/;
            my $sectiontext = $filename;
            $sectiontext =~ s/mid.qb/mid_text.qs/;
            my $vocalfile = $filename;
            $vocalfile =~ s/mid.qb/mid.qs/;

            $object->sectionfile( $sectionfile );
            $object->sectiontext( $sectiontext );
            $object->vocalfile( $vocalfile );
        }
    }
    elsif ( $filename =~ m/\.mid$/ ) {
        $object = new Spopt::MidiFile;
    }
    else {
        print "unknown file type.\n";
        return undef;
    }

    $object->file( $filename );
    $object->readfile;
    return $object;
}

sub process_song {
    my $optionsHASH = shift;

    my $game     = $optionsHASH->{'game'};
    my $filename = $optionsHASH->{'filename'};
    my $title    = $optionsHASH->{'title'};
    my $handle   = $optionsHASH->{'handle'};
    my $chart    = $optionsHASH->{'chart'};
    my $diff     = $optionsHASH->{'diff'};
    my $alg      = $optionsHASH->{'algorithm'};
    my $pic      = $optionsHASH->{'draw'};

    my $songkey = $filename;
    $songkey =~ s/\.mid(\.qb\.xen|\.qb\.ps2)?$//;

    my $sp = $ALGORITHM{$alg}->{'sp'};
    my $sq = $ALGORITHM{$alg}->{'sq'};
    my $wp = $ALGORITHM{$alg}->{'wp'};
    my $wd = $ALGORITHM{$alg}->{'wd'};

    my $diffdir = "$OUTPUT_DIR/$game/$chart/$diff";
    mkpath( $diffdir ) unless -d $diffdir;

    my $song = new Spopt::Song;
    $song->game( $GAME{$game}->{'optimizer'} );
    $song->filetype( $GAME{$game}->{'type'} );
    $song->diff($diff);
    $song->chart($chart);
    $song->midifile($handle);
    $song->squeeze_percent($sq);
    $song->sp_squeeze_percent($sp);
    $song->whammy_delay($wd);
    $song->whammy_percent($wp);
    $song->construct_song();
    $song->calc_unsqueezed_data();
    $song->calc_squeezed_data();
    $song->init_phrase_sp_pwls();

    if ($alg eq "blank") {
        print "Generating blank chart for $game:$filename:$chart:$diff\n";

        ## Make the blank notechart
        my $painter = new Spopt::SongPainter;
        $painter->debug( $DEBUG );
        $painter->timing( $TIMING );
        $painter->song($song);
        $painter->filename("$diffdir/$songkey.blank.png");
        $painter->note_order( $NOTE_PRESET, $NOTE_ORDER );
        $painter->title($title);
        $painter->subtitle( join ' ', $CHART{$chart}->{'name'},$diff );
        $painter->outline_only(0);
        highlight_blank_phrases($song,$painter);
        $painter->paintsong();

    }
    else {
        print "Generating $alg algorithm chart for $game:$filename:$chart:$diff\n";

        my ($dum1,$dum2,$dum3,$perfect) = $song->estimate_scores();
        $RESULTSDB{$game}{$filename}{$diff}{"no-sp"}{best}{score} = $perfect; 

        my $optimizer = new Spopt::Optimizer;
        $optimizer->song($song);
        $optimizer->gen_interesting_events();
        $optimizer->debug(0);
        $optimizer->game( $GAME{$game}->{'optimizer'} );
        if ( $WHAMMY_RATE ) {
            $optimizer->whammy_per_quarter_bar( $WHAMMY_RATE );
        }
        else {
            $optimizer->whammy_per_quarter_bar( $GAME{$game}->{'whammyrate'} );
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
            my $painter = new Spopt::SongPainter;
            if ( $WHAMMY_RATE ) {
                $painter->whammy_per_quarter_bar( $WHAMMY_RATE );
            }
            else {
                $painter->whammy_per_quarter_bar( $GAME{$game}->{'whammyrate'} );
            }
            $painter->debug(0);
            $painter->song($song);
            $painter->filename("$diffdir/$songkey.$alg.best.png");
            $painter->note_order( $NOTE_PRESET, $NOTE_ORDER );
            $painter->title($title);
            $painter->paintsol($sol[0]);
	}

        printf "$game %-25s %-8s %-20s score:%6s path:$pathstr\n", $filename, $diff, $alg, $totscore;

        $RESULTSDB{$game}{$filename}{$diff}{$alg}{best}{score}    = $totscore; 
        $RESULTSDB{$game}{$filename}{$diff}{$alg}{best}{txtfile}  = "$songkey.$alg.summary.html";
        $RESULTSDB{$game}{$filename}{$diff}{$alg}{best}{pngfile}  = "$songkey.$alg.best.png";
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




