#!/usr/bin/perl5
use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;
use strict;

our $SL = new SongLib;
##foreach my $game (qw(gh2-ps2 gh2-x360 gh-ps2 ghrt80s-ps2)) {
foreach my $game (qw(gh3-ps2)) {
    my @songarr = $SL->get_songarr_for_game($game);
    foreach my $diff (qw(expert hard medium easy)) {
	foreach my $song (@songarr) {
	    my $tier  = $song->{tier};
	    my $title = $song->{name};
	    my $file  = $song->{file};
	    system("perl process_song_test.pl $game $diff $tier \"$title\" $file");
	}
    }
}
