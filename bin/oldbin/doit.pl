#!/usr/bin/perl5
use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;
use strict;

our $GHROOT = "/home/Dave/gh";
our $SL = new SongLib;
foreach my $game (qw(gh2-ps2 gh2-x360 gh-ps2 ghrt80s-ps2 gh3-ps2)) {
    my @songarr = $SL->get_songarr_for_game($game);
    foreach my $diff (qw(expert hard medium easy)) {
	foreach my $song (@songarr) {
	    my $tier  = $song->{tier};
	    my $title = $song->{name};
	    my $file  = $song->{file};
	    ##my $sust  = $song->{sust};
	    ##next unless $game eq "gh3-ps2"; 
	    ##next unless $tier == 10;
	    ##next unless $file =~ /carcinogen|tina|puttingholes|morello|slash/;
	    ##next unless $diff eq "expert";
	    next unless $game eq "gh2-x360"; 
	    next unless $file =~ /memoriesofthe|stateofmass|youshouldbeashamed/;
	    system("perl $GHROOT/bin/process_song.pl $game $diff $tier \"$title\" $file");
	    ##system("perl $GHROOT/bin/process_song.pl $game $diff $tier \"$title\" $file $sust");
	}
    }
}
