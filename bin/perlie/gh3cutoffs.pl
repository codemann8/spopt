#!/usr/bin/perl5
use FindBin;
use FileHandle;
use lib "$FindBin::Bin/../lib";
use SongLib;
use Song;
use MidiFile;
use QbFile;
use Pwl;
use strict;

autoflush STDOUT 1;
our $MIDIDIR = "/home/Dave/gh/midi";
our $QBDIR = "/home/Dave/gh/qb";

our $SL = new SongLib;
my $game = "gh3-ps2";
my @songarr = $SL->get_songarr_for_game($game);
@songarr = (@songarr);

foreach my $song (@songarr) {
	
    my $file  = $song->{file};
    my $sust = $song->{sust};
    my $filename = "$QBDIR/$game/$file.qb.ps2";

    ##print "Reading $file...\n";

    my $mf = new QbFile;
    $mf->file($filename);
    $mf->sustainthresh($sust);
    $mf->read();

    my @bases = ();
    foreach my $diff (qw(easy medium hard expert)) {
        my $song = new Song;
        $song->game("gh3");
        $song->diff($diff);
        $song->midifile($mf);
        $song->filetype("qb");
        $song->construct_song();
        $song->calc_unsqueezed_data();

        my $na = $song->notearr();
        my $basescore = 0;
        foreach my $n (@$na) { $basescore += $n->baseTotScore(); }
	push @bases, $basescore;
    }

    printf "%-30s %6d %6d %6d %6d\n", $file, @bases;
}

