#!/usr/bin/perl
use strict;

package main;

my $infile = shift @ARGV;
my $outfile = shift @ARGV;
print "Converting $infile to $outfile...\n";

## Read in the file
open MIDIFILE, $infile;
my $buf = "",
my @filearr = ();
while (1) {
    my $len = read MIDIFILE, $buf, 1024;
    last if $len == 0;
    my @a = unpack "V*", $buf;
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
my $measnum = 1;
my $b2m = new Pwl;
while ($bb < $numbeats) {
    my $measstart = int($m2t->interpolate($TRACKS{beats}[$bb])+0.0001);
    $b2m->add_point($measstart/480.0,$measnum);

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
    $measnum++;
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
	## Alright, here we jump out 
	## beat num, note str, length in ms, length in ticks
	my $start = int($m2t->interpolate($TRACKS{$tag}{$diff}[$i]));
	my $end   = int($m2t->interpolate($TRACKS{$tag}{$diff}[$i]+$TRACKS{$tag}{$diff}[$i+1]));
	my $note = $TRACKS{$tag}{$diff}[$i+2];
	$note = $note & 0x3f;
        my $hopo = $note & 0x20 ? 1 : 0;
	$note = $note & 0x1f;
	my $notestr = "";
	if ($note & 0x1)  { $notestr .= "G"; }
	if ($note & 0x2)  { $notestr .= "R"; }
	if ($note & 0x4)  { $notestr .= "Y"; }
	if ($note & 0x8)  { $notestr .= "B"; }
	if ($note & 0x10) { $notestr .= "O"; }

        $notestr .= " (HOPO)" if $hopo;

	my $dur = $TRACKS{$tag}{$diff}[$i+1];
	printf "%-6s %-4s %8.3f %5d %5d \%s\n",
	      $diff,
	      $tag,
	      $b2m->interpolate($start/480.0),
	      $dur, 
	      $end-$start,
	      ##($dur >= 270 and $dur <= 275) ? "$notestr CHECKTHISOUT" : $notestr;
	      $notestr;
    }	
}


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
    if    ($type == 256)    { splice @$ra, 0, 3; return []; }
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

package Pwl;
use strict;

sub new { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self; }

sub _init { my $self = shift; $self->{points} = []; }

sub add_point {
    my ($self,$x,$y) = @_;
    my $idx = $self->_bin_idx_search($x);
    splice @{$self->{points}}, $idx, 0, [ $x, $y ];
}

sub get_points {
    my $self = shift;
    return ( @{$self->{points}} );
}

sub interpolate {
    my ($self,$x) = @_;
    my $idx = $self->_bin_idx_search($x);
    my $ra = $self->{points};
    if ($idx > 0 and $idx < @$ra) {
	my $retval = $ra->[$idx-1][1];
	return $ra->[$idx-1][1] + ($ra->[$idx][1] - $ra->[$idx-1][1]) * ($x - $ra->[$idx-1][0]) / ($ra->[$idx][0] - $ra->[$idx-1][0]);
    }
    elsif ($idx == 0)    { return $self->{points}[0][1]; }
    elsif  ($idx == @$ra) { return $self->{points}[-1][1]; }
    else { die "Something wierd happened in interpolate"; }
}


sub _bin_idx_search {
    my ($self,$x) = @_;
    my $ra = $self->{points};

    if (@$ra >= 2 and $x > $ra->[0][0] and $x <= $ra->[-1][0]) {
	my $left = 0; my $right = @$ra - 1;
	while ($right-$left > 1) {
	    my $mid = int (($left+$right)/2 + 1e-7);
	    if ($x > $ra->[$mid][0]) { $left = $mid; }
	    else                  { $right = $mid; }
	}
	return $right;
    }
    elsif (@$ra >= 1 and $x > $ra->[-1][0]) { return scalar(@$ra); }
    else { return 0; }
}

