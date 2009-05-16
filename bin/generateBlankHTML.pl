#!/usr/bin/env perl
# $Id: generateBlankHTML.pl,v 1.4 2009-05-16 02:37:56 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/generateBlankHTML.pl,v $

use strict;
use warnings;

use Config::General;
use File::Basename;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Spopt::SongInfo;

use CGI qw/:standard *table *Tr/;

my $version = do { my @r=(q$Revision: 1.4 $=~/\d+/g); sprintf '%d.'.'%d'x$#r,@r };

my %TOPSCORES = ();

my @games = 
(   
    { 'name' => 'gh-ps2',        'title' => 'Guitar Hero I -- PS2'              },
    { 'name' => 'gh2-ps2',       'title' => 'Guitar Hero II -- PS2'             },
    { 'name' => 'gh2-x360',      'title' => 'Guitar Hero II -- X360'            },
    { 'name' => 'ghrt80s-ps2',   'title' => 'Guitar Hero Encore : Rock the 80s' },
    { 'name' => 'gh3-ps2',       'title' => 'Guitar Hero III'                   },
    { 'name' => 'gh3-dlc',       'title' => 'Guitar Hero III -- DLC'            },
    { 'name' => 'gh3-aerosmith', 'title' => 'Guitar Hero: Aerosmith'            },
    { 'name' => 'ghwt',          'title' => 'Guitar Hero: World Tour'           },
    { 'name' => 'ghwt-dlc',      'title' => 'Guitar Hero: World Tour -- DLC'    },
    { 'name' => 'ghm',           'title' => 'Guitar Hero: Metallica'            },
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

my $GAME_REGEX = defined $config{'GAME_REGEX'} ? $config{'GAME_REGEX'} : qw{.*};
my $DIFF_REGEX = defined $config{'DIFF_REGEX'} ? $config{'DIFF_REGEX'} : qw{.*};
my $TIER_REGEX = defined $config{'TIER_REGEX'} ? $config{'TIER_REGEX'} : qw{.*};
my $OUTPUT_DIR = defined $config{'OUTPUT_DIR'} ? $config{'OUTPUT_DIR'} : qw{.};
my $CHART_REGEX = defined $config{'CHART_REGEX'} ? $config{'CHART_REGEX'} : 'guitar';

my $SL = new Spopt::SongInfo;

for my $chart ( keys %charts ) {
    next unless $chart =~ /$CHART_REGEX/;

    foreach my $game_hash ( @games ) {
        my $game  = $game_hash->{'name'};
        my $title = $game_hash->{'title'};
        next unless $game =~ /$GAME_REGEX/;
        my $filename = 'blank_'.$game.'_'.$chart.'.html';
        open FILE, ">$filename";
        select FILE;
        gen_index_alpha( $game, $title, $chart );
        select STDOUT;
        close FILE;
    }
}

exit;

sub gen_index {
    my ( $game, $title, $chart ) = @_;
    my @tt = $SL->get_tier_titles_for_game($game);
    my @sa = $SL->get_songarr_for_game($game);
    my $maxtier = scalar(@tt)-1;

    print start_html("Blank Charts for $title $charts{$chart}"), "\n";
    print start_table, "\n";

    for my $tier (0 .. $maxtier) {
	my $tier_title = $tt[$tier];
	my @songs = grep { $_->{'tier'} == $tier } @sa;

        print Tr( th({colspan=>5},$tier_title) ), "\n";
	foreach my $rs (@songs) {
            print start_Tr, "\n";
            print td( $rs->{'name'} ), "\n";
            my $base = $rs->{'file'};
            $base =~ s/(.*).mid/$1/;
            foreach my $diff ( qw( easy medium hard expert ) ) {
                print td( a({href=>"/ghwt/$chart/$diff/$base.blank.png"},$diff) ), "\n";
            }
            print end_Tr, "\n";
	}
    }
    print end_table, "\n";
    print end_html, "\n";
}

sub gen_index_alpha {
    my ( $game, $title, $chart ) = @_;
    my @sa = $SL->get_songarr_for_game($game);

    print start_html("Blank Charts for $title $charts{$chart}"), "\n";
    print start_table, "\n";

    # my @songs = grep { $_->{'tier'} == $tier } @sa;
    my @songs = sort { $a->{'name'} cmp $b->{'name'} } @sa;

    foreach my $rs (@songs) {
        print start_Tr, "\n";
        print td( $rs->{'name'} ), "\n";
        my $base = $rs->{'file'};
        $base =~ s/(.*).mid/$1/;
        foreach my $diff ( qw( easy medium hard expert ) ) {
            print td( a({href=>"/ghwt/$chart/$diff/$base.blank.png"},$diff) ), "\n";
        }
        print end_Tr, "\n";
    }
    print end_table, "\n";
    print end_html, "\n";
}

