#!/usr/bin/env perl
# $Id: generateBlankHTML.pl,v 1.1 2008-11-04 12:51:18 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/generateBlankHTML.pl,v $

use strict;
use warnings;

use Config::General;
use File::Basename;

use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;

use CGI qw/:standard *table *Tr/;

my $version = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf '%d.'.'%d'x$#r,@r };

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
);

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
my $OUTPUT_DIR = defined $config{'OUTPUT_DIR'} ? $config{'OUTPUT_DIR'} : qw{.};

my $SL = new SongLib;

foreach my $game_hash ( @games ) {
    my $game  = $game_hash->{'name'};
    my $title = $game_hash->{'title'};

    next unless $game =~ /$GAME_REGEX/;
    gen_index( $game, $title );
}

exit;

sub gen_index {
    my ( $game, $title ) = @_;
    my @tt = $SL->get_tier_titles_for_game($game);
    my @sa = $SL->get_songarr_for_game($game);
    my $maxtier = scalar(@tt)-1;

    print start_html("Blank Charts for $title"), "\n";
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
                print td( a({href=>"/ghwt/$diff/$base.blank.png"},$diff) ), "\n";
            }
            print end_Tr, "\n";
	}
    }
    print end_table, "\n";
    print end_html, "\n";
}

