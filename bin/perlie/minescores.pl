#!/usr/bin/perl5
use strict;

use HTTP::Request::Common qw(POST GET);
use LWP::UserAgent;
use HTTP::Cookies;

our $UA;
our @DB;
our @DBTEST1;
our @DBTEST2;
our $SCOREHERO = "www.scorehero.com";
##our $SCOREHERO = "82.165.251.152";

our $OUTDIR = "/cygdrive/c/Web/GuitarHero";
our $UA = LWP::UserAgent->new;
$UA->timeout(30);
if (-e "/tmp/cookies.txt") { unlink "/tmp/cookies.txt"; } $UA->cookie_jar(HTTP::Cookies->new(file => "/tmp/cookies.txt", autosave => 1));
for my $g (2,3,1,4) {
    for my $d (4,3,2,1) {
	##my $webaddr = "http://www.scorehero.com/top_scores.php?game=$g&diff=$d";
	my $webaddr = "http://www.scorehero.com/top_scores.php?game=$g&diff=$d";
        my $resp = $UA->get($webaddr);
        my $str = $resp->as_string();
	my @a = split /\n/, $str;
	for (my $i = 0; $i < @a; $i++) {
	    ##print "$i $a[$i]\n";
	    next unless $a[$i] =~ /tr height..25/;
	    $a[$i+3] =~ />(\d\d\d?,\d\d\d)</;
	    my $score = $1;
	    $a[$i+2] =~ /<a.*>(.*)<\/a>/;
	    my $title = $1;
	    
	    next unless length($score) and length($title);
	    $score =~ s/,//g;
	    printf "%6d \%d \%d \%s\n", $score, $g, $d, $title;
	    $i += 3;
	}
	##print $str;
        sleep 10;
    }
}
