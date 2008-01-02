#!/usr/bin/perl5
use FindBin;
use FileHandle;
use lib "$FindBin::Bin/lib";
use SongLib;
use Song;
use MidiFile;
use Pwl;
use strict;

autoflush STDOUT 1;
our $MIDIDIR = "/home/Dave/gh/midi";

our $SL = new SongLib;
##foreach my $game (qw(gh2-ps2 gh2-x360 gh-ps2 ghrt80s-ps2)) {
my @out = ();
foreach my $game (qw(gh3-ps2)) {
    my @songarr = $SL->get_songarr_for_game($game);

    foreach my $song (@songarr) {
	
	my $file  = $song->{file};
        my $filename = "$MIDIDIR/$game/$file";

	print "Reading $file...\n";

	my $mf = new MidiFile;
	$mf->file($filename);
	$mf->maxtrack(2);
	$mf->read();

        foreach my $diff (qw(expert hard medium easy)) {

            my $song = new Song;
            if ($game eq "gh-ps2")  { $song->game("gh"); }
            if ($game eq "gh3-ps2") { $song->game("gh3"); }
            $song->diff($diff);
            $song->midifile($mf);
            $song->construct_song();
            $song->calc_unsqueezed_data();

	    my $na = $song->notearr();

	    foreach my $nn (@$na) {
		next unless $nn->star();
		next unless $nn->sustain();
		push @out, [$file, $diff, $nn->startMeas(), $nn->notestr(), $nn->lenBeat() ];
	    }
	}
    }
}

@out = sort { $b->[4] <=> $a->[4] or $a->[0] cmp $b->[0] or $a->[1] cmp $b->[1] or $a->[2] <=> $b->[2] } @out;

foreach my $rr (@out) { printf "%-30s  %-6s  %8.3f  %6.3f  \%s\n", (@$rr)[0,1,2,4,3]; }
	    
