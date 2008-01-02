#!/usr/bin/perl
use FindBin;
use lib "$FindBin::Bin/../lib";
use strict;
use PWl;

my $infile = shift @ARGV;
my $outfile = shift @ARGV;

## Read in the file
open MIDIFILE, $infile;
my $buf = "",
my @filearr = ();
while (1) {
    my $len = read MIDIFILE, $buf, 1024;
    last if $len == 0;
    my @a = unpack "L*", $buf;
    push @filearr, @a;
}
close MIDIFILE;

## Track breakdown
## --------------------------------
## (1)  1x null track
## (5)  4x notes for main part
## (9)  4x SP phrases for main part
## (13) 4x Battle phrases for main part
## (17) 4x notes for alt part
## (21) 4x SP phrases for alt part
## (49) 28x null tracks
## (50) Player 1 sections for Face-off
## (51) Player 2 sections for Face-off
## (52) 2x null tracks
## (53) 1 Time signature track
## (54) 1 Beat counting track
## + some more crap I don't feel like parsing right now


## Split the thing up into tracks
splice @filearr, 0, 7;  ## Get rid of the file header 
foreach (0 .. 0)        { &get_track(\@filearr); }
our %TRACKS;
$TRACKS{main}{easy}     = &get_track(\@filearr);
$TRACKS{main}{medium}   = &get_track(\@filearr);
$TRACKS{main}{hard}     = &get_track(\@filearr);
$TRACKS{main}{expert}   = &get_track(\@filearr);
$TRACKS{mainsp}{easy}   = &get_track(\@filearr);
$TRACKS{mainsp}{medium} = &get_track(\@filearr);
$TRACKS{mainsp}{hard}   = &get_track(\@filearr);
$TRACKS{mainsp}{expert} = &get_track(\@filearr);
foreach (0 .. 3)        { &get_track(\@filearr); }
$TRACKS{alt}{easy}      = &get_track(\@filearr);
$TRACKS{alt}{medium}    = &get_track(\@filearr);
$TRACKS{alt}{hard}      = &get_track(\@filearr);
$TRACKS{alt}{expert}    = &get_track(\@filearr);
$TRACKS{altsp}{easy}    = &get_track(\@filearr);
$TRACKS{altsp}{medium}  = &get_track(\@filearr);
$TRACKS{altsp}{hard}    = &get_track(\@filearr);
$TRACKS{altsp}{expert}  = &get_track(\@filearr);
foreach (0 .. 31)       { &get_track(\@filearr); }
$TRACKS{timesig}        = &get_track(\@filearr);
$TRACKS{beats}          = &get_track(\@filearr);


## Generate the PWL
my $numbeats   = scalar @{$TRACKS{beats}};
my $numtimesig = scalar @{$TRACKS{timesig}};
my $m2t = new Pwl;
for my $i (0 .. $numbeats-1) { $m2t->add_point($TRACKS{beats}[$i],480 * $i); }

## Generate the collateral for the timesig/tempo track
my @tevents = ();
my $tt = 0;
my $beats = $TRACKS{timesig}[$tt][1];
push @tevents, [0,"timesig",$beats];
my $bb = 0;
while ($bb < $numbeats) {
    my $measstart = int($m2t->interpolate($TRACKS{beats}[$bb])+0.0001);

    ## Check for new timesignature
    if ($tt < $numtimesig-1 and $TRACKS{timesig}[$tt+1][0] + 5 < $TRACKS{beats}[$bb]) {
	$tt++;
	$beats = $TRACKS{timesig}[$tt][1];
	push @tevents, [$measstart,"timesig",$beats];
    }

    ## The normal case is that we will have enough beats to hit the start of the next measure
    if ($bb + $beats < $numbeats - 1) {
	my $tempo = int (1000 * ($TRACKS{beats}[$bb+$beats] - $TRACKS{beats}[$bb]) / (1.0 * $beats) );
	push @tevents, [$measstart,"tempo",$tempo];
    }

    ## Now we check that we have multiple beats, but not enough for a full measure
    elsif ($bb < $numbeats - 1) {
	my $tempo = int (1000 * ($TRACKS{beats}[$numbeats-1] - $TRACKS{beats}[$bb]) / (1.0 * ($numbeats-$bb-1) ) );
	push @tevents, [$measstart,"tempo",$tempo];
    }

    $bb += $beats;
}

