#!/usr/bin/perl5

use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;
use MidiFile;
use QbFile;
use Song;
use strict;

our $QBDIR = "/home/Dave/gh/qb";
our $SL = new SongLib;
foreach my $game (qw(gh3-ps2)) {
    my @songarr = $SL->get_songarr_for_game($game);
	foreach my $song (@songarr) {
	my $tier  = $song->{tier};
	my $title = $song->{name};
	my $file  = $song->{file};
	my $sust  = $song->{sust};
	my $filename = $tier == 10 ? "$QBDIR/$game/$file.qb.xen" : "$QBDIR/$game/$file.qb.ps2"; 

	##Read the midi file
        my $mfbase = new QbFile;
	$mfbase->sustainthresh($sust);
	$mfbase->file($filename);
	$mfbase->read();

	my $beatlen = $mfbase->{_beat}[1] - $mfbase->{_beat}[0];
	printf "%-40s %3d\n", $file, $beatlen; 
    }
}

