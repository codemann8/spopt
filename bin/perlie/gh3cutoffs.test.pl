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

    my $mf2 = new QbFile;
    $mf2->file($filename);
    $mf2->sustainthresh($sust);
    $mf2->read();

    ## Experiment for slow PS2 crap
    foreach my $diff (qw(easy medium hard expert)) {
	my $ra1 = $mf2->{_notes}{$diff};
	foreach my $n (@$ra1) {
	    ##$n->[0] -= 1 if $n->[0] % 2 == 1;
	    $n->[1] -= 1 if $n->[1] % 2 == 1;
	}
    }
    my $ra2 = $mf2->{_beat};
    ##for (my $i = 0; $i < @$ra2; $i++) { $ra2->[$i]-- if $ra2->[$i] % 2 == 1; }


    my @bases = ();
    foreach my $diff (qw(expert)) {
        my $song = new Song;
        $song->game("gh3");
        $song->diff($diff);
        $song->midifile($mf);
        $song->filetype("qb");
        $song->construct_song();
        $song->calc_unsqueezed_data();

        my $song2 = new Song;
        $song2->game("gh3");
        $song2->diff($diff);
        $song2->midifile($mf2);
        $song2->filetype("qb");
        $song2->construct_song();
        $song2->calc_unsqueezed_data();

        my $na = $song->notearr();
        my $na2 = $song2->notearr();
        my $basescore = 0;
        my $basescore2 = 0;
        foreach my $n (@$na)  { $basescore  += $n->baseTotScore(); }
        foreach my $n (@$na2) { $basescore2 += $n->baseTotScore(); }
	printf "%-25s %6d %6d\n", $file, $basescore, $basescore2;
	##push @bases, $basescore;
    }

    ##printf "%-30s %6d %6d %6d %6d\n", $file, @bases;
}

