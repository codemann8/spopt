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
	my @basescores = &getscores($mfbase);

	my $min=$sust;
	my $max=$sust;

	while ($min > 0) {
	    print "Checking min = $min\n";
	    my $mf = new QbFile;
	    $mf->sustainthresh($min);
	    $mf->file($filename);
	    $mf->read();
	    my @scores = &getscores($mf);
	    last if $scores[0] != $basescores[0];
	    last if $scores[1] != $basescores[1];
	    last if $scores[2] != $basescores[2];
	    last if $scores[3] != $basescores[3];
	    $min--;
	}
	$min++;

	while ($max < 500) {
	    print "Checking max = $max\n";
	    my $mf = new QbFile;
	    $mf->sustainthresh($max);
	    $mf->file($filename);
	    $mf->read();
	    my @scores = &getscores($mf);
	    last if $scores[0] != $basescores[0];
	    last if $scores[1] != $basescores[1];
	    last if $scores[2] != $basescores[2];
	    last if $scores[3] != $basescores[3];
	    $max++;
	}
	$max--;

	printf "%-40s %3d   %3d\n", $file,  $min,  $max;
    }
}

sub getscores {
    my $mf = shift;
    my @out = ();
    foreach my $diff (qw(easy medium hard expert)) {
        my $song = new Song;
        $song->game("gh3");
	$song->filetype("qb");
	$song->diff($diff);
	$song->midifile($mf);
	$song->construct_song();
	$song->calc_unsqueezed_data();
	my $score = 0;
	my $rna = $song->notearr();
	foreach my $nn (@$rna) { $score += $nn->baseTotScore(); }
	push @out, $score;
    }
    return @out;
}

