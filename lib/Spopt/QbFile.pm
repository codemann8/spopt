package QbFile;
use strict;

sub new               { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop             { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub file              { my $self = shift; return $self->_prop("file",@_);    }
sub debug             { my $self = shift; return $self->_prop("debug",@_);    }
sub sustainthresh     { my $self = shift; return $self->_prop("sustainthresh",@_);    }
sub get_notearr       { my ($self,$diff) = @_; return $self->{_notes}{$diff}; }
sub get_sparr         { my ($self,$diff) = @_; return $self->{_sp}{$diff}; }
sub get_beats         { my ($self) = @_;       return $self->{_beat}; }
sub get_timesig       { my ($self) = @_;       return $self->{_timesig}; }

sub _init {
    my $self = shift;
    $self->file("");
    $self->debug(0);
    $self->sustainthresh(0);
    $self->{_beat}           = [];
    $self->{_timesig}        = [];
    $self->{_notes}{easy}    = [];
    $self->{_notes}{medium}  = [];
    $self->{_notes}{hard}    = [];
    $self->{_notes}{expert}  = [];
    $self->{_sp}{easy}       = [];
    $self->{_sp}{medium}     = [];
    $self->{_sp}{hard}       = [];
    $self->{_sp}{expert}     = [];
    $self->{_markers}        = [];
}

sub read {
    my $self = shift;
    my $debug = $self->debug();
    if ($debug >= 1) { print "DEBUG: Enter QbFile::read()\n"; }

    ## Get the file into an array of dwords
    my $filename = $self->{file};
    my $mode = "ps2";
    if ($filename =~ /xen$/) { $mode = "x360"; }
    open MIDIFILE, $self->{file} or die "Could not open file $self->{file} for reading";
    my $buf = "",
    my @filearr = ();
    while (1) {
        my $len = read MIDIFILE, $buf, 1024;
        last if $len == 0;
	my @a;
	if ($mode eq "x360") { @a = unpack "N*", $buf; }
	else                 { @a = unpack "V*", $buf; }
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

    my %temptracks = ();
    splice @filearr, 0, 7;  ## Get rid of the file header 

    foreach (0 .. 0)            { &_get_track(\@filearr) if $mode eq "ps2"; } # null

    #foreach (0 .. 3)            { &_get_track(\@filearr); } # main notes
    $temptracks{main}{easy}     = &_get_track(\@filearr);
    $temptracks{main}{medium}   = &_get_track(\@filearr);
    $temptracks{main}{hard}     = &_get_track(\@filearr);
    $temptracks{main}{expert}   = &_get_track(\@filearr);
    #foreach (0 .. 3)            { &_get_track(\@filearr); } # main sp
    $temptracks{mainsp}{easy}   = &_get_track(\@filearr);
    $temptracks{mainsp}{medium} = &_get_track(\@filearr);
    $temptracks{mainsp}{hard}   = &_get_track(\@filearr);
    $temptracks{mainsp}{expert} = &_get_track(\@filearr);
    foreach (0 .. 3)            { &_get_track(\@filearr); } # main battle phrases

    #foreach (0 .. 3)            { &_get_track(\@filearr); } # bass/rhythm notes
    $temptracks{coop}{easy}     = &_get_track(\@filearr);
    $temptracks{coop}{medium}   = &_get_track(\@filearr);
    $temptracks{coop}{hard}     = &_get_track(\@filearr);
    $temptracks{coop}{expert}   = &_get_track(\@filearr);
    #foreach (0 .. 3)            { &_get_track(\@filearr); } # bass/rhythm sp
    $temptracks{coopsp}{easy}   = &_get_track(\@filearr);
    $temptracks{coopsp}{medium} = &_get_track(\@filearr);
    $temptracks{coopsp}{hard}   = &_get_track(\@filearr);
    $temptracks{coopsp}{expert} = &_get_track(\@filearr);
    foreach (0 .. 3)            { &_get_track(\@filearr); } # bass/rhythm battle phrases

    #HACK - skip Aerosmith extra sections
    # foreach (0 .. 11) { &_get_track(\@filearr); }

    #foreach (0 .. 3)           { &_get_track(\@filearr); } # co-op p1 notes
    $temptracks{altp1}{easy}     = &_get_track(\@filearr);
    $temptracks{altp1}{medium}   = &_get_track(\@filearr);
    $temptracks{altp1}{hard}     = &_get_track(\@filearr);
    $temptracks{altp1}{expert}   = &_get_track(\@filearr);
    #foreach (0 .. 3)            { &_get_track(\@filearr); } # co-op p1 sp
    $temptracks{altp1sp}{easy}   = &_get_track(\@filearr);
    $temptracks{altp1sp}{medium} = &_get_track(\@filearr);
    $temptracks{altp1sp}{hard}   = &_get_track(\@filearr);
    $temptracks{altp1sp}{expert} = &_get_track(\@filearr);
    foreach (0 .. 3)            { &_get_track(\@filearr); } # co-op p1 battle phrases

    #foreach (0 .. 3)           { &_get_track(\@filearr); } # co-op p2 notes
    $temptracks{altp2}{easy}     = &_get_track(\@filearr);
    $temptracks{altp2}{medium}   = &_get_track(\@filearr);
    $temptracks{altp2}{hard}     = &_get_track(\@filearr);
    $temptracks{altp2}{expert}   = &_get_track(\@filearr);
    #foreach (0 .. 3)           { &_get_track(\@filearr); } # co-op p2 sp
    $temptracks{altp2sp}{easy}   = &_get_track(\@filearr);
    $temptracks{altp2sp}{medium} = &_get_track(\@filearr);
    $temptracks{altp2sp}{hard}   = &_get_track(\@filearr);
    $temptracks{altp2sp}{expert} = &_get_track(\@filearr);
    foreach (0 .. 3)            { &_get_track(\@filearr); } # co-op p2 battle phrases

    foreach (0 .. 3)           { &_get_track(\@filearr); } # active sections for face off/boss battle

    $temptracks{timesig}        = &_get_track(\@filearr);
    $temptracks{beats}          = &_get_track(\@filearr);
    $temptracks{markers}        = &_get_marker_track(\@filearr);

    my $part   = 'main';
    my $partsp = $part . 'sp';

    for my $dd (qw(easy medium hard expert)) {

        unless ( defined ($temptracks{$part}{$dd}) ) {
            print "no section matching $part.\n";
            return;
        }
	## Get the notes down first
	for (my $i = 0; $i < @{$temptracks{$part}{$dd}}; $i+=3) { 
	    push @{$self->{_notes}{$dd}}, [ @{$temptracks{$part}{$dd}}[$i .. $i+2] ];
	}

	## Run through the notes to get the SP start points
	my $spp = 0;
	my $numspphrases = scalar(@{$temptracks{$partsp}{$dd}});
	for (my $i = 0; $i < @{$self->{_notes}{$dd}}; $i++) {
	    next if $spp >= $numspphrases;
	    if ( $self->{_notes}{$dd}[$i][0] >= $temptracks{$partsp}{$dd}[$spp][0] ) { 
		$self->{_sp}{$dd}[$spp][0] = $i;
		$self->{_sp}{$dd}[$spp][1] = $i + $temptracks{$partsp}{$dd}[$spp][2] - 1;
		$spp++;
	    }
	}
    }

    ## beat track just moves over
    @{$self->{_beat}} = @{$temptracks{beats}};

    if ($self->sustainthresh() == 0) {
	my $st = int (($temptracks{beats}[1] - $temptracks{beats}[0])/2 + 0.0001);
        $self->sustainthresh($st);
    }

    ## massage the time sig track a little
    for (my $i = 0 ; $i < @{$temptracks{timesig}} ; $i++) {
        $self->{_timesig}[$i] = [ $temptracks{timesig}[$i][0], $temptracks{timesig} [$i][1] ];
    }


    ###################################################################
    ##  BEGIN SECTION NAMES
    ###################################################################

    ## for section names, we have to read in the master file
    my $master_file = "";
    if ($filename =~ /(\S+)\/(\S+)/) { $master_file = "$1/master_section_names.txt"; }
        else                         { $master_file = "master_section_names.txt";    }
    open MSECTION, "$master_file" or die "Could not find section file for opening";
    my %db = ();
    while (<MSECTION>) {
	next unless /(\S+)\s+(\S+)\s+(\S+)\s+(\S.*\S)/;
	my ($strcrc,$songcrc,$songbase,$string) = ($1,$2,$3,$4);
	$db{$songbase}{$strcrc} = $string;
    }
    close MSECTION;

    ## Now we need to extract the base name of this qb file
    my $basefilename = "";
    if     ($filename =~ /(\S+)\/(\S+).mid.qb.*/)  { $basefilename =  "$2"; }
    elsif  ($filename =~ /(\S+).mid.qb.*/)         { $basefilename =  "$1"; }
    else                                           { $basefilename =  "deadbeefsdfjdlskjfdklsjflsf"; }

    ## Now loop through all of the section names, and if we find one, then we stick it in the hash
    foreach my $ra (@{$temptracks{markers}}) {
	my ($tt,$kk) = @$ra;
	if (exists($db{$basefilename}{$kk})) {
	    push @{$self->{_markers}}, [ $tt, $db{$basefilename}{$kk} ];
	}
    }

    ###################################################################
    ##  END SECTION NAMES
    ###################################################################
}

sub _get_track {
    my $ra = shift;
    $ra->[0] == 787456 or $ra->[0] == 2100224 or die "No track header where one was expected";
    splice @$ra, 0, 5;

    my $type = $ra->[0];
    if    ($type == 256)    { splice @$ra, 0, 3; return []; }
    if    ($type == 65536)  { splice @$ra, 0, 3; return []; }
    elsif ($type == 65792)  { return &_parse_simple_list($ra);  }
    elsif ($type == 786688) { return &_parse_multlist($ra);  }
    elsif ($type == 68608)  { return &_parse_multlist($ra);  }
    elsif ($type == 655616) { return &_parse_multlist($ra);  }
    else                    { die "Got very confused in get_track: type=$type"; }
    ##elsif ($type == 65536)  { &parse_rec65536();  }
}

sub _get_marker_track {
    my $ra = shift;
    my @out = ();
    $ra->[0] == 787456 or $ra->[0] == 2100224 or die "No track header where one was expected";
    splice @$ra, 0, 5;
    my $type = $ra->[0];
    $type == 655616 or $type == 68096 or die "Couldn't find the right marker track, got $type instead";
    my $len = $ra->[1];
    splice @$ra, 0, 3;
    if ($len > 1) { splice @$ra, 0, $len; }
    for my $i ( 0 .. $len ) {
        ## 10 words each
	
	## 0x00010000
	## start pointer
	## type = integer
	## checksum for "time"
	## time value
	## pointer
	## type = basic variable
	## checksum for "marker"
	## value of the string checksum
	## 0x00000000

	my $timestamp       = $ra->[4];
	my $string_checksum = sprintf "%08x", $ra->[8];
	$out[$i][0] = $timestamp;
	$out[$i][1] = $string_checksum;
        splice @$ra, 0, 10;
    }
    return \@out;
}


sub _parse_simple_list {
    my $ra = shift;
    my $num = $ra->[1];
    my $numm1 = $num - 1;
    splice @$ra, 0, 3;
    my $out = [ (@$ra)[0 .. $numm1] ];
    splice @$ra, 0, $num;
    return $out;
}

sub _parse_multlist {
    my $ra = shift;
    my $num = $ra->[1];
    splice @$ra, 0, 3;
    if ($num > 1) { splice @$ra, 0, $num; }
    my @out = ();
    for my $i ( 0 .. $num-1 ) {$out[$i] = &_parse_simple_list($ra); }
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

sub get_markers {
    my $self = shift;
    return $self->{_markers};
}


1;

