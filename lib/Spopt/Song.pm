package Song;
use strict;
use TempoEvent;
use TimesigEvent;
use Note;
use Pwl;

sub new           { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop         { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub filetype      { my $self = shift; return $self->_prop("filetype",@_);    }
sub game          { my $self = shift; return $self->_prop("game",@_);    }
sub diff          { my $self = shift; return $self->_prop("diff",@_);    }
sub chart         { my $self = shift; return $self->_prop('chart',@_);    }
sub midifile      { my $self = shift; return $self->_prop("midifile",@_);    }
sub notearr       { my $self = shift; return $self->_prop("notearr",@_);    }
sub tempoarr      { my $self = shift; return $self->_prop("tempoarr",@_);    }
sub timesigarr    { my $self = shift; return $self->_prop("timesigarr",@_);    }
sub sparr         { my $self = shift; return $self->_prop("sparr",@_);    }
sub b2mpwl        { my $self = shift; return $self->_prop("b2mpwl",@_);    }
sub m2bpwl        { my $self = shift; return $self->_prop("m2bpwl",@_);    }
sub b2tpwl        { my $self = shift; return $self->_prop("b2tpwl",@_);    }
sub t2bpwl        { my $self = shift; return $self->_prop("t2bpwl",@_);    }
sub t2mpwl        { my $self = shift; return $self->_prop("t2mpwl",@_);    }
sub m2tpwl        { my $self = shift; return $self->_prop("m2tpwl",@_);    }

sub sectionnames  { my $self = shift; return $self->_prop("sectionnames",@_);    }

sub whammy_percent     { my $self = shift; return $self->_prop("whammy_percent",@_);    }
sub whammy_delay       { my $self = shift; return $self->_prop("whammy_delay",@_);    }
sub squeeze_percent    { my $self = shift; return $self->_prop("squeeze_percent",@_);    }
sub sp_squeeze_percent { my $self = shift; return $self->_prop("sp_squeeze_percent",@_); }

sub b2m           { my ($self,$b) = @_; return $self->{b2mpwl}->interpolate($b); }
sub b2t           { my ($self,$b) = @_; return $self->{b2tpwl}->interpolate($b); }
sub m2b           { my ($self,$m) = @_; return $self->{m2bpwl}->interpolate($m); }
sub m2t           { my ($self,$m) = @_; return $self->{m2tpwl}->interpolate($m); }
sub t2b           { my ($self,$t) = @_; return $self->{t2bpwl}->interpolate($t); }
sub t2m           { my ($self,$t) = @_; return $self->{t2mpwl}->interpolate($t); }

sub bpm           { my ($self,$m) = @_; return $self->{bpm}{$m}; }

sub estimate_scores {
    my $self = shift;
    my $na = $self->notearr();
    my ($base,$perfect) = (0,0);
    foreach my $n (@$na) {
	$base    += $n->baseTotScore();
	$perfect += $n->multTotScore();
    }
    my $fours = 2.0 * $base;
    my $fives = ($self->game() eq "gh") ? 3.0 * $base : int (2.8 * $base);
    return ($base,$fours,$fives,$perfect)
}


sub _init {
    my $self = shift;

    $self->diff('expert');
    $self->chart('guitar');
    $self->game('gh3');
    $self->filetype('qb');
    $self->squeeze_percent(0);
    $self->sp_squeeze_percent(0);
    $self->whammy_delay(0);
    $self->whammy_percent(1.00);

    $self->notearr([]);
    $self->tempoarr([]);
    $self->timesigarr([]);
    $self->sparr([]);

    $self->b2mpwl('');
    $self->b2tpwl('');
    $self->t2bpwl('');
    $self->t2mpwl('');
    $self->m2bpwl('');
    $self->m2tpwl('');

    $self->{'bpm'} = {};
    $self->{'sectionnames'} = [];
}

# do a consistency check over the song data
sub check {
    my $self = shift;

    print  "Running Song consistency check.\n";
    printf "Chart: %s\n", $self->chart;
    printf "Difficulty: %s\n", $self->diff;

    my $notes_ref = $self->notearr;
    printf "Chart has %u notes.\n", scalar @$notes_ref;

    print  "Checking notes...\n";
    for my $ref ( @$notes_ref ) {
        
    }

    my $starPower_ref = $self->sparr;
    my $tempo_ref = $self->tempoarr;
    my $timeSig_ref = $self->timesigarr;

    # use Data::Dumper;
    # print Dumper $self->notearr;

    return $self;
}

sub init_phrase_sp_pwls {
    my $self = shift;
    my $spa  = $self->sparr();
    my $na   = $self->notearr();
    for my $i (0 .. @$spa - 1) {
	my $pwl = Pwl->new();
	$self->{_sptick_pwl}[$i] = $pwl;
	$pwl->add_point(0,0);
	my $cumsp = 0;
	my ($dummy,$s) = @{$spa->[$i]};
	my $e = @$na - 1;
	if ($i < @$spa-1) { ($dummy,$e) = @{$spa->[$i+1]}; $e--; }

	for my $j ( $s .. $e ) {
	    next unless $na->[$j]->star();
	    next unless $na->[$j]->sustain();
	    next unless $na->[$j]->totSpTick() > 0;
	    $pwl->add_point($na->[$j]->effectiveSPStartTick(),$cumsp);
	    $cumsp += $na->[$j]->totSpTick(); 
	    $pwl->add_point($na->[$j]->SpEndTick(),$cumsp);
	}
	$pwl->add_point(1e10,$cumsp);
    }
}

sub get_sptick_pwl_points {
    my ($self,$idx) = @_;
    return $self->{_sptick_pwl}[$idx]->get_points();
}

sub get_spticks_after_phrase {
    my ($self,$phraseidx,$tick) = @_;
    if ($tick < 0)   { $tick = 0;   }
    if ($tick > 1e10) { $tick = 1e10; }
    return $self->{_sptick_pwl}[$phraseidx]->interpolate($tick);
}

sub calc_phrase_sp_ticks_sans_last { 
    my ($self,$phraseidx) = @_;
    return $self->_calc_phrase_sp_x($phraseidx,0);
}

sub calc_phrase_sp_ticks { 
    my ($self,$phraseidx) = @_;
    return $self->_calc_phrase_sp_x($phraseidx,1);
}

sub _calc_phrase_sp_x {
    my ($self,$phraseidx,$lastflag) = @_;
    my $na   = $self->notearr();
    my $spa    = $self->sparr();
    my ($s,$e) = @{$spa->[$phraseidx]};
    return 0 if ($s == $e) and not $lastflag;
    $e-- unless $lastflag;
    my $cumsp = 0;
    for my $i ($s .. $e) {
	next unless $na->[$i]->star();
	next unless $na->[$i]->sustain();
	$cumsp += $na->[$i]->totSpTick(); 
    }
    return $cumsp;
}

sub calc_unsqueezed_data {
    my $self = shift;
    my $na = $self->notearr();
    foreach my $n (@$na) { $n->calc_unsqueezed_data($self); }
}

sub calc_squeezed_data {
    my $self = shift;
    my $na = $self->notearr();
    my $diff = $self->diff();
    ##my $rawsec = $diff eq "easy"   ? 1.0/6.0 :
    ##             $diff eq "medium" ? 1.0/8.0 : 1.0/12.0;
    ##my $rawsec = $diff eq "easy"   ? 1.0/8.0 :
    ##             $diff eq "medium" ? 1.0/8.0 : 1.0/12.0;
    ##my $rawsec = $diff eq "easy"   ? 1.0/12.0 :
    ##             $diff eq "medium" ? 1.0/12.0 : 1.0/12.0;

    my $rawsec = $self->game() eq "gh3" ? 1/10.0 : 1/12.0;

    my $ss   = $rawsec * $self->squeeze_percent();
    my $ssps = $rawsec * $self->sp_squeeze_percent();
    my $wd   = $self->whammy_delay();
    my $wp   = $self->whammy_percent();
    my $numnotes = scalar(@$na);

    for my $i (0 .. $numnotes-1) {
	my $prev = $i == 0 ? "NULL" : $na->[$i-1];
        my $note = $na->[$i];
        $note->notecalc_squeezed_data( $prev, $self, $ss, $ssps, $wd, $wp);
    }
}

sub construct_song {
    my $self = shift;
    if ($self->filetype() eq "midi") {
        $self->_gen_tempo_array();
        $self->_gen_timesig_array();
        $self->_gen_measure_beat_structures();
        $self->_gen_note_arr(1,"notearr");
	$self->_gen_sectionnames();
    }

    elsif ($self->filetype() eq 'qb') {
        $self->_qb_gen_tempo_timesig_measure_beat_stuff();
        $self->_qb_gen_note_arr(1,'notearr');
	$self->_qb_gen_sectionnames();
    }

    else { die "Couldn't figure out filetype in Song::construct_song\n"; }

    $self->_associate_tempos("notearr");
    $self->initialize_multipliers();
}

sub _gen_sectionnames {
    my $self = shift;
    @{$self->{sectionnames}} = ();
    my $mf   = $self->midifile();
    my $ra = $mf->getall();
    my @a = grep { $_->argstr() =~ /\[section/ } @$ra;
    foreach my $a (@a) {
	my $tick = $a->tick();
	my $txt  = $a->argstr();
	$txt =~ s/\[section //;
	$txt =~ s/\]//;
	my $meas = $self->t2m($tick);
	push @{$self->{sectionnames}}, [$meas, $txt];
    }
}

sub _qb_gen_sectionnames {
    my $self = shift;
    @{$self->{sectionnames}} = ();
    my $mf   = $self->midifile();
    my $rmarkers = $mf->get_markers();

    ## Now we just have to convert from ms2tick and then t2m
    foreach my $rm (@$rmarkers) {
	my $tick = $self->{_qbstuff}{ms2tick}->interpolate($rm->[0]);
	my $meas = $self->t2m($tick);
	push @{$self->{sectionnames}}, [$meas, $rm->[1]];
    }
}

sub initialize_multipliers {
    my $self = shift;
    my $na = $self->notearr();

    if ($self->game() eq "gh") {
        for my $i ( 0 .. @$na-1 ) {
            my $mult     = $i < 10  ? 1 : $i < 20 ? 2 : $i < 30 ? 3 : 4;
            my $multsust = $i < 9   ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
            $na->[$i]->mult($mult);
            $na->[$i]->multsust($multsust);
        }
    }

    else {
        for my $i ( 0 .. @$na-1 ) {
            my $mult     = $i < 9  ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
            my $multsust = $i < 9  ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
            $na->[$i]->mult($mult);
            $na->[$i]->multsust($multsust);
        }
    }
}

sub insert_misses {
    my ($self,$startMeas,$stopMeas) = @_;
    my $na = $self->notearr();
    my $last = @$na - 1;
    my $startidx = -1;
    my $stopidx = -1;
    for my $i ( 0 .. $last ) {
	my $sm = $self->t2m($na->[$i]->startTick());
	$startidx = $i if $sm < $startMeas;
	$stopidx = $i  if $sm < $stopMeas;
    }
    $startidx++;
    if ($startidx <= $stopidx) { for my $i ( $startidx .. $stopidx ) { $na->[$i]->mult(1); } }

    my $maxi = $stopidx > $last - 29 ? $last - $stopidx : 29;

    if ($self->game() eq "gh") {
	for my $i ( 1 .. $maxi ) { 
            my $mult     = $i < 10 ? 1 : $i < 20 ? 2 : $i < 30 ? 3 : 4;
            my $multsust = $i < 9  ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
	    next if $na->[$stopidx+$i]->mult() < $mult;
            $na->[$stopidx+$i]->mult($mult);
            $na->[$stopidx+$i]->multsust($multsust);
        }
    }

    else {
	for my $i ( 1 .. $maxi ) { 
            my $mult     = $i < 9  ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
            my $multsust = $i < 9  ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
	    next if $na->[$stopidx+$i]->mult() < $mult;
            $na->[$stopidx+$i]->mult($mult);
            $na->[$stopidx+$i]->multsust($multsust);
        }
    }
}


sub _gen_measure_beat_structures {
    my $self = shift;
    my @pwl = map { Pwl->new() } (0 .. 5);
    $self->b2tpwl($pwl[0]);
    $self->b2mpwl($pwl[1]);
    $self->m2tpwl($pwl[2]);
    $self->m2bpwl($pwl[3]);
    $self->t2bpwl($pwl[4]);
    $self->t2mpwl($pwl[5]);

    ## First, get all of the time signature events out of the first midi track
    my $mf = $self->midifile();
    my @aa = $mf->gettrack(0);
    my @timesigs = grep { $_->eventstr() eq "timesig" or $_->eventstr() eq "endtrack" } @aa;

    ## Deal with the initial time signature
    my $bpm = $timesigs[0]->argint1();
    my $lastmeas = 1;
    my $lasttick = 0;
    $self->_add_tbm_point(0,0,1);
    shift @timesigs;

    foreach my $tt (@timesigs) {
	if ($tt->eventstr eq "endtrack") {
	    ## End track doesn't HAVE to land on a measure boundary,
	    ## so we just use this as a sign to extend the
	    ## last true timesig event by 10000 measures (more than we believe will be in any song)
	    my $lastbeat = int ($lasttick / 480 + 1e-7);
	    $self->_add_tbm_point($lasttick + 480*$bpm*10000, $lastbeat + $bpm * 10000, $lastmeas + 10000);
	    for my $i ( $lastmeas .. $lastmeas+10000) { $self->{bpm}{$i} = $bpm; }
	    last;
	}

	else {
	    my $tick = $tt->tick();
	    my $beat = int ($tick / 480 + 1e-7);
	    my $meas = $lastmeas + int ( ($tick - $lasttick) / 480 / $bpm + 1e-7 );
	    $self->_add_tbm_point($tick,$beat,$meas);
	    for my $i ( $lastmeas .. $meas-1 ) { $self->{bpm}{$i} = $bpm; }
	    $lastmeas = $meas;
	    $lasttick = $tick;
	    $bpm = $tt->argint1();
	}
    }
}

sub _add_tbm_point {
    my ($self,$t,$b,$m) = @_;
    $self->{b2tpwl}->add_point($b,$t);
    $self->{t2bpwl}->add_point($t,$b);
    $self->{b2mpwl}->add_point($b,$m);
    $self->{m2bpwl}->add_point($m,$b);
    $self->{t2mpwl}->add_point($t,$m);
    $self->{m2tpwl}->add_point($m,$t);
}

sub _qb_gen_tempo_timesig_measure_beat_stuff {
    my $self = shift;
    my $qbf = $self->midifile();
    my $rbeat    = $qbf->get_beats();
    my $rtimesig = $qbf->get_timesig();

    ## Set up the conversion from the millisecond domain to the beat domain
    $self->{_qbstuff}{ms2beat} = Pwl->new();
    $self->{_qbstuff}{beat2ms} = Pwl->new();
    $self->{_qbstuff}{ms2tick} = Pwl->new();
    $self->{_qbstuff}{tick2ms} = Pwl->new();
    for my $i (0 .. @$rbeat - 1) {
        $self->{_qbstuff}{ms2beat}->add_point( $rbeat->[$i], $i );
        $self->{_qbstuff}{beat2ms}->add_point( $i, $rbeat->[$i] );
        $self->{_qbstuff}{ms2tick}->add_point( $rbeat->[$i], 480 * $i );
        $self->{_qbstuff}{tick2ms}->add_point( 480 * $i, $rbeat->[$i] );
    }

    ## We can do the timesig stuff easy
    ## We assume a track where the timesigs align to a 480
    my $numtimesig = @$rtimesig;
    die "No timesigs" if $numtimesig == 0;
    for my $i ( 0 .. $numtimesig-1 ) {
	my $ms = $rtimesig->[$i][0];
	my $beat = $self->{_qbstuff}{ms2beat}->interpolate($ms);
	my $tick = 30 * int(16 * $beat + 0.5);
	$tick % 480 == 0 or print STDERR "Timesig event doesn't align to a beat boundary here\n";
	my $te = new TimesigEvent;
	$te->tick($tick);
	$te->bpm($rtimesig->[$i][1]);
	push @{$self->{timesigarr}}, $te;
    }

    ## bmt stuff
    my @pwl = map { Pwl->new() } (0 .. 5);
    $self->b2tpwl($pwl[0]);
    $self->b2mpwl($pwl[1]);
    $self->m2tpwl($pwl[2]);
    $self->m2bpwl($pwl[3]);
    $self->t2bpwl($pwl[4]);
    $self->t2mpwl($pwl[5]);

    ## Convert the beat array and timesig array into synthesized tempo events
    my $tt = 0;
    my $bb = 0;
    my $bpmeas = $rtimesig->[$tt][1];
    my $numbeats = @$rbeat;

    my $measnum = 1;

    while ($bb < $numbeats + 1000) {
	my $time = $rbeat->[$bb];
        if ($tt < $numtimesig-1 and $rtimesig->[$tt+1][0] < $rbeat->[$bb] + 5) { $tt++; }
	my $bpmeas = $rtimesig->[$tt][1];

	my $tempo = 0;
        $self->_add_tbm_point(480.0 * $bb, $bb, $measnum);
	$self->{bpm}{$measnum} = $bpmeas;

	if ($bb < $numbeats - 1) {
            if ($bb + $bpmeas < $numbeats - 1) { $tempo = int (1000 * ($rbeat->[$bb+$bpmeas] - $rbeat->[$bb]) / (1.0 * $bpmeas) ); }
	    else                               { $tempo = int (1000 * ($rbeat->[$numbeats-1] - $rbeat->[$bb]) / (1.0 * ($numbeats-$bb-1) ) ); }
	    my $tick = 480 * $bb;
	    my $te = new TempoEvent;
	    $te->tick($tick);
	    $te->tempo($tempo);
	    push @{$self->{tempoarr}}, $te;
	}
        $bb += $bpmeas;
	$measnum++;
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

sub _gen_timesig_array() {
    my $self = shift;
    my $mf = $self->midifile();
    my @aa = $mf->gettrack(0);
    my $lte = new TimesigEvent;
    my $lasttick = 0;
    foreach my $e (@aa) {
	$lte->tick($e->tick());
	next unless $e->eventstr() eq "timesig";
	my $te = new TimesigEvent;
	$te->populateFromMidiEvent($e);
	$lte->bpm($te->bpm());
	push @{$self->{timesigarr}}, $te;
    }
    push @{$self->{timesigarr}}, $lte;
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

sub _weed_out_bad_noteon_events {
    my ($self,$ra,$left,$right) = @_;
    my $lastnoteidx = 0;
    my $lasttime = 0;
    my $laststatus = "noteoff";
    for my $ni ($left .. $right) {
	my @events = grep { $_->argint1() == $ni and $_->eventstr() =~ /^note(on|off)$/ } @$ra;
	next unless @events > 0;
	for my $i ( 0 .. scalar(@events)-1 ) {
	    if ($laststatus eq "noteon" and $events[$i]->eventstr() eq "noteon" and $lasttime != $events[$i]->tick()) {
		## The last note is bogus, so we just change the argint1 to 9999
		$events[$lastnoteidx]->argint1(9999);
	    }
	    $laststatus = $events[$i]->eventstr();
	    if ($laststatus eq "noteon") {
		$lasttime = $events[$i]->tick();
		$lastnoteidx = $i;
	    }
	}
    }	
}

sub _qb_gen_note_arr {
    my ($self,$tracknum,$arrstring) = @_;
    my $diff = $self->diff();
    my $chart = $self->chart();
    my $qbf = $self->midifile();
    my $qbfna = $qbf->get_notearr($chart,$diff);
    my $sustainthresh = $qbf->sustainthresh();
    for (my $i = 0; $i < @$qbfna; $i++) {
	my ($msstart,$mslen,$notebv) = @{$qbfna->[$i]};
	my $nn = Note->new();
	$nn->idx($i);
	$nn->star(0);
	$notebv = $notebv & 0b00111111;
	if ($notebv & 0x1)  { $nn->green(1);}
	if ($notebv & 0x2)  { $nn->red(1);}
	if ($notebv & 0x4)  { $nn->yellow(1);}
	if ($notebv & 0x8)  { $nn->blue(1);}
	if ($notebv & 0x10) { $nn->orange(1);}
	if ($notebv & 0x20) { $nn->purple(1);}
	$nn->startTick($self->{_qbstuff}{ms2tick}->interpolate($msstart));
	$nn->endTick($mslen > $sustainthresh ? $self->{_qbstuff}{ms2tick}->interpolate($msstart+$mslen) : $nn->startTick());
	push @{$self->{$arrstring}}, $nn;
    }

    ## Now we do the SP stuff
    my $qbfspa = $qbf->get_sparr($chart,$diff);
    $self->{sparr} = [];
    for (my $i = 0; $i < @$qbfspa; $i++) {
	push @{$self->{sparr}}, [ @{$qbfspa->[$i]} ];
	for ( my $j = $qbfspa->[$i][0]; $j <= $qbfspa->[$i][1]; $j++ ) {
            $self->{$arrstring}[$j]->star(1);
        }
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
    my $sp = "off";

    my $last_noteon_time = 0;

    ## We have to sort the events by the following rules
    ## Timestamp, smallest to biggest
    ## noteoff events for the 7 mod 12 note
    ## noteon  events for the 7 mod 12 note
    ## noteoff events for the other notes
    ## noteon  events for the other notes

    ##@aa = sort { (($a->tick() cmp $b->tick()) or
    ##( ($a->argint1() % 12 == 7) and ($b->argint1() % 12 != 7) ? -1 :
    ##($a->argint1() % 12 != 7) and ($b->argint1() % 12 == 7) ?  1 : 0 ) or
    ##($a->eventstr() cmp $b->eventstr()) or
    ##($a->argint1()  <=> $b->argint1())) } @aa;

    $self->_weed_out_bad_noteon_events(\@aa,$offset,$offset+7);
    my $spstate = "off";
    my @spa = ();

    foreach my $e (@aa) {
	my $time = $e->tick();
	if ($e->eventstr() eq "noteon") {
	    my $notenum = $e->argint1();
	    next unless $notenum >= $offset and $notenum < $offset+12;
	    my $color =  ($notenum % 12 == 0) ? "green" :
	                 ($notenum % 12 == 1) ? "red" :
	                 ($notenum % 12 == 2) ? "yellow" :
	                 ($notenum % 12 == 3) ? "blue" :
	                 ($notenum % 12 == 4) ? "orange" : "none";

	    ## This is to deal with a special case when chords
	    ## don't line up perfectly.  Strutter PS2 Expert
	    ## has an example of this here
	    if ( ($e->argint1() >= $offset + 0) and
                 ($e->argint1() <= $offset + 4) and
		 ($time > $last_noteon_time)    and 
		 ($time - $last_noteon_time) < 15 ) {
	       $time = $last_noteon_time;
	    }

	    elsif ( ($e->argint1() >= $offset + 0) and
                    ($e->argint1() <= $offset + 4) ) {
	        $last_noteon_time = $time; 
	    }

	    if ($e->argint1() == $offset + 0) { $notes{$time}{green}  = "on"; $sp{$time} = $spstate; }
	    if ($e->argint1() == $offset + 1) { $notes{$time}{red}    = "on"; $sp{$time} = $spstate; }
	    if ($e->argint1() == $offset + 2) { $notes{$time}{yellow} = "on"; $sp{$time} = $spstate; }
	    if ($e->argint1() == $offset + 3) { $notes{$time}{blue}   = "on"; $sp{$time} = $spstate; }
	    if ($e->argint1() == $offset + 4) { $notes{$time}{orange} = "on"; $sp{$time} = $spstate; }
	    if ($e->argint1() == $offset + 7 and $spstate eq "off") {$spstate = "on"; push @spa, $time; }
	    if ($e->argint1() == $offset + 9) { $player{$time}        = "on"; }
	}

	if ($e->eventstr() eq "noteoff") {
	    my $notenum = $e->argint1();
	    next unless $notenum >= $offset and $notenum < $offset+12;
	    my $color =  ($notenum % 12 == 0)     ? "green" :
	                 ($notenum % 12 == 1)     ? "red" :
	                 ($notenum % 12 == 2)     ? "yellow" :
	                 ($notenum % 12 == 3)     ? "blue" :
	                 ($notenum % 12 == 4)     ? "orange" : "none";

	    ## This is to deal with notes that turn off just a little after a note has turned on.
	    ## We don't like these timestamps screwing things, up, so we muck with them
	    ## Caveat -- we can't pre-emptively move these if the previous time had a noteon event for the
	    ## same note -- we should have two note-on events then
	    if ( ($e->argint1() >= $offset + 0) and
                 ($e->argint1() <= $offset + 4) and
		 ($time > $last_noteon_time)    and 
		 (($time - $last_noteon_time) < 15 ) and
		 ($color eq "none" or not exists $notes{$last_noteon_time}{$color} or $notes{$last_noteon_time}{$color} ne "on") ) {
	       $time = $last_noteon_time;
	    }

	    if ($e->argint1() == $offset + 0) { $notes{$time}{green}  = "off"; }
	    if ($e->argint1() == $offset + 1) { $notes{$time}{red}    = "off"; }
	    if ($e->argint1() == $offset + 2) { $notes{$time}{yellow} = "off"; }
	    if ($e->argint1() == $offset + 3) { $notes{$time}{blue}   = "off"; }
	    if ($e->argint1() == $offset + 4) { $notes{$time}{orange} = "off"; }
	    if ($e->argint1() == $offset + 7 and $spstate eq "on") {$spstate = "off"; push @spa, $time; }
	    if ($e->argint1() == $offset + 9) { $player{$time}        = "off"; }
	}
    }

    my @ts = sort { $a <=> $b } (keys %notes);

    ## Coallesce the notes
    my $noteidx = 0;
    for my $i ( 0 .. scalar(@ts)-1) {
	my $time = $ts[$i];
	my @buttons = keys %{$notes{$time}};
	@buttons = grep { $notes{$time}{$_} eq "on" } @buttons;
	next unless @buttons > 0;
	my $nn = Note->new();
	$nn->idx($noteidx); $noteidx++;

	if ($sp{$time} eq "on") { $nn->star(1); }
	else                    { $nn->star(0); }

	foreach my $color (@buttons) {
	    if ($color eq "green")    { $nn->green(1); }
	    if ($color eq "red")      { $nn->red(1); }
	    if ($color eq "yellow")   { $nn->yellow(1); }
	    if ($color eq "blue")     { $nn->blue(1); }
	    if ($color eq "orange")   { $nn->orange(1); }
	}
	$nn->startTick($time);
        if    ($i == scalar(@ts)-1)       { $nn->endTick($time); }
        elsif ($ts[$i+1] - $ts[$i] < 161) { $nn->endTick($time); }
        else                              { $nn->endTick($ts[$i+1]); }

	push @{$self->{$arrstring}}, $nn;
    }

    ## Deal with the SP phrases
    $self->{sparr} = [];
    my $idx = 0;
    my $na = $self->{$arrstring};
    while (@spa > 0 and $idx < @$na )  {
	if     ($na->[$idx]->startTick() < $spa[0]) { $idx++; next; }
	elsif  ($na->[$idx]->startTick() >= $spa[1]) { shift @spa; shift @spa; next; }
	my $idx2 = $idx;
	while ($idx2 < @$na-1 and $na->[$idx2+1]->startTick() < $spa[1]) { $idx2++; }
	## Deal with a corner case where the first note sometimes doesn't get flagged because of event ordering
	$na->[$idx]->star(1);
	push @{$self->{sparr}}, [$idx,$idx2];
	$idx = $idx2+1;
	shift @spa; shift @spa;
    }

    ##my $spstate = "off";
    ##my $start = 0;
    ##my $end = 0;
    ##for my $i ( 0 .. @{$self->{$arrstring}}-1 ) {
    ##    if ($spstate eq "off") {
    ##        next unless $self->{$arrstring}[$i]->star();
    ##        $spstate = "on";
    ##        $start = $i;
    ##        $end = $i;
    ##    }

    ##    elsif ($i == @{$self->{$arrstring}}-1) {
    ##        push @{$self->{sparr}}, [$start,$i];
    ##        $spstate = "off";
    ##    }

    ##    elsif ($self->{$arrstring}[$i]->star()) { $end++; }

    ##    else {
    ##        $spstate = "off";
    ##        push @{$self->{sparr}}, [$start,$end];
    ##    }
    ##}
}
    
	    

sub find_note_idx_after_squeezed {
    my ($self,$tick) = @_;
    my $na = $self->notearr();
    return -1 if $na->[-1]->rightStartTick() <= $tick;
    return 0 if $tick < $na->[0]->rightStartTick();
    my $left = 0; my $right = @$na - 1;
    while ($right - $left > 1 + 1e-7) {
	my $mid = int (($right + $left)/2.00 + 1e-7);
	if ($tick >= $na->[$mid]->rightStartTick()) { $left = $mid; }
	else                                        { $right = $mid; }
    }
    return $right;
}

sub find_note_idx_before_squeezed {
    my ($self,$tick) = @_;
    my $na = $self->notearr();
    return (@$na-1) if $na->[-1]->leftStartTick() < $tick;
    return -1 if $tick <= $na->[0]->leftStartTick();
    my $left = 0; my $right = @$na - 1;
    while ($right - $left > 1 + 1e-7) {
	my $mid = int (($right + $left)/2.00 + 1e-7);
	if ($tick >  $na->[$mid]->leftStartTick()) { $left = $mid; }
	else                                       { $right = $mid; }
    }
    return $left;
}

sub clear_score_cache {
    my $self = shift;
    $self->{scorecache} = {};
}

sub score_range {
    my ($self,$leftidx,$rightidx) = @_;
    if (defined $self->{scorecache}{$leftidx}{$rightidx})   { return @{$self->{scorecache}{$leftidx}{$rightidx}}; }

    if ($rightidx-$leftidx < 1e-7) { 
	my $na = $self->notearr();
	my @a = ($na->[$leftidx]->multNoteScore(),
	         $na->[$leftidx]->multSustScore(),
	         $na->[$leftidx]->multTotScore());
	$self->{scorecache}{$leftidx}{$rightidx} = [@a]; 
	return @a;
    }

    if ($rightidx-$leftidx < 1+1e-7) { 
	my $na = $self->notearr();
	my @a1 = ($na->[$leftidx]->multNoteScore(),
	          $na->[$leftidx]->multSustScore(),
	          $na->[$leftidx]->multTotScore());

	my @a2 = ($na->[$rightidx]->multNoteScore(),
	          $na->[$rightidx]->multSustScore(),
	          $na->[$rightidx]->multTotScore());

	my @a = map { $a1[$_]+$a2[$_] } (0,1,2);

	$self->{scorecache}{$leftidx}{$rightidx} = [@a]; 
	return @a;
    }
    my $mid=  int (($leftidx+$rightidx)/2 + 1e-7);
    my @a1 = $self->score_range($leftidx,$mid);
    my @a2 = $self->score_range($mid+1,$rightidx);
    my @a = map { $a1[$_]+$a2[$_] } (0,1,2);
    $self->{scorecache}{$leftidx}{$rightidx} = [@a]; 
    return @a;
}

sub sprintme {
    my $self = shift;
    my $na = $self->notearr();
    my $out = "";
    for my $i ( 0 .. @$na-1 ) {
	$out .= sprintf "%4d %8d %8d %8d %3d %7.3f %6.3f %1d %1d %1dx %-3s %4d %4d %4d %4d %4d %4d SP:%4d\n",
            $i,
            $na->[$i]->leftStartTick(),
            $na->[$i]->startTick(),
            $na->[$i]->rightStartTick(),
            $na->[$i]->rightStartTick() - $na->[$i]->leftStartTick(),
            $na->[$i]->startMeas(),
            $na->[$i]->lenBeat(),
            $na->[$i]->sustain(),
            $na->[$i]->star(),
            $na->[$i]->mult(),
            $na->[$i]->notestr(),
	    $na->[$i]->baseNoteScore(),
	    $na->[$i]->baseSustScore(),
	    $na->[$i]->baseTotScore(),
	    $na->[$i]->multNoteScore(),
	    $na->[$i]->multSustScore(),
	    $na->[$i]->multTotScore(),
	    $na->[$i]->totSpTick();
    }
    return $out;
}

1;

