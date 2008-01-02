#!/usr/bin/perl5









package Note;

our $MIN_SUSTAIN_SEPARATION = 240;
our $EPS = 1e-7;

sub new        { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop      { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }

## Source fields
sub green      { my $self = shift; return $self->_prop("green",@_);     }
sub red        { my $self = shift; return $self->_prop("red",@_);       }
sub yellow     { my $self = shift; return $self->_prop("yellow",@_);    }
sub blue       { my $self = shift; return $self->_prop("blue",@_);      }
sub orange     { my $self = shift; return $self->_prop("orange",@_);    }
sub startTick  { my $self = shift; return $self->_prop("startTick",@_); }
sub endTick    { my $self = shift; return $self->_prop("endTick",@_);   }
sub star       { my $self = shift; return $self->_prop("star",@_);      }
sub mult       { my $self = shift; return $self->_prop("mult",@_);      }
sub prevTempo  { my $self = shift; return $self->_prop("prevTempo",@_); }
sub currTempo  { my $self = shift; return $self->_prop("currTempo",@_); }
sub nextTempo  { my $self = shift; return $self->_prop("nextTempo",@_); }

## Derived fields
sub notestr    { my $self = shift; return $self->_prop("notestr",@_);   }
sub chordsize  { my $self = shift; return $self->_prop("chordsize",@_); }
sub sustain    { my $self = shift; return $self->_prop("sustain",@_);   }

sub lenTick    { my $self = shift; return $self->_prop("lenTick",@_);   }
sub lenBeat    { my $self = shift; return $self->_prop("lenBeat",@_);   }
sub lenMeas    { my $self = shift; return $self->_prop("lenMeas",@_);   }

sub startBeat  { my $self = shift; return $self->_prop("startBeat",@_); }
sub startMeas  { my $self = shift; return $self->_prop("startMeas",@_); }
sub endBeat         { my $self = shift; return $self->_prop("endBeat",@_); }
sub endMeas         { my $self = shift; return $self->_prop("endMeas",@_); }

sub baseSpTick    { my $self = shift; return $self->_prop("baseSpTick",@_);   }
sub baseSpBeat    { my $self = shift; return $self->_prop("baseSpBeat",@_);   }

sub baseNoteScore   { my $self = shift; return $self->_prop("baseNoteScore",@_); }
sub baseSustScore   { my $self = shift; return $self->_prop("baseSustScore",@_); }
sub baseTotScore    { my $self = shift; return $self->_prop("baseTotScore",@_);  }

sub multNoteScore   { my $self = shift; return $self->_prop("noteScore",@_); }
sub multSustScore   { my $self = shift; return $self->_prop("sustScore",@_); }
sub multTotScore    { my $self = shift; return $self->_prop("totScore",@_);  }


## Squeeze related fields
sub squeezedSpTick  { my $self = shift; return $self->_prop("squeezedSpTick",@_);   }
sub squeezedSpBeat  { my $self = shift; return $self->_prop("squeezedSpBeat",@_);   }
sub totSpBeat       { my $self = shift; return $self->_prop("totSpBeat",@_);   }
sub totSpTick       { my $self = shift; return $self->_prop("totSpTick",@_);   }

sub leftStartBeat   { my $self = shift; return $self->_prop("leftStartBeat",@_); }
sub leftStartMeas   { my $self = shift; return $self->_prop("leftStartMeas",@_); }
sub leftStartTick   { my $self = shift; return $self->_prop("leftStartTick",@_); }
sub rightStartBeat  { my $self = shift; return $self->_prop("rightStartBeat",@_); }
sub rightStartMeas  { my $self = shift; return $self->_prop("rightStartMeas",@_); }
sub rightStartTick  { my $self = shift; return $self->_prop("rightStartTick",@_); }

sub _init {
    my $self = shift;
    $self->green(0);
    $self->red(0);
    $self->yellow(0);
    $self->blue(0);
    $self->orange(0);
    $self->startTick(0);
    $self->endTick(0);
    $self->star(0);
    $self->mult(1);
    $self->prevTempo("");
    $self->currTempo("");
    $self->nextTempo("");
}

sub calc_unsqueezed_data {
    my $self = shift;
    my $song = shift;

    ## Do note string and chord size first
    my $notestr = "";
    my $chordsize = 0;
    if ($self->green())  { $notestr .= "G"; $chordsize++; }
    if ($self->red())    { $notestr .= "R"; $chordsize++; }
    if ($self->yellow()) { $notestr .= "Y"; $chordsize++; }
    if ($self->blue())   { $notestr .= "B"; $chordsize++; }
    if ($self->orange()) { $notestr .= "O"; $chordsize++; }
    $self->notestr($notestr);
    $self->chordsize($chordsize);

    ## Now we do a simple check to see if the note is a sustain
    my $sustain = 0;
    my ($st,$et) = ($self->startTick(),$self->endTick());
    if ( ($et-$st) >= $MIN_SUSTAIN_SEPARATION ) { $sustain = 1; }
    else                                        { $et = $st; }
    $self->sustain($sustain);
    $self->endTick($et);
    $self->lenTick($et-$st);

    ## Now we do all of the beat/meas conversions
    my $sb = $song->t2b($st);
    my $eb = $song->t2b($et);
    my $sm = $song->b2m($sb);
    my $em = $song->b2m($eb);
    $self->startBeat($sb);
    $self->endBeat($eb);
    $self->startMeas($sm);
    $self->endMeas($em);
    $self->lenBeat($eb-$sb);
    $self->lenMeas($em-$sm);
    $self->baseSpTick($self->star() ? $et-$st : 0); 
    $self->baseSpBeat($self->star() ? $eb-$sb : 0); 

    my $bns = 50 * $chordsize;
    my $bss = $sustain ? int ( 25 * $chordsize * ($eb-$sb) + 0.5 + $EPS ) : 0;
    my $bts = $bns + $bss;

    my $mult = $self->mult();
    my $mns = $mult * $bns;
    my $mss = $mult * $bss;
    my $mts = $mult * $bts;

    $self->baseNoteScore($bns);
    $self->baseSustScore($bss);
    $self->baseTotScore($bts);

    $self->multNoteScore($mns);
    $self->multSustScore($mss);
    $self->multTotScore($mts);

    ## Dump in defaults for the squeeze related fields
    $self->leftStartBeat($sb);
    $self->leftStartMeas($sm);
    $self->leftStartTick($st);
    $self->rightStartBeat($sb);
    $self->rightStartMeas($sm);
    $self->rightStartTick($st);

    $self->squeezedSpTick(0);
    $self->squeezedSpBeat(0);
    $self->totSpTick($self->baseSpTick());
    $self->totSpBeat($self->baseSpBeat());
}

sub score_note {
    my ($self,$lefttick,$righttick) = @_;
    my ($ns,$ss,$ts) = (0,0,0);
    if ($lefttick <= $self->rightStartTick() and $righttick >= $self->leftStartTick()) {
	$ns += $self->multNoteScore();
	if ($self->sustain()) {
	    my $fraction = 1.00 * ($righttick - $self->startTick()) / ($self->endTick() - $self->startTick());
	    $fraction = 1.00 if $fraction > 1.00; $fraction = 0 if $fraction < 0;
	    $ss = $self->mult() * int ( $self->baseSustScore() * $fraction );
	}
    }

    elsif ($self->sustain() and $lefttick > $self->rightStartTick() and $lefttick < $self->endTick()) {
	my $right_end = $righttick > $self->endTick() ? $self->endTick() : $righttick;
	my $fraction = 1.00 * ($right_end - $lefttick) / ($self->endTick() - $self->startTick());
	$ss = $self->mult() * int ( $self->baseSustScore() * $fraction );
    }
    return ($ns,$ss,$ns+$ss);
}

sub calc_sp_tick {
    my ($self,$righttick) = @_;
    return 0.00 unless $self->sustain();
    my $fraction = 1.00 * ( $righttick - $self->endTick() + $self->totSpTick() ) / ( $self->totSpTick() );
    $fraction = 1.00 if $fraction > 1.00; $fraction = 0 if $fraction < 0;
    return int ($fraction * $self->totSpTick());
}

sub _init {
    my $self = shift;
    $self->{mult}           = 0;

    $self->{baseNoteScore}  = 0;
    $self->{baseSustScore}  = 0;
    $self->{baseTotScore}   = 0;

    $self->{noteScore}      = 0;
    $self->{sustScore}      = 0;
    $self->{totScore}       = 0;

}
1;









package MidiEvent;

sub new        { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop      { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub track      { my $self = shift; return $self->_prop("track",@_);    }
sub tick       { my $self = shift; return $self->_prop("tick",@_);     }
sub eventstr   { my $self = shift; return $self->_prop("eventstr",@_); }
sub argstr     { my $self = shift; return $self->_prop("argstr",@_);   }
sub argint1    { my $self = shift; return $self->_prop("argint1",@_);  }
sub argint2    { my $self = shift; return $self->_prop("argint2",@_);  }
sub argint3    { my $self = shift; return $self->_prop("argint3",@_);  }
sub argint4    { my $self = shift; return $self->_prop("argint4",@_);  }

sub _init {
    my $self = shift;
    $self->track(0);
    $self->tick(0);
    $self->eventstr("");
    $self->argstr("");
    $self->argint1(0);
    $self->argint2(0);
    $self->argint3(0);
    $self->argint4(0);
}
1;









package MidiFile;
sub new        { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop      { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub file       { my $self = shift; return $self->_prop("file",@_);    }

sub _init {
    my $self = shift;
    $self->file("");
    $self->{events} = [];
}

sub read {
    my $self = shift;

    ## Get the file into an array of bytes
    open MIDIFILE, $self->{file} or die "Could not open file $self->{file} for reading";
    my $buf = "",
    my @filearr = ();
    while (1) {
        my $len = read AAA, $buf, 1024;
        last if $len == 0;
        my @a = unpack "C*", $buf;
        push @filearr, @a;
    }
    close MIDIFILE;

    my ($tracks) = $self->_parse_MThd(\@filearr);
    for my $i ( 0 .. $tracks-1) { $self->_parse_MTrk($i,\@filearr); }
}

sub getall {
    my $self = shift;
    return $self->{events};
}

sub gettrack {
    my ($self,$n) = @_;
    my @track = grep { $_->track() == $n } @{$self->{events}};
    return @track;
}

sub _parse_MThd {
    my $self = shift;
    my $rf = shift;
    $rf->[0] == 0x4d or die "Invalid MThd Header, aborting...";
    $rf->[1] == 0x54 or die "Invalid MThd Header, aborting...";
    $rf->[2] == 0x68 or die "Invalid MThd Header, aborting...";
    $rf->[3] == 0x64 or die "Invalid MThd Header, aborting...";
    my $numtracks = 256 * $rf->[11] + $rf->[12];
    splice @$rf, 0, (8+6);
    return $numtracks;
}

sub _parse_MTrk {
    my ($self,$n,$rf) = @_;
    $rf->[0] == 0x4d or die "Invalid MTrk Header, aborting...";
    $rf->[1] == 0x54 or die "Invalid MTrk Header, aborting...";
    $rf->[2] == 0x72 or die "Invalid MTrk Header, aborting...";
    $rf->[3] == 0x6b or die "Invalid MTrk Header, aborting...";
    my $numbytes = (1 << 24) * $rf->[4] + (1 << 16) * $rf->[5] + (1 << 8) * $rf->[6] + $rf->[7];
    my $timestamp = 0;
    my $lasttype = "";
    my $status = "";
    splice @$rf, 0, (8);
    while ($numbytes > 0) {

        ## Parse the timestamp
	my ($deltalen,$delta) = $self->_parse_var_len($rf);
	splice @$rf, 0, $deltalen; $numbytes -= $datalen; $timestamp += $delta;

	## No figure out what the status is
	if    ($rf->[0] == 0xff)                      { $status = "meta";         splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] == 0xf0)                      { $status = "sysex";        splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0x80 and $rf->[0] <= 0x8f) { $status = "noteoff";      splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0x90 and $rf->[0] <= 0x9f) { $status = "noteon";       splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xa0 and $rf->[0] <= 0xaf) { $status = "aftertouch";   splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xb0 and $rf->[0] <= 0xbf) { $status = "control";      splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xc0 and $rf->[0] <= 0xcf) { $status = "program";      splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xd0 and $rf->[0] <= 0xdf) { $status = "chanpressure"; splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xe0 and $rf->[0] <= 0xef) { $status = "pitchwheel";   splice @$rf, 0, 1; $numbytes--;}
	else                                          { 1; } ## Running status implied

	my $event = new MidiEvent;
	$event->track($n);
	$event->tick($timestamp);

	if ($status eq "noteoff") {
	    $event->eventstr($status);
	    $event->argint1($rf->[0]);
	    $event->argint2($rf->[1]);
	    splice @$rf, 0, 2; $numbytes -= 2;
	}

	elsif ($status eq "noteon") {
	    my $locstatus = ($rf->[1] == 0) ? "noteoff", "noteon";
	    $event->eventstr($locstatus);
	    $event->argint1($rf->[0]);
	    $event->argint2($rf->[1]);
	    splice @$rf, 0, 2; $numbytes -= 2;
	}

	elsif ($status eq "meta") {
	    if ( ($rf->[0] >= 0x01) and ($rf->[0] <= 0x09) ) {

		my    $locstatus = "";
		if    ($rf->[0] == 0x01  { $locstatus = "text"; }
		elsif ($rf->[0] == 0x02) { $locstatus = "copyright"; }
		elsif ($rf->[0] == 0x03) { $locstatus = "trackname"; }
		elsif ($rf->[0] == 0x04) { $locstatus = "instrument"; }
		elsif ($rf->[0] == 0x05) { $locstatus = "lyric"; }
		elsif ($rf->[0] == 0x06) { $locstatus = "marker"; }
		elsif ($rf->[0] == 0x07) { $locstatus = "cuepoint"; }
		elsif ($rf->[0] == 0x08) { $locstatus = "programname"; }
		elsif ($rf->[0] == 0x09) { $locstatus = "devicename"; }

		splice @$rf, 0, 1; $numbytes -= 1;
		my ($sublen,$len) = $self->parse_var_len($rf);
		splice @$rf, 0, $sublen; $numbytes -= $sublen;
		my $str = ""; for my $i ( 0 .. $len-1 ) { $str .= $rf->[$i]; }
		splice @$rf, 0, $len; $numbytes -= $len;

	        $event->eventstr($locstatus);
	        $event->argstr($str);
	    }

	    elsif ($rf->[0] == 0x2f) {
	        $event->eventstr("endtrack");
		splice @$rf, 0, 3; $numbytes -= 3;
	    }

	    elsif ($rf->[0] == 0x51) {
	        $event->eventstr("tempo");
	        $event->argint1( (1 << 16) * $rf->[2] + (1 << 8) * $rf->[3] + $rf->[4] );
		splice @$rf, 0, 5; $numbytes -= 5;
	    }

	    elsif ($rf->[0] == 0x58) {
	        $event->eventstr("timesig");
		$event->argint1($rf->[2]);
		$event->argint2($rf->[3]);
		$event->argint3($rf->[4]);
		$event->argint4($rf->[5]);
		splice @$rf, 0, 6; $numbytes -= 6;
	    }

	    else { die "could not parse meta midi event -- dying"; }
	}

	else { die "unrecognized midi event"; }
        push @{$self->{events}}, $event;
    }
}

sub _parse_var_len {
    my ($self,$ra) = @_;
    if    ($ra->[0] < 128) { return (1,  $ra->[0]); }
    elsif ($ra->[1] < 128) { return (2, (($ra->[0]-128) << 7) + $ra->[1]); }
    elsif ($ra->[2] < 128) { return (3, (($ra->[0]-128) << 14) + (($ra->[1]-128) << 7) + $ra->[2]); }
    else                   { return (4, (($ra->[0]-128) << 21) + (($ra->[1]-128) << 14) + (($ra->[2]-128) << 7) + $ra->[3]); }
}
1;









package TempoEvent;

sub new    { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop  { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub tick   { my $self = shift; return $self->_prop("tick",@_);  }
sub tempo  { my $self = shift; return $self->_prop("tempo",@_); }

sub _init {
    my $self = shift;
    $self->tick(0);
    $self->tempo(0);
}

sub populateFromMidiEvent {
    my ($self,$me) = @_;
    $self->tick($me->tick());
    $self->tempo($me->argint1());
}

1;

package Pwl;

sub new { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; return $self; }
sub add_point {
    my ($self,$x,$y) = @_;

}

sub interpolate



sub _bin_idx_search {
    my ($self,$x) = @_;
    my $ra = $self->{points};

    if (@$ra >= 2 and $x > $ra->[0] and $x <= $ra[-1]) {
	my $left = 0; my $right = @$ra - 1;
	while ($right-$left > 1) {
	    my $mid = int (($left+$right)/2 + 1e-7);
	    if ($x > $ra->[$mid]) { $left = $mid; }
	    else                  { $right = $mid; }
	}
	return $right;
    }
    elsif (@$ra >= 1 and $x > $ra[-1]) { return scalar(@$ra); }
    else { return 0; }
}












package Song;

sub new           { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop         { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub diff          { my $self = shift; return $self->_prop("diff",@_);    }
sub midifile      { my $self = shift; return $self->_prop("midifile",@_);    }
sub notearr       { my $self = shift; return $self->_prop("notearr",@_);    }
sub tempoarr      { my $self = shift; return $self->_prop("tempoarr",@_);    }
sub coop          { my $self = shift; return $self->_prop("coop",@_);    }
sub coop_notearr  { my $self = shift; return $self->_prop("coop_notearr",@_);    }

sub _init {
    my $self = shift;
    $self->diff("expert");
    $self->coop(0);
    $self->notearr([]);
    $self->tempoarr([]);
}

sub construct_song {
    my $self = shift;
    $self->_gen_tempo_array();
    $self->_gen_measure_beat_structures();
    $self->_gen_note_arr(1,"notearr");
    $self->_associate_tempos("notearr");
    if ($self->coop()) {
	$self->_gen_note_arr(2,"coop_notearr");
        $self->_associate_tempos("coop_notearr");
    }
}

sub _gen_tempo_array() {
    my $self = shift;
    my $mf = $self->midifile();
    my @aa = $mf->gettrack(0);
    my $lte = new TempoEvent;
    my $lasttick = 0;
    foreach my $e (@aa) {
	$lte->tick($e->tick());
	next unless $e->eventstr() eq "tempo";
	my $te = new TempoEvent;
	$te->populateFromMidiEvent($e);
	$lte->tempo($te->tempo());
	push @{$self->{tempoarr}}, $te;
    }
    push @{$self->{tempoarr}}, $lte;
}

sub _associate_tempos {
    my $self = shift;
    my $na = $self->{notearr};
    my $ta = $self->{tempoarr};

    my $last_tempo_idx = @$ta - 1;
    my $current_tempo_ptr = 0;

    foreach my $n (@$na) {
	while (($current_tempo_ptr < $last_tempo_idx) and ($ta->[$current_tempo_ptr+1]->tick() <= $n->startTick())) { $current_tempo_ptr++; }

	if ($current_tempo_ptr == 0) { $n->prevTempo($ta->[0]); }
	else                         { $n->prevTempo($ta->[$current_tempo_ptr-1]); }

	$n->currTempo($ta->[$current_tempo_ptr]);

	if ($current_tempo_ptr == $last_tempo_idx) { $n->nextTempo($ta->[$last_tempo_idx]); }
	else                                       { $n->nextTempo($ta->[$current_tempo_ptr+1]); }
    }
}


sub _gen_note_arr {
    my ($self,$tracknum,$arrstring) = @_;
    my $diff = $self->diff();
    my $offset = ($diff eq "easy") ? 60 : ($diff eq "medium") ? 72 : ($diff eq "hard") ? 84 : ($diff eq "expert") ? 96 : 0;

    ## Firse we organzie the notes into a hash by timestamp
    my $mf = $self->midifile();
    my @aa = $mf->gettrack($tracknum);
    my (%notes,%sp,%player) = ();
    foreach my $e (@aa) {
	my $time = $e->tick();
	if ($e->eventstr() eq "noteon") {
	    if ($e->argint1() == $offset + 0) { $notes{$time}{green}  = "on"; }
	    if ($e->argint1() == $offset + 1) { $notes{$time}{red}    = "on"; }
	    if ($e->argint1() == $offset + 2) { $notes{$time}{yellow} = "on"; }
	    if ($e->argint1() == $offset + 3) { $notes{$time}{blue}   = "on"; }
	    if ($e->argint1() == $offset + 4) { $notes{$time}{orange} = "on"; }
	    if ($e->argint1() == $offset + 7) { $sp{$time}            = "on"; }
	    if ($e->argint1() == $offset + 9) { $player{$time}        = "on"; }
	}

	if ($e->eventstr() eq "noteoff") {
	    if ($e->argint1() == $offset + 0) { $notes{$time}{green}  = "off"; }
	    if ($e->argint1() == $offset + 1) { $notes{$time}{red}    = "off"; }
	    if ($e->argint1() == $offset + 2) { $notes{$time}{yellow} = "off"; }
	    if ($e->argint1() == $offset + 3) { $notes{$time}{blue}   = "off"; }
	    if ($e->argint1() == $offset + 4) { $notes{$time}{orange} = "off"; }
	    if ($e->argint1() == $offset + 7) { $sp{$time}            = "off"; }
	    if ($e->argint1() == $offset + 9) { $player{$time}        = "off"; }
	}
    }

    my @ts = sort { $a <=> $b } (keys %notes);

    ## Coallesce the notes
    for my $i ( 0 .. scalar(@ts)-1) {
	my $time = $ts[$i];
	my @buttons = keys %{$notes{$time}};
	next unless $notes{$time}{$buttons[0]} eq "on";
	my $nn = new Note;
	foreach my $color (@buttons) {
	    if ($color eq "green")    { $nn->green(1); }
	    if ($color eq "red")      { $nn->red(1); }
	    if ($color eq "yellow")   { $nn->yellow(1); }
	    if ($color eq "blue")     { $nn->blue(1); }
	    if ($color eq "orange")   { $nn->orange(1); }
	}
	$nn->startTick($time);
        if    ($i == scalar(@ts)-1)       { $nn->endTick($time); }
        elsif ($ts[$i+1] - $ts[$i] < 240) { $nn->endTick($time); }
        else                              { $nn->endTick($ts[$i+1]); }

	push @{$self->{$arrstring}}, $nn;
    }
}




	foreach my $b (qw(G R Y B O)) { $note_on = 1 if $notes{$difficulty}{$ts[$i]}{$b}; }
	next unless $note_on;
	my $newnote = {};
	$newnote->{start}  = $ts[$i]/480.0;

	   if ($i == scalar(@ts)-1) {
	       $newnote->{sustain} = 0;
	       $newnote->{len}  = 0;
	   }

	   elsif (($ts[$i+1] - $ts[$i]) < 240) {
	       $newnote->{sustain} = 0;
	       $newnote->{len}  = 0;
	   }

	   else {
	       $newnote->{sustain} = 1; 
	       $newnote->{len}  = ($ts[$i+1]-$ts[$i])/480.0;
	   }

	   my $notestr = "";
	   foreach my $b (qw(G R Y B O)) { $notestr .= $b if $notes{$difficulty}{$ts[$i]}{$b}; }
	   $newnote->{notestr} = $notestr;
	   $newnote->{spflag} = 0;

	   push @{$notes2{$difficulty}}, $newnote;
       }









       my @ts = sort { $a <=> $b } (keys %{$notes{$difficulty}});


       ## Now we deal with the star power phrases
       ## We assume on-off pairs for now -- should probably do some better checking later
       my @spts = sort { $a <=> $b } (keys %{$sp{$difficulty}});
       for (my $i = 0; $i < @spts; $i += 2) {
	   my $spon  = $spts[$i]/480.0;
	   my $spoff = $spts[$i+1]/480.0;
	   my $notefirst = 0;
	   my $notelast = -1;
	   for my $j ( 0 .. scalar(@{$notes2{$difficulty}})-1 ) {
	       if ($notes2{$difficulty}[$j]{start} < $spon)  { $notefirst++; }
	       if ($notes2{$difficulty}[$j]{start} < $spoff) { $notelast++; }
	   }
	   ##print "sp phrase from $spon to $spoff ($notefirst to $notelast)\n";
	   for my $j ($notefirst .. $notelast) { $notes2{$difficulty}[$j]{spflag} = 1; }
	   push @{$spphrases{$difficulty}}, [ $notefirst, $notelast ];
       }

       ## Now we deal with seeding the multipliers and scoring
       for my $i ( 0 .. scalar(@{$notes2{$difficulty}})-1 ) {
	   $notes2{$difficulty}[$i]{mult} = $i < 9 ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
	   my $chordsize = length $notes2{$difficulty}[$i]{notestr};
           $notes2{$difficulty}[$i]{basescore} = $chordsize * $notes2{$difficulty}[$i]{mult} * 50;
           $notes2{$difficulty}[$i]{sustainscore} = int ( $chordsize * $notes2{$difficulty}[$i]{len} * 25 + 0.5 + 1e-5 ) * $notes2{$difficulty}[$i]{mult};
           $notes2{$difficulty}[$i]{totscore} = $notes2{$difficulty}[$i]{basescore} +  
                                                $notes2{$difficulty}[$i]{sustainscore};
       }

}

    ## tempo array
    ## measure/beat conversion setup (needed for later in this routine) 
    ## fill in notes
}




























    my %notes          = ();
    my %sp             = ();
    my %player         = ();
    my %spphrases = ();
    foreach my $ra (@$rnoteevents) {
	my ($ts,$type,$note,$velocity) = @$ra;
	if ($note >= 60 and $note <= 69) {
	    if    ($note == 60) { $notes{easy}{$ts}{G} = $velocity; }
	    elsif ($note == 61) { $notes{easy}{$ts}{R} = $velocity; }
	    elsif ($note == 62) { $notes{easy}{$ts}{Y} = $velocity; }
	    elsif ($note == 63) { $notes{easy}{$ts}{B} = $velocity; }
	    elsif ($note == 64) { $notes{easy}{$ts}{O} = $velocity; }
	    elsif ($note == 67) { $sp{easy}{$ts}       = $velocity; }
	    elsif ($note == 69) { $player{easy}{$ts}   = $velocity; }
	}

	if ($note >= 72 and $note <= 81) {
	    if    ($note == 72) { $notes{medium}{$ts}{G} = $velocity; }
	    elsif ($note == 73) { $notes{medium}{$ts}{R} = $velocity; }
	    elsif ($note == 74) { $notes{medium}{$ts}{Y} = $velocity; }
	    elsif ($note == 75) { $notes{medium}{$ts}{B} = $velocity; }
	    elsif ($note == 76) { $notes{medium}{$ts}{O} = $velocity; }
	    elsif ($note == 79) { $sp{medium}{$ts}       = $velocity; }
	    elsif ($note == 81) { $player{medium}{$ts}   = $velocity; }
	}

	if ($note >= 84 and $note <= 93) {
	    if    ($note == 84) { $notes{hard}{$ts}{G} = $velocity; }
	    elsif ($note == 85) { $notes{hard}{$ts}{R} = $velocity; }
	    elsif ($note == 86) { $notes{hard}{$ts}{Y} = $velocity; }
	    elsif ($note == 87) { $notes{hard}{$ts}{B} = $velocity; }
	    elsif ($note == 88) { $notes{hard}{$ts}{O} = $velocity; }
	    elsif ($note == 91) { $sp{hard}{$ts}       = $velocity; }
	    elsif ($note == 93) { $player{hard}{$ts}   = $velocity; }
	}

	if ($note >= 96 and $note <= 105) {
	    if    ($note == 96)  { $notes{expert}{$ts}{G} = $velocity; }
	    elsif ($note == 97)  { $notes{expert}{$ts}{R} = $velocity; }
	    elsif ($note == 98)  { $notes{expert}{$ts}{Y} = $velocity; }
	    elsif ($note == 99)  { $notes{expert}{$ts}{B} = $velocity; }
	    elsif ($note == 100) { $notes{expert}{$ts}{O} = $velocity; }
	    elsif ($note == 103) { $sp{expert}{$ts}       = $velocity; }
	    elsif ($note == 105) { $player{expert}{$ts}   = $velocity; }
	}
    }

    my %notes2 = ();
    foreach my $difficulty (qw(easy medium hard expert)) {
       my @ts = sort { $a <=> $b } (keys %{$notes{$difficulty}});

       ## Coallesce the notes
       for my $i ( 0 .. scalar(@ts)-1) {
	   ## Is this a note-on event;
	   my $note_on = 0;
	   foreach my $b (qw(G R Y B O)) { $note_on = 1 if $notes{$difficulty}{$ts[$i]}{$b}; }
	   next unless $note_on;
	   my $newnote = {};
	   $newnote->{start}  = $ts[$i]/480.0;

	   if ($i == scalar(@ts)-1) {
	       $newnote->{sustain} = 0;
	       $newnote->{len}  = 0;
	   }

	   elsif (($ts[$i+1] - $ts[$i]) < 240) {
	       $newnote->{sustain} = 0;
	       $newnote->{len}  = 0;
	   }

	   else {
	       $newnote->{sustain} = 1; 
	       $newnote->{len}  = ($ts[$i+1]-$ts[$i])/480.0;
	   }

	   my $notestr = "";
	   foreach my $b (qw(G R Y B O)) { $notestr .= $b if $notes{$difficulty}{$ts[$i]}{$b}; }
	   $newnote->{notestr} = $notestr;
	   $newnote->{spflag} = 0;

	   push @{$notes2{$difficulty}}, $newnote;
       }

       ## Now we deal with the star power phrases
       ## We assume on-off pairs for now -- should probably do some better checking later
       my @spts = sort { $a <=> $b } (keys %{$sp{$difficulty}});
       for (my $i = 0; $i < @spts; $i += 2) {
	   my $spon  = $spts[$i]/480.0;
	   my $spoff = $spts[$i+1]/480.0;
	   my $notefirst = 0;
	   my $notelast = -1;
	   for my $j ( 0 .. scalar(@{$notes2{$difficulty}})-1 ) {
	       if ($notes2{$difficulty}[$j]{start} < $spon)  { $notefirst++; }
	       if ($notes2{$difficulty}[$j]{start} < $spoff) { $notelast++; }
	   }
	   ##print "sp phrase from $spon to $spoff ($notefirst to $notelast)\n";
	   for my $j ($notefirst .. $notelast) { $notes2{$difficulty}[$j]{spflag} = 1; }
	   push @{$spphrases{$difficulty}}, [ $notefirst, $notelast ];
       }

       ## Now we deal with seeding the multipliers and scoring
       for my $i ( 0 .. scalar(@{$notes2{$difficulty}})-1 ) {
	   $notes2{$difficulty}[$i]{mult} = $i < 9 ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
	   my $chordsize = length $notes2{$difficulty}[$i]{notestr};
           $notes2{$difficulty}[$i]{basescore} = $chordsize * $notes2{$difficulty}[$i]{mult} * 50;
           $notes2{$difficulty}[$i]{sustainscore} = int ( $chordsize * $notes2{$difficulty}[$i]{len} * 25 + 0.5 + 1e-5 ) * $notes2{$difficulty}[$i]{mult};
           $notes2{$difficulty}[$i]{totscore} = $notes2{$difficulty}[$i]{basescore} +  
                                                $notes2{$difficulty}[$i]{sustainscore};
       }

   }


    ## Here we quickly make a data structure for the note events
    my $lastbeat = $notes2{easy}[-1]{start} + 
                   $notes2{easy}[-1]{len} + 100;
    my @tsevents = grep { $_->[1] eq "timesig" } @$rtempo;
    my @quick_bpmeas = ();
    my $marker = 0;
    if (@tsevents > 1) {
	for my $i ( 0 .. @tsevents - 2 ) {
            push @quick_bpmeas, [$tsevents[$i][2], int(($tsevents[$i][0]+1e-5)/480.0), int(($tsevents[$i+1][0]+1e-5)/480.0)];
	}
    }
    my $lastts = @tsevents-1;
    push @quick_bpmeas, [$tsevents[$lastts][2], int(($tsevents[$lastts][0]+1e-5)/480.0), $lastbeat];

    ## Here we tack on 24 4/4/ measures just for kicks
    push @quick_bpmeas, [4, $lastbeat, $lastbeat + 96 ]; 

    my %m2b = ();
    my %b2m = ();
    my %beatspermeas = ();

    my ($measnum,$globalbeatnum) = (1,0,0);


    foreach my $ra (@quick_bpmeas) {
	for my $nummeas (1 .. int(($ra->[2]-$ra->[1]+1e-5)/$ra->[0])) {
	    $beatspermeas{$measnum} = $ra->[0];
	    $m2b{$measnum} = $globalbeatnum;
	    for my $b ( 0 .. $ra->[0]-1 ) {
		$b2m{$globalbeatnum} = $measnum + 1.0 * $b / $ra->[0];
	        $globalbeatnum++;	
	    }
	    $measnum++;
	}
    }

    ## We also need to parse the tempo track for squeezes
    my @tempoevents = grep { $_->[1] eq "tempo" } @$rtempo;
    my $numbeats = scalar(keys(%b2m));
    my $tempoptr = 0;
    my @squeeze = 0;
    for my $i ( 0 .. $numbeats - 1 ) {
	my $miditicks = 480 * $i;
	while ( ($tempoptr < scalar(@tempoevents)-1) and ($tempoevents[$tempoptr][0] + 1e-7 > $miditicks) ) { $tempoptr++; }
        $squeeze[$i] = 0.5 * $TIMING_WINDOW * 1e6 / ($tempoevents[$tempoptr][2] + 1e-7);
    }

   return (\%notes2,\%spphrases,\%b2m,\%m2b,\%beatspermeas,\@squeeze);
}


## Midi messages to parse
## Random text: <delta> 255 1 <num bytes> <text>
## Title track: <delta> 255 3 <num bytes> <text>
## End Delim:   <delta> 255 47 0
## Tempo:       <delta> 255 81 3 xx yy zz
## Time sig:    <delta> 255 88 4 num log2(denom) xx yy
## Note on      <delta> 0x8* <note> <velocity>
## Note off     <delta> 0x9* <note> <velocity>
## Continuation <delta> <note less than 0x80> <velocity>


sub parse_track {
    my ($ra) = @_;
    printf "DEBUG: Enter parse track\n" if $DEBUG >= 3;
    my $timestamp = 0;
    my @out = ();
    my $lastcode = 0;
    while (@$ra > 0) {
	my ($deltalen,$delta) = &parse_delta($ra);
	splice @$ra, 0, $deltalen;
	$timestamp += $delta;
	#printf "len:$deltalen delta:$delta timestamp:$timestamp  " . ("\%d " x 25) . "\n", (@$ra)[0 .. 24];

	if    (($ra->[0] == 255) and ($ra->[1] == 1))  { my $len = $ra->[2]; splice @$ra, 0, (3 + $len); }
	elsif (($ra->[0] == 255) and ($ra->[1] == 3))  { my $len = $ra->[2]; splice @$ra, 0, (3 + $len); }
	elsif (($ra->[0] == 255) and ($ra->[1] == 47)) { splice @$ra, 0, 3; last; }

	elsif (($ra->[0] == 255) and ($ra->[1] == 81)) {
	    my $tempo = ($ra->[3] << 16) + ($ra->[4] << 8) + ($ra->[5]);
	    push @out, [ $timestamp, "tempo", $tempo ];
	    splice @$ra, 0, 6;
	}

	elsif (($ra->[0] == 255) and ($ra->[1] == 88)) {
	    my $num = $ra->[3];
	    my $denom = (1 << $ra->[4]); 
	    push @out, [ $timestamp, "timesig", $num, $denom ];
	    splice @$ra, 0, 7;
	}
	elsif ($ra->[0] >= 128) {
	    $lastcode = $ra->[0];
	    my ($note,$velocity) = ($ra->[1], $ra->[2]);

	    if ($lastcode >= 128 and $lastcode < 144) { $velocity = 0; } 
	    push @out, [ $timestamp, "note", $note, $velocity ];
	    printf "DEBUG: ts:$timestamp beat:%.1f code:\%d   note:$note  velocity:$velocity\n", $timestamp/480, $lastcode if $DEBUG >= 3;
	    splice @$ra, 0, 3;
	}
	else {
	    my ($note,$velocity) = ($ra->[0], $ra->[1]);
	    if ($lastcode >= 128 and $lastcode < 144) { $velocity = 0; } 
	    printf "DEBUG: ts:$timestamp beat:%.1f code:\%d   note:$note  velocity:$velocity\n", $timestamp/480, $lastcode if $DEBUG >= 3;
	    push @out, [ $timestamp, "note", $note, $velocity ];
	    splice @$ra, 0, 2;
	}
    }
    return \@out;
}

sub parse_delta {
    my ($ra) = @_;
    if    ($ra->[0] < 128) { return (1,  $ra->[0]); }
    elsif ($ra->[1] < 128) { return (2, (($ra->[0]-128) << 7) + $ra->[1]); }
    elsif ($ra->[2] < 128) { return (3, (($ra->[0]-128) << 14) + (($ra->[1]-128) << 7) + $ra->[2]); }
    else                   { return (4, (($ra->[0]-128) << 21) + (($ra->[1]-128) << 14) + (($ra->[2]-128) << 7) + $ra->[3]); }

}








sub read       { my $self = shift; return $self->_prop("file",@_);    }