## Generate the collateral for the note tracks
my @mevents = ();
my @aevents = ();
foreach my $ra (["easy",   60, \@mevents, "main"],
                ["medium", 72, \@mevents, "main"],
                ["hard",   84, \@mevents, "main"],
                ["expert", 96, \@mevents, "main"],
                ["easy",   60, \@aevents, "alt"],
                ["medium", 72, \@aevents, "alt"],
                ["hard",   84, \@aevents, "alt"],
                ["expert", 96, \@aevents, "alt"] ) {
    my ($diff,$base,$ea,$tag) = @$ra;
    my $numevents = scalar @{$TRACKS{$tag}{$diff}};
    for (my $i = 0; $i < $numevents; $i += 3) {
	my $start = int($m2t->interpolate($TRACKS{$tag}{$diff}[$i]));
	my $end   = int($m2t->interpolate($TRACKS{$tag}{$diff}[$i]+$TRACKS{$tag}{$diff}[$i+1]));
	my $note = $TRACKS{$tag}{$diff}[$i+2];
	$note = $note & 0x1f;
	if ($note & 0x1)  { push @$ea, ([$start,"noteon",$base+0], [$end,"noteoff",$base+0]); }
	if ($note & 0x2)  { push @$ea, ([$start,"noteon",$base+1], [$end,"noteoff",$base+1]); }
	if ($note & 0x4)  { push @$ea, ([$start,"noteon",$base+2], [$end,"noteoff",$base+2]); }
	if ($note & 0x8)  { push @$ea, ([$start,"noteon",$base+3], [$end,"noteoff",$base+3]); }
	if ($note & 0x10) { push @$ea, ([$start,"noteon",$base+4], [$end,"noteoff",$base+4]); }
    }	
}

## SP phrases
foreach my $ra (["easy",   60, \@mevents, "mainsp"],
                ["medium", 72, \@mevents, "mainsp"],
                ["hard",   84, \@mevents, "mainsp"],
                ["expert", 96, \@mevents, "mainsp"],
                ["easy",   60, \@aevents, "altsp"],
                ["medium", 72, \@aevents, "altsp"],
                ["hard",   84, \@aevents, "altsp"],
                ["expert", 96, \@aevents, "altsp"] ) {
    my ($diff,$base,$ea,$tag) = @$ra;
    my $numphrases = scalar @{$TRACKS{$tag}{$diff}};
    for (my $i = 0; $i < $numphrases-1; $i++) {
	my $start = int($m2t->interpolate($TRACKS{$tag}{$diff}[$i][0]));
	my $end   = int($m2t->interpolate($TRACKS{$tag}{$diff}[$i][0]+$TRACKS{$tag}{$diff}[$i][1]));
        push @$ea, ([$start,"noteon",$base+7], [$end,"noteoff",$base+7]);
    }
}

## Sort the Events
@tevents = sort { $a->[0] <=> $b->[0] or $b->[1] cmp $a->[1] } @tevents;
@aevents = sort { $a->[0] <=> $b->[0] or $a->[1] cmp $b->[1] or $a->[2] <=> $b->[2]} @aevents;
@mevents = sort { $a->[0] <=> $b->[0] or $a->[1] cmp $b->[1] or $a->[2] <=> $b->[2]} @mevents;

push @aevents, [$aevents[-1][0]+5, "endtrack"];
push @mevents, [$mevents[-1][0]+5, "endtrack"];

