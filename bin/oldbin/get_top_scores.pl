#!/usr/bin/perl5
use HTTP::Request::Common qw(POST GET);
use LWP::UserAgent;
use HTTP::Cookies;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;
use strict;

our $UA;
our %DB;
our @DBTEST1;
our @DBTEST2;
our $SCOREHERO = "www.scorehero.com";
##our $SCOREHERO = "82.165.251.152";

our $OUTDIR = "/cygdrive/c/Web/GuitarHero";
our $UA = LWP::UserAgent->new;
$UA->timeout(30);
if (-e "/tmp/cookies.txt") { unlink "/tmp/cookies.txt"; } $UA->cookie_jar(HTTP::Cookies->new(file => "/tmp/cookies.txt", autosave => 1));

my @games = ( ["gh-ps2",      "group=1&game=1"],
              ["gh2-ps2",     "group=2&game=2"],
              ["gh2-x360",    "group=2&game=3"],
              ["ghrt80s-ps2", "group=3&game=4"],
              ["gh3-ps2",     "group=4&game=6"],
              ["gh3-x360",    "group=4&game=5"],
              ["gh3-ps3",     "group=4&game=7"],
              ["gh3-wii",     "group=4&game=8"] );

## I'm sucking down the scores for the 360 since that seems to be the platform of choice

foreach my $ra (@games) {
    my ($game,$tag) = @$ra;
    for my $d (4,3,2,1) {
	print "Getting scores for game:$game diff:$d\n";
	##my $webaddr = "http://www.scorehero.com/top_scores.php?game=$g&diff=$d";
	my $webaddr = "http://www.scorehero.com/top_scores.php?" . $tag . "&diff=$d";
        my $resp = $UA->get($webaddr);
        my $str = $resp->as_string();
	my @a = split /\n/, $str;
	for (my $i = 0; $i < @a; $i++) {
	    ##print "$i $a[$i]\n";
	    next unless $a[$i] =~ /tr height..25/;
	    $a[$i+3] =~ />(\d\d\d?,\d\d\d)\s*</;
	    my $score = $1;
	    $a[$i+2] =~ /<a.*>(.*)<\/a>/;
	    my $title = $1;
	    
	    next unless length($score) and length($title);
	    $score =~ s/,//g;
	    ##printf "%6d \%d \%d \%s\n", $score, $g, $d, $title;
	    push @{$DB{$game}[$d]}, { score => $score, title => $title };
	    $i += 3;
	}
	##print $str;
        sleep 3;
    }
}

our $OUTDIR = "/cygdrive/c/Web/GuitarHero";
my $outfile = "$OUTDIR/top_scores.txt";
open AAA, ">$outfile";
my %diff2num = ( easy => 1, medium => 2, hard => 3, expert => 4);
##my %game2num = ( "gh2-ps2" => 2, "gh2-x360" => 3, "gh-ps2" => 1, "ghrt80s-ps2" => 4, "gh3-ps2" => 5 );
our $SL = new SongLib;
foreach my $game ("gh2-ps2", "gh2-x360", "gh-ps2", "ghrt80s-ps2", "gh3-ps2") {
    my @sa = $SL->get_songarr_for_game($game);
    foreach my $diff (qw(easy medium hard expert)) {
	my $diffnum = $diff2num{$diff};
	for my $i ( 0 .. $#sa ) {
	    printf AAA "%-13s %-6s %-30s %7d (\%s/\%s)\n", $sa[$i]{game},
	                                                   $diff,
	                                                   $sa[$i]{file},
	                                                   $DB{$game}[$diffnum][$i]{score},
	                                                   $sa[$i]{name},
	                                                   $DB{$game}[$diffnum][$i]{title};
	}
    }
}
close AAA;

