#!/usr/bin/perl
use strict;

package main;
our $SUSTLIM = 255;

my $infile = shift @ARGV;
##my $outfile = shift @ARGV;
if (@ARGV) { $SUSTLIM = shift @ARGV; }

##print "Converting $infile to $outfile...\n";

## Read in the file
open MIDIFILE, $infile;
my $buf = "",
my @filearr = ();
while (1) {
    my $len = read MIDIFILE, $buf, 1024;
    last if $len == 0;
    my @a = unpack "N*", $buf;
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
##foreach (0 .. 0)        { &get_track(\@filearr); }
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
foreach (0 .. 7)        { &get_track(\@filearr); }
##$TRACKS{alt}{easy}      = &get_track(\@filearr);
##$TRACKS{alt}{medium}    = &get_track(\@filearr);
##$TRACKS{alt}{hard}      = &get_track(\@filearr);
##$TRACKS{alt}{expert}    = &get_track(\@filearr);
##$TRACKS{altsp}{easy}    = &get_track(\@filearr);
##$TRACKS{altsp}{medium}  = &get_track(\@filearr);
##$TRACKS{altsp}{hard}    = &get_track(\@filearr);
##$TRACKS{altsp}{expert}  = &get_track(\@filearr);
foreach (0 .. 31)       { &get_track(\@filearr); }
$TRACKS{timesig}        = &get_track(\@filearr);
$TRACKS{beats}          = &get_track(\@filearr);


## Generate the PWL
my $numbeats   = scalar @{$TRACKS{beats}};
my $numtimesig = scalar @{$TRACKS{timesig}};
my $m2t = new Pwl;
my $t2m = new Pwl;
my $ms2meas = new Pwl;
for my $i (0 .. $numbeats-1) {
    $m2t->add_point($TRACKS{beats}[$i],480 * $i);
    $t2m->add_point(480 * $i, $TRACKS{beats}[$i]);
}

## Generate the collateral for the timesig/tempo track
my @tevents = ();
my $tt = 0;
my $beats = $TRACKS{timesig}[$tt][1];
push @tevents, [0,"timesig",$beats];
my $bb = 0;
my $measnum = 1;
while ($bb < $numbeats) {
    my $measstart = int($m2t->interpolate($TRACKS{beats}[$bb])+0.0001);
    $ms2meas->add_point($TRACKS{beats}[$bb],$measnum);

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

my %OUT = ();
foreach my $ra (["easy",   60, \@mevents, "main"],
                ["medium", 72, \@mevents, "main"],
                ["hard",   84, \@mevents, "main"],
                ["expert", 96, \@mevents, "main"] ) {
    my ($diff,$base,$ea,$tag) = @$ra;
    my $numevents = scalar @{$TRACKS{$tag}{$diff}};
    my $pointsum = 0;
    print "DEBUG: diff:$diff\n";
    for (my $i = 0; $i < $numevents; $i += 3) {

	## I want to collect the following info
	##    a) duration in ms
	##    b) duration in beats
	##    c) base points for the sustain
	##    d) start measure
	##    e) note string
	## And then push that onto an array

	my $msstart    = $TRACKS{$tag}{$diff}[$i];
	my $mslen      = $TRACKS{$tag}{$diff}[$i+1];
	my $msend      = $msstart + $mslen;

	my $beats = ($m2t->interpolate($msend) - $m2t->interpolate($msstart)) / 480.0;
	my $points = int (25 * $beats + 0.5 + 1e-6);

	my $startmeas = $ms2meas->interpolate($msstart);

	my $notestr = "";
	my $note = $TRACKS{$tag}{$diff}[$i+2] & 0x1f;
	if ($note & 0x1)  { $notestr .= "G"; }
	if ($note & 0x2)  { $notestr .= "R"; }
	if ($note & 0x4)  { $notestr .= "Y"; }
	if ($note & 0x8)  { $notestr .= "B"; }
	if ($note & 0x10) { $notestr .= "O"; }

	my $basepoints = length($notestr) * 50;
	$basepoints += $points if $mslen > $SUSTLIM;
	$pointsum += $basepoints;

	printf "DEBUG: $basepoints $pointsum $mslen $beats $points $notestr $startmeas\n";

	push @{$OUT{$diff}}, [ $mslen, $beats, $points, $startmeas, $notestr, $basepoints ];
    }
    print "\n";
}

## sort each of the arrays based on the length of the note
foreach my $diff (qw(easy medium hard expert)) {
    @{$OUT{$diff}} = sort { $a->[0] <=> $b->[0] || $a->[4] <=> $b->[4] } @{$OUT{$diff}};
}

my %offset = ();
my %basescore = ();
## calculate the offset of the SUSTLIM
## Calculate the base score for each of the levels
foreach my $diff (qw(easy medium hard expert)) {
    $basescore{$diff} = 0;
    for my $i ( 0 .. scalar(@{$OUT{$diff}})-1 ) {
	$offset{$diff} = $i if $OUT{$diff}[$i][0] <= $SUSTLIM; 
	$basescore{$diff} += $OUT{$diff}[$i][5];
    }
}

printf "%17d || %17d || %17d || %17d\n", $basescore{easy}, $basescore{medium}, $basescore{hard}, $basescore{expert};
print "\n";

for my $i (-10 .. 10) {
    my $out = $i == 1 ? "--------------------------------------------------------------------------------\n" : "";
    foreach my $diff (qw(easy medium hard expert)) {
	my $jj = $offset{$diff}+$i;
	if     ($jj < 0 or $jj >= scalar(@{$OUT{$diff}})) { $out .= "                 ";}
	else   { $out .= sprintf "%3d %2d %-3s %6.2f", (@{$OUT{$diff}[$jj]})[0,2,4,3];   }
	if     ($diff ne "expert") { $out .= " || "; }
    }
    $out .= "\n";
    print $out;
}


sub get_track {
    my $ra = shift;
    $ra->[0] == 787456 or $ra->[0] == 2100224 or die "No track header where one was expected";
    splice @$ra, 0, 5;

    my $type = $ra->[0];
    if    ($type == 256)    { splice @$ra, 0, 3; return []; }
    if    ($type == 65536)  { splice @$ra, 0, 3; return []; }
    elsif ($type == 65792)  { return &parse_simple_list($ra);  }
    elsif ($type == 786688) { return &parse_multlist($ra);  }
    elsif ($type == 68608)  { return &parse_multlist($ra);  }
    elsif ($type == 655616) { return &parse_multlist($ra);  }
    else                    { die "Got very confused in get_track: type=$type"; }
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

sub __min {
    my $min = $_[0];
    foreach my $a (@_) { $min = $a if $a < $min; }
    return $min;
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

