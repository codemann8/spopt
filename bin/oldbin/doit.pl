#!/usr/bin/perl -w
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;

our ($cfgfile) = (@ARGV);

our ($GHROOT,$MIDIDIR,$QBDIR,$OUTDIR,$GAME_REGEX,$DIFF_REGEX,$TIER_REGEX,$FILE_REGEX) = ();
$GHROOT = "/home/Dave/gh/spopt";

## Do the config file stuff
if ($cfgfile) {
    my $fn = "$FindBin::Bin/../cfg/$cfgfile";
    if (-e $fn) { require $fn; }
    else        { die "Could not file cfg file: $fn for reading"; }
}

our $SL = new SongLib;
foreach my $game (qw(gh2-ps2 gh2-x360 gh-ps2 ghrt80s-ps2 gh3-ps2 gh3-x360)) {
    my @songarr = $SL->get_songarr_for_game($game);
    foreach my $song (@songarr) {
        foreach my $diff (qw(expert hard medium easy)) {
	    my $tier  = $song->{tier};
	    my $title = $song->{name};
	    my $file  = $song->{file};
            if ($GAME_REGEX) { next unless $game =~ /$GAME_REGEX/; }
            if ($DIFF_REGEX) { next unless $diff =~ /$DIFF_REGEX/; }
            if ($TIER_REGEX) { next unless $tier =~ /$TIER_REGEX/; }
            if ($FILE_REGEX) { next unless $file =~ /$FILE_REGEX/; }

	    system("perl $GHROOT/bin/process_song.pl $game $diff $tier \"$title\" $file $cfgfile");
	}
    }
}
