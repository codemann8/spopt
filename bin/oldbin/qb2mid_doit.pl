#!/usr/bin/perl5
use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;
use strict;

our $GHROOT  = "/home/Dave/gh";
our $QBROOT  = "$GHROOT/qb";
our $MIDIROOT = "$GHROOT/midi";

our $SL = new SongLib;
foreach my $game (qw(gh3-ps2)) {
    my @songarr = $SL->get_songarr_for_game($game);
    foreach my $song (@songarr) {
	my $file  = $song->{file};
	my $sust  = $song->{sust};
	my $qbfile = "$file.qb.ps2";
	system("perl $GHROOT/bin/qb2mid2.pl $QBROOT/$game/$qbfile $MIDIROOT/$game/$file $sust");
    }
}