## Get rid of the tevents after the last aevents and mevents (slow ride has some crap here)
my $maxtime = &__max($aevents[-1][0]+5,$mevents[-1][0]+5);
@tevents = grep { $_->[0] < $maxtime } @tevents;
push @tevents, [$maxtime, "endtrack"];

## Start creating the midi file pieces
my $t1 = &make_track(\@tevents);
my $t2 = &make_track(\@mevents);
my $t3 = &make_track(\@aevents);
my $midifile = "MThd" . (pack "Nnnn", 6, 1, 3, 480) . $t1 . $t2 . $t3;

## Write the damned file
open OUTFILE, ">$outfile";
binmode OUTFILE;
print OUTFILE $midifile;
close OUTFILE;

sub make_track {
    my $ra = shift;
    my $numbytes = 0;
    my $cursor = 0;
    my $out = "";
    foreach my $ee (@$ra) {
        my ($nb,$ts) = &midi_var_len($ee->[0] - $cursor);
	$out .= $ts; $numbytes += $nb; 
	$cursor = $ee->[0];

        if ($ee->[1] eq "endtrack") {
	    $out .= pack "C*", (0xff, 0x2f, 0); $numbytes += 3;
	}

	elsif ($ee->[1] eq "noteon") {
	    $out .= pack "C*", (0x90, $ee->[2], 100); $numbytes += 3;
	}

	elsif ($ee->[1] eq "noteoff") {
	    $out .= pack "C*", (0x80, $ee->[2], 0); $numbytes += 3;
	}

	elsif ($ee->[1] eq "timesig") {
	    $out .= pack "C*", (0xff, 0x58, 4, $ee->[2], 4, 24, 8); $numbytes += 7;
	}

	elsif ($ee->[1] eq "tempo") {
	    my $ttt = $ee->[2];
	    my $small = $ttt % 256; $ttt -= $small; $ttt = $ttt >> 8;
	    my $med   = $ttt % 256; $ttt -= $med;   $ttt = $ttt >> 8;
	    my $lrg   = $ttt % 256;
	    $out .= pack "C*", (0xff, 0x51, 0x03, $lrg, $med, $small); $numbytes += 6;
	}

	else { die "What the hell happened"; }
    }

    $out = "MTrk" . pack("N", $numbytes) . $out;
    return $out;
}

sub midi_var_len {
    my $num = shift;
    my @out = ($num % 128);
    $num = $num >> 7 if $num > 0;
    while ($num > 0) {
	unshift @out, 0x80 | $num % 128;
	$num = $num >> 7;
    }
    return (scalar(@out), pack "C*", @out);
}

sub get_track {
    my $ra = shift;
    $ra->[0] == 787456 or die "No track header where one was expected";
    splice @$ra, 0, 5;

    my $type = $ra->[0];
    if    ($type == 256)    { splice @$ra, 0, 3; return ""; }
    elsif ($type == 65792)  { return &parse_simple_list($ra);  }
    elsif ($type == 786688) { return &parse_multlist($ra);  }
    elsif ($type == 655616) { return &parse_multlist($ra);  }
    else                    { die "Got very confused in get_track"; }
    ##elsif ($type == 65536)  { &parse_rec65536();  }
}

sub parse_simple_list {
    my $ra = shift;
    my $num = $ra->[1];
    my $numm1 = $num - 1;
    splice @$ra, 0, 3;
    my $out = [ (@$ra)[0 .. $numm1] ];
    splice @$ra, 0, $num;
    return $out;
}

sub parse_multlist {
    my $ra = shift;
    my $num = $ra->[1];
    splice @$ra, 0, 3;
    if ($num > 1) { splice @$ra, 0, $num; }
    my @out = ();
    for my $i ( 0 .. $num-1 ) { $out[$i] = &parse_simple_list($ra); }
    return [ @out ];
}

sub __max {
    my $max = $_[0];
    foreach my $a (@_) { $max = $a if $a > $max; }
    return $max;
}

