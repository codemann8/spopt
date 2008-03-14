#!/usr/bin/perl -w
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;

our $GHROOT = "/home/tarragon/cvs/spopt";
our $SL = new SongLib;
foreach my $game (qw(gh2-ps2 gh2-x360 gh-ps2 ghrt80s-ps2 gh3-ps2 gh3-x360)) {
    my @songarr = $SL->get_songarr_for_game($game);
    foreach my $song (@songarr) {
        foreach my $diff (qw(expert hard medium easy)) {
	    my $tier  = $song->{tier};
	    my $title = $song->{name};
	    my $file  = $song->{file};
	    ##my $sust  = $song->{sust};
	    ##next unless $game eq "gh3-ps2"; 
	    ##next unless $tier == 10;
	    ##next unless $file =~ /carcinogen|tina|puttingholes|morello|slash/;
	    ##next unless $diff eq "expert";
	    next unless $game eq "gh3-x360"; 
	    unless ( $file =~ /^dlc38/ or $file =~ /^dlc39/ or $file =~ /^dlc40/ ) { next };
	    system("perl $GHROOT/bin/process_song.pl $game $diff $tier \"$title\" $file");
	    ##system("perl $GHROOT/bin/process_song.pl $game $diff $tier \"$title\" $file $sust");
	}
    }
}
