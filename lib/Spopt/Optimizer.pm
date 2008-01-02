package Optimizer;
use strict;
use Activation;
use Solution;

sub new        { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop      { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub whammy_per_quarter_bar  { my $self = shift; return $self->_prop("whammy_per_quarter_bar",@_);  }
sub delay_per_quarter_bar  { my $self = shift; return $self->_prop("delay_per_quarter_bar",@_);  }
sub song       { my $self = shift; return $self->_prop("song",@_);  }
sub game       { my $self = shift; return $self->_prop("game",@_);  }
sub debug      { my $self = shift; return $self->_prop("debug",@_);  }

sub _init {
    my $self = shift;
    $self->game("gh2");
    $self->whammy_per_quarter_bar(7.5);
    $self->delay_per_quarter_bar(9.0/24.0);
}

sub get_summary {
    my $self = shift;
    my $out = "";
    my $song = $self->song();
    my $spa = $song->sparr();
    my $last = scalar(@$spa);
    my $numreports = scalar @{$self->{_scoreboard}[$last]};
    $numreports = 5 if $numreports > 5;
    die "No final solutions" if $numreports == 0;
    for my $i (0 .. $numreports-1) {
	my $score   = $self->{_scoreboard}[$last][$i]->score();
	my $pathstr = $self->{_scoreboard}[$last][$i]->pathstr();
	$out .= sprintf "SP Score: %6d  Pathstr: $pathstr\n", $score;
    }
    return $out;
}

sub get_solutions {
    my $self = shift;
    my $song = $self->song();
    my $spa = $song->sparr();
    my $last = scalar(@$spa);
    return @{$self->{_scoreboard}[$last]};
}

sub gen_interesting_events {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();
    $self->{_start_events} = [];
    $self->{_end_events} = [];
    foreach my $n (@$na) {
	push @{$self->{_start_events}}, $n->startTick()-2;
	push @{$self->{_start_events}}, $n->rightStartTick()-2;
	push @{$self->{_end_events}}, $n->leftStartTick()+2;
	push @{$self->{_end_events}}, $n->startTick()+2;
	next unless $n->sustain();
	push @{$self->{_end_events}}, $n->endTick();
    }
    @{$self->{_start_events}} = sort {$a <=> $b} @{$self->{_start_events}};
    @{$self->{_end_events}}   = sort {$a <=> $b} @{$self->{_end_events}};
}

sub __binsearch_find_next_idx {
    my ($ra,$x) = @_;
    if ($x > $ra->[-1]) { return @$ra-1; }
    if ($x < $ra->[0])  { return 0; }
    my ($left,$right) = (0,@$ra-1);
    while ($right-$left>1) {
	my $mid = int (0.5 * ($right+$left) + 1e-7);
	if ($ra->[$mid] > $x)  { $right = $mid; }
	else                   { $left  = $mid; }
    }
    return $right;
}

sub get_compressed_activation {
    my ($self,$idx,$compsp,$optsp) = @_;
    my $dpqb = $self->delay_per_quarter_bar();
    my $totsp = $compsp+$optsp;
    $totsp = 8.0 if $totsp > 8.0;
    $compsp = 8.0 if $compsp > 8.0;
    return () if $totsp < 4.0 - 1e-7;

    my $song = $self->song();
    my $na = $song->notearr();
    my $spa = $song->sparr();
    my @out = ();

    ## We calculate the delay for an activation.
    my $delayTicks = 2;
    if ($self->game() eq "gh") {
        $delayTicks = $totsp >= 6.0 ? 0 : (6.0 - $totsp)/2 * $dpqb * 1e6 / $na->[$spa->[$idx][1]]->currTempo()->tempo() * 480;
	$delayTicks = 2 if $delayTicks<2;
    }

    my $leftTick1 = $na->[$spa->[$idx][1]]->leftStartTick() + $delayTicks;
    my $leftTick2 = &__max($leftTick1,$na->[$spa->[$idx][1]]->rightStartTick() - 2);

    ## The reason for the complexity is to pick up cases where an activation bleeds into the start
    ## of the next sp phrase (even if its a full activation).
    if ($na->[$spa->[$idx][1]]->sustain() and $delayTicks > 2) {
        my ($s2epwl,$e2spwl,$sppwl,$crossover_points) = $self->_gen_sp_pwls($idx,$compsp+$optsp,$leftTick1,$leftTick2+$delayTicks);
	$totsp = $sppwl->interpolate($song->t2m($leftTick1+$delayTicks));
	$totsp = 8 if $totsp > 8;
    }

    for (my $i = $idx+1; $i < @$spa; $i++) {


        my $rightTick2 = $na->[$spa->[$i][0]]->rightStartTick() - 2;
        my $rightTick1 =&__min($rightTick2,$na->[$spa->[$i][0]]->leftStartTick() + 2);

	my ($leftTick,$rightTick,$leftmeas,$rightmeas,$leftidx,$rightidx);

	my $leftMeas1  = $song->t2m($leftTick1);
	my $leftMeas2  = $song->t2m($leftTick2);
	my $rightMeas1 = $song->t2m($rightTick1);
	my $rightMeas2 = $song->t2m($rightTick2);

	last if ($rightMeas1-$leftMeas2) > $totsp;
	next if ($rightMeas2-$leftMeas1) < $compsp;
	next if ($rightMeas2-$leftMeas1) < 4.0-1e-7;

        $leftidx  =  $spa->[$idx][1] + 1;
	$rightidx = ($i == @$spa-1 ? scalar(@$na)-1 : $spa->[$i][0] - 1);

	if ($leftMeas2 + $compsp > $rightMeas2) {
	    $rightmeas = $rightMeas2;
	    $leftmeas  = $rightMeas2-$compsp;
	}
	else {
	    $leftmeas   = $leftMeas2;
	    $rightmeas  = &__max($leftmeas+$compsp, $rightMeas1);
	}

	$leftTick  = $song->m2t($leftmeas);
	$rightTick = $song->m2t($rightmeas);

	##if ($self->game() eq 'gh3') {
	##    last if (($rightTick1-$leftTick2)/480.0/4.0) > $totsp;
	##    next if (($rightTick2-$leftTick1)/480.0/4.0) < $compsp;
	##    next if (($rightTick2-$leftTick1)/480.0/4.0) < 4.0-1e-7;

        ##    $leftidx  =  $spa->[$idx][1] + 1;
	##    $rightidx = ($i == @$spa-1 ? scalar(@$na)-1 : $spa->[$i][0] - 1);

	##    if ($leftTick2 + 480.0*4.0*$compsp > $rightTick2) {
	##	$rightTick = $rightTick2;
	##	$leftTick = $leftTick2 - 480.0*4.0*$compsp;
	##    }

	##    else {
	##	$leftTick = $leftTick2;
	##	$rightTick = &__max($leftTick+480.0*4.0*$compsp,$rightTick1);
	##    }
	##}

	##else {
	##    my $leftMeas1  = $song->t2m($leftTick1);
	##    my $leftMeas2  = $song->t2m($leftTick2);
	##    my $rightMeas1 = $song->t2m($rightTick1);
	##    my $rightMeas2 = $song->t2m($rightTick2);

	##    last if ($rightMeas1-$leftMeas2) > $totsp;
	##    next if ($rightMeas2-$leftMeas1) < $compsp;
	##    next if ($rightMeas2-$leftMeas1) < 4.0-1e-7;

        ##    $leftidx  =  $spa->[$idx][1] + 1;
	##    $rightidx = ($i == @$spa-1 ? scalar(@$na)-1 : $spa->[$i][0] - 1);

	##    if ($leftMeas2 + $compsp > $rightMeas2) {
	##        $rightmeas = $rightMeas2;
	##        $leftmeas  = $rightMeas2-$compsp;
	##    }
	##    else {
	##        $leftmeas   = $leftMeas2;
	##        $rightmeas  = &__max($leftmeas+$compsp, $rightMeas1);
	##    }

	##    $leftTick  = $song->m2t($leftmeas);
	##    $rightTick = $song->m2t($rightmeas);
	##}

	my $act = new Activation;
	$act->song($song);
	$act->compulsorySP($compsp);
	$act->optionalSPAvailable($totsp-$compsp);

	$act->optionalSPUsed($rightmeas-$leftmeas-$compsp);
	##if ($self->game() eq "gh3") { $act->optionalSPUsed(($rightTick-$leftTick)/480.0/4.0-$compsp); }
	##else {                        $act->optionalSPUsed($rightmeas-$leftmeas-$compsp); }

	$act->compressed_flag(1);
	$act->lastSPidx($idx);
	$act->startTick($leftTick);
	$act->endTick($rightTick);
	$act->leftNoteIdxLimit($leftidx);
	$act->rightNoteIdxLimit($rightidx);
	$act->scoreMe();
	if ($act->totScore > 0) { push @out, $act; }
    }
    return @out;
}


sub get_uncompressed_activation {
    my ($self,$idx,$compsp,$optsp) = @_;
    my $debug = $self->debug();
    my $dpqb = $self->delay_per_quarter_bar();
    my @acts = ();
    my $song = $self->song();
    my $na = $song->notearr();
    my $spa = $song->sparr();

    my $totsp = $compsp+$optsp;
    my $delayTicks = 2;
    if ($self->game() eq "gh") {
        $delayTicks = $totsp >= 6.0 ? 0 : (6.0 - $totsp)/2 * $dpqb * 1e6 / $na->[$spa->[$idx][1]]->currTempo()->tempo() * 480;
	$delayTicks = 2 if $delayTicks<2;
    }

   
    ## This is a GH1 band-aid to deal with whammy delay 
    my $leftTick = $na->[$spa->[$idx][1]]->effectiveSPStartTick() + $delayTicks;
    my ($leftTick1, $leftTick2);
    if ($delayTicks > 2) {

	## We have to do a quick check to see if the previous note is a sustain
	my $leftTick0 = (($spa->[$idx][1] - $spa->[$idx][0] > 0) and 
	                ($na->[$spa->[$idx][1]-1]->sustain())) ? $na->[$spa->[$idx][1]-1]->endTick() : 0;

        $leftTick1 = &__max($na->[$spa->[$idx][1]]->leftStartTick(),$leftTick0) + $delayTicks;
        $leftTick2 = $na->[$spa->[$idx][1]]->effectiveSPStartTick() + $delayTicks;
	$leftTick = &__min($leftTick1,$leftTick2);
    }

    my $rightTick = ($idx == @$spa-1 ? $na->[-1]->endTick() : $na->[$spa->[$idx+1][1]]->rightStartTick()-2); 
    my $leftidx =  $spa->[$idx][1] + 1;
    my $rightidx = 1e9;
    
    my ($s2epwl,$e2spwl,$sppwl,$crossover_points) = $self->_gen_sp_pwls($idx,$compsp+$optsp,$leftTick,$rightTick);
    my @xover_ticks = map { $song->m2t($_) } @$crossover_points;
    my @local_events = sort {$a <=> $b} ($leftTick,$rightTick,@xover_ticks);

    ## More GH1 whammy delay band-aids
    if ($delayTicks > 2) {
        @local_events = sort {$a <=> $b} ($leftTick1,$leftTick2,$rightTick,@xover_ticks);
    }


    my $start_event_idx = &__binsearch_find_next_idx($self->{_start_events},$leftTick);
    my $end_event_idx   = &__binsearch_find_next_idx($self->{_end_events},  $leftTick);
    my $local_event_idx = &__binsearch_find_next_idx(\@local_events,$leftTick);

    my $cursor = $leftTick;
    while ($cursor <= $rightTick) {

	my $startmeas = $song->t2m($cursor);
	my $totsp = $sppwl->interpolate($startmeas);
	##print "DEBUG:    Trying cursor=$cursor (sp=$totsp)\n" if $debug;
	my $totoptsp = $totsp - $compsp;

	my $endtick;

	##if ($self->game() eq "gh3") { $endtick = $cursor + 480.0*4.0*$totsp; }
	##else { my $endmeas  = $s2epwl->interpolate($startmeas); $endtick  = $song->m2t($endmeas); }
	my $endmeas  = $s2epwl->interpolate($startmeas);
	$endtick  = $song->m2t($endmeas);

	if ($totsp >= 4.00 - 1e-7) {
	    my $act = new Activation;
	    $act->song($song);
	    $act->compulsorySP($compsp);
	    $act->optionalSPAvailable($totoptsp);
	    $act->optionalSPUsed($totoptsp);
	    $act->compressed_flag(0);
	    $act->lastSPidx($idx);
	    $act->startTick($cursor);
	    $act->endTick($endtick);
	    $act->leftNoteIdxLimit($leftidx);
	    $act->rightNoteIdxLimit($rightidx);
	    $act->scoreMe();
	    push @acts, $act if $act->totScore > 0;
	    print ("DEBUG:        ".$act->sprintme()."\n") if ($debug and $act->totScore > 0);

	    ## Do a quick check to see if this activation ends at the start of an SP phrase --
	    ## if so, we create another activation that doesn't include the SP note so as to
	    ## preserve the SP phrase
            for (my $i = $idx+1; $i < @$spa; $i++) {
		last if ($act->endTick() <  $na->[$spa->[$i][0]]->leftStartTick());
		next if ($act->endTick() >= $na->[$spa->[$i][0]]->rightStartTick());
	        my $act2 = new Activation;
	        $act2->song($song);
	        $act2->compulsorySP($compsp);
	        $act2->optionalSPAvailable($totoptsp);
	        $act2->optionalSPUsed($totoptsp);
	        $act2->compressed_flag(0);
	        $act2->lastSPidx($idx);
	        $act2->startTick($cursor);
	        $act2->endTick($endtick);
	        $act2->leftNoteIdxLimit($leftidx);
	        $act2->rightNoteIdxLimit($spa->[$i][0]-1);
	        $act2->scoreMe();
		push @acts, $act2 if $act2->totScore > 0;
		print ("DEBUG:        ".$act2->sprintme()."\n") if ($debug and $act2->totScore > 0);
	    }
	}

	## Now we adjust the various pointers
	while ($cursor  >= $self->{_start_events}[$start_event_idx]-1 and $start_event_idx < @{$self->{_start_events}}-1) { $start_event_idx++; }
	while ($endtick >= $self->{_end_events}[$end_event_idx]-1     and $end_event_idx   < @{$self->{_end_events}}-1)   { $end_event_idx++;   }
	while ($cursor  >= $local_events[$local_event_idx]-1          and $local_event_idx < @local_events-1)             { $local_event_idx++; }

	## Now we consider our various options for moving the cursor
	my @options = ();
	push @options, 4*480;
	push @options, 1 if ($cursor == $rightTick);
	push @options, $rightTick - $cursor;
	push @options, ($self->{_start_events}[$start_event_idx] - $cursor);
	push @options, ($local_events[$local_event_idx] - $cursor);

	my $proposed_end_meas   = $song->t2m($self->{_end_events}[$end_event_idx]);
	my $proposed_start_meas = $e2spwl->interpolate($proposed_end_meas);
	my $proposed_start_tick = $song->m2t($proposed_start_meas);
	push @options, ($proposed_start_tick - $cursor);

	@options = grep { $_ > 1e-7 } @options;
	my $movement = &__min(@options);

	$cursor += $movement;
    }

    ## Now we have all of these activations, so we need to pick the best
    my %local_scoreboard = ();
    foreach my $act (@acts) {
	my $score = $act->totScore();
	my $length = $act->displayRightTick() - $act->displayLeftTick();
	my $sqlen =  &__max($act->startTick() - $act->displayLeftTick(),0) +
	             &__max($act->displayRightTick()-$act->endTick(),0);
	my $nextsp = $act->nextSPidx();

	if (not defined $local_scoreboard{$nextsp}) {
	    $local_scoreboard{$nextsp}{score}  = $score;
	    $local_scoreboard{$nextsp}{len}    = $length;
	    $local_scoreboard{$nextsp}{sqlen}  = $sqlen;
	    $local_scoreboard{$nextsp}{act}    = $act;
	    next;
	}

	next if $score < $local_scoreboard{$nextsp}{score};


	next if $score == $local_scoreboard{$nextsp}{score} and
	        $sqlen >= $local_scoreboard{$nextsp}{sqlen};

	next if $score  == $local_scoreboard{$nextsp}{score} and
	        $sqlen  == $local_scoreboard{$nextsp}{sqlen} and 
	        $length >= $local_scoreboard{$nextsp}{len};

	$local_scoreboard{$nextsp}{score}  = $score;
	$local_scoreboard{$nextsp}{len}    = $length;
	$local_scoreboard{$nextsp}{sqlen}  = $sqlen;
	$local_scoreboard{$nextsp}{act}    = $act;
    }

    my @out = ();
    foreach my $k (sort {$a <=> $b} keys %local_scoreboard) { push @out, $local_scoreboard{$k}{act}; }
    return @out;
}

sub _gen_sp_pwls {
    my ($self,$idx,$sp,$left,$right) = @_;
    my $s2epwl = new Pwl;
    my $e2spwl = new Pwl;
    my $sppwl  = new Pwl;
    my $xover  = [];
    my $song = $self->song();
    my @pwl_points = $song->get_sptick_pwl_points($idx);
    my $timesigs   = $song->timesigarr();
    my @x1 = map { $_->[0]    } @pwl_points;
    my @x2 = map { $_->tick() } @$timesigs;
    my @x = ($left,$right,@x1,@x2); 
    @x = grep { $_ >= $left and $_ <= $right } @x;

    ## Uniquify the list
    my %x = map { ($_,1) } @x;
    @x = sort {$a <=> $b} (keys %x);

    my $lastxmeas  = 0;
    my $lastx      = 0;
    my $lastsp = $sp;
    my $wpqb = $self->whammy_per_quarter_bar();


    foreach my $x (@x) {
	my $xmeas = $song->t2m($x);
	my $spticks = $song->get_spticks_after_phrase($idx,$x);

	##my $totsp = $sp + $spticks / 480 * 2.0 / 7.5;
	my $totsp = $sp + $spticks / 480 * 2.0 / $wpqb;

	## We have to add an intermediate point if we crossed the 4 meas threshold or the 8 meas threshold
	if ($totsp > 4.0 and $lastsp < 4.0) { 
	    my $intx = $lastxmeas + (4.0-$lastsp) / ($totsp-$lastsp) * ($xmeas-$lastxmeas);
	    $s2epwl->add_point($intx,$intx+4.0);
	    $e2spwl->add_point($intx+4.0,$intx);
	    $sppwl->add_point($intx,4.0);
	    push @$xover, $intx;
	}

	if ($totsp > 8.0 and $lastsp < 8.0) { 
	    my $intx = $lastxmeas + (8.0-$lastsp) / ($totsp-$lastsp) * ($xmeas-$lastxmeas);
	    $s2epwl->add_point($intx,$intx+8.0);
	    $e2spwl->add_point($intx+8.0,$intx);
	    $sppwl->add_point($intx,8.0);
	    push @$xover, $intx;
	}

	$totsp = 8 if $totsp > 8;
	$s2epwl->add_point($xmeas,$xmeas+$totsp);
	$e2spwl->add_point($xmeas+$totsp,$xmeas);
	$sppwl->add_point($xmeas,$totsp);

	##if ($self->game() eq 'gh3') {
	##    if ($totsp > 4.0 and $lastsp < 4.0) {
	##        my $intx = $lastx + (4.0-$lastsp) / ($totsp-$lastsp) * ($x-$lastx);
	##        $s2epwl->add_point($song->t2m($intx),$song->t2m($intx+4.0*4.0*480.0));
	##        $e2spwl->add_point($song->t2m($intx+4.0*4.0*480.0),$song->t2m($intx));
	##        $sppwl->add_point($intx,4.0);
	##        push @$xover, $intx;
	##    }

	##    if ($totsp > 8.0 and $lastsp < 8.0) {
	##        my $intx = $lastx + (8.0-$lastsp) / ($totsp-$lastsp) * ($x-$lastx);
	##        $s2epwl->add_point($song->t2m($intx),$song->t2m($intx+8.0*4.0*480.0));
	##        $e2spwl->add_point($song->t2m($intx+8.0*4.0*480.0),$song->t2m($intx));
	##        $sppwl->add_point($intx,8.0);
	##        push @$xover, $intx;
	##    }

	##    $totsp = 8 if $totsp > 8;
	##    $s2epwl->add_point($xmeas,$song->t2m($x+4.0*480.0*$totsp));
	##    $e2spwl->add_point($song->t2m($x+4.0*480.0*$totsp,$xmeas));
	##    $sppwl->add_point($xmeas,$totsp);
	##}

	##else {

	##    ## We have to add an intermediate point if we crossed the 4 meas threshold or the 8 meas threshold
	##    if ($totsp > 4.0 and $lastsp < 4.0) { 
	##        my $intx = $lastxmeas + (4.0-$lastsp) / ($totsp-$lastsp) * ($xmeas-$lastxmeas);
	##        $s2epwl->add_point($intx,$intx+4.0);
	##        $e2spwl->add_point($intx+4.0,$intx);
	##        $sppwl->add_point($intx,4.0);
	##        push @$xover, $intx;
	##    }

	##    if ($totsp > 8.0 and $lastsp < 8.0) { 
	##        my $intx = $lastxmeas + (8.0-$lastsp) / ($totsp-$lastsp) * ($xmeas-$lastxmeas);
	##        $s2epwl->add_point($intx,$intx+8.0);
	##        $e2spwl->add_point($intx+8.0,$intx);
	##        $sppwl->add_point($intx,8.0);
	##        push @$xover, $intx;
	##    }

	##    $totsp = 8 if $totsp > 8;
	##    $s2epwl->add_point($xmeas,$xmeas+$totsp);
	##    $e2spwl->add_point($xmeas+$totsp,$xmeas);
	##    $sppwl->add_point($xmeas,$totsp);
	##}

	$lastsp = $totsp;
	$lastx = $x;
	$lastxmeas = $xmeas;
    }
    return ($s2epwl,$e2spwl,$sppwl,$xover);
}

sub __min {
    my $min = @_[0];
    foreach my $a (@_) { $min = $a if $a < $min; }
    return $min;
}

sub get_unique_sp_pairs {
    my ($self,$rs) = @_;
    my %a = ();
    my @out;
    foreach my $sol (@$rs) {
	my $csp = $sol->compsp();
	my $osp = $sol->optsp();
	$a{"${csp}_$osp"} = [$csp,$osp];
    }
    foreach my $k (sort keys %a) { push @out, $a{$k}; }
    return @out;
}

sub _filter_current_scoreboard {
    my ($self,$i) = @_;
    my $rsol = $self->{_scoreboard}[$i];

    ## This routine pretty much decimates the scoreboard, but the 
    ## splice solution didn't do a much better job here.
    my %hh = ();
    foreach my $rs (@$rsol) {
	my $score  = $rs->score();
	my $compsp = sprintf "%.7f", $rs->compsp();
	my $optsp  = sprintf "%.7f", $rs->optsp();
	my $key = "${compsp}_$optsp";
	push @{$hh{$key}}, $rs;
    }

    my @out = ();
    my $num_to_save = 5;
    foreach my $k (sort keys %hh) {
	if (scalar(@{$hh{$k}} <= $num_to_save)) { push @out, @{$hh{$k}}; next; }
	@{$hh{$k}} = sort { $b->{score} <=> $a->{score} ||
	                    $a->{pathstr} cmp $b->{pathstr} } @{$hh{$k}};
	for my $i (0 .. $num_to_save-1) { push @out, $hh{$k}[$i]; }
    }

    @{$self->{_scoreboard}[$i]} = @out;
}

sub _summarize_current_scoreboard {
    my ($self,$i) = @_;
    my $rsol = $self->{_scoreboard}[$i];
    my %best = ();
    foreach my $rs (@$rsol) {
	my $score  = $rs->score();
	my $compsp = $rs->compsp();
	my $optsp  = $rs->optsp();
	my $key = "${compsp}_$optsp";
	if (not defined $best{$key} or not defined $best{$key}{$score} or $score > $best{$key}{$score}) {
	    $best{$key}{score}   = $score;
	    $best{$key}{compsp}  = $compsp;
	    $best{$key}{optsp}   = $optsp;
	    $best{$key}{pathstr} = $rs->pathstr();
	    $best{$key}{sol}     = $rs;
	}
	my @keys = sort { $best{$b}{score} <=> $best{$a}{score} } keys %best;
	foreach my $k (@keys) {
	    printf "    Score:%6d  Compsp:%.4f  Optsp:%.4f  Pathstr:\%s\n", $best{$k}{score}, $best{$k}{compsp},
	                                                                    $best{$k}{optsp}, $best{$k}{pathstr};
	}
    }
}

sub _filter_out_compressed_uncompressed_duplicates {
    my ($self,$cc,$uu) = @_;
    my @out = @$cc;
    foreach my $u (@$uu) {
	my $match = 0;
	foreach my $c (@$cc) {
	    next if $u->nextSPidx() ne $c->nextSPidx();
	    next if $u->noteScore() != $c->noteScore();
	    next if $u->sustScore() != $c->sustScore();
	    $match = 1; last;
	}
	if ($match == 0) { push @out, $u; }
    }
    return @out;
}


sub optimize_me {
    my $self = shift;
    my $song = $self->song();
    my $spa = $song->sparr();
    my $debug = $self->debug();
    $self->{_scoreboard} = [];
    my $scoreboard = $self->{_scoreboard};
    my $wpqb = $self->whammy_per_quarter_bar();

    my $start_solution = new Solution;
    $start_solution->song($song);
    push @{$scoreboard->[0]}, $start_solution;


    for my $i (0 .. @$spa-1) {

	print("DEBUG: Examining SP phrase $i...\n") if $debug;
	$self->_filter_current_scoreboard($i);
	$self->_summarize_current_scoreboard($i) if $debug;

	foreach my $ss (@{$scoreboard->[$i]}) {
	    my $savesol = $self->save_sol($ss,$i);
	    push @{$scoreboard->[$i+1]}, $savesol;
	}

	my %locacts = ();
	my @sppairs = $self->get_unique_sp_pairs($scoreboard->[$i]);
	foreach my $pair (@sppairs) {
	    my ($c,$o) = @$pair;
	    my $addc = 2.0;
	    ##my $addo = $song->calc_phrase_sp_ticks_sans_last($i) / 480.0 * 2.0 / 7.5;
	    my $addo = $song->calc_phrase_sp_ticks_sans_last($i) / 480.0 * 2.0 / $wpqb;
	    my $newc = $c+$addc;          $newc = 8.0 if $newc > 8.0;
	    my $newt = $c+$addc+$o+$addo; $newt = 8.0 if $newt > 8.0;
	    my $newo = $newt-$newc;
	    printf("DEBUG:    trying (c,o) = (%.3f,%.3f) + (%.3f,%.3f)...\n", $c, $o, $addc, $addo) if $debug;
	    my @a = $self->get_compressed_activation($i,$newc,$newo);
	    my @b = $self->get_uncompressed_activation($i,$newc,$newo);
	    my @out = $self->_filter_out_compressed_uncompressed_duplicates(\@a,\@b);
	    printf("DEBUG:    got \%d compressed, \%d uncompressed\n", scalar(@a), scalar(@b)) if $debug;
	    foreach my $act (@out) { push @{$locacts{$c}{$o}}, $act; }
	}

	foreach my $ss (@{$scoreboard->[$i]}) {
	    my $c = $ss->compsp();
	    my $o = $ss->optsp();
	    foreach my $act (@{$locacts{$c}{$o}}) {
		my ($newsol,$newidx) = $self->add_act_to_sol($ss,$act);
		push @{$scoreboard->[$newidx]}, $newsol;
	    }
	}
    }

    my $last = @$spa;
    @{$scoreboard->[$last]} = sort { ($b->score() <=> $a->score()) || ($a->pathstr() cmp $b->pathstr()) } @{$scoreboard->[$last]};
    foreach my $ss  (@{$scoreboard->[$last]}) { $ss->genpathstr_final(); }

    return @{$scoreboard->[$last]};
}

sub save_sol {
    my ($self,$oldsol,$i) = @_;
    my $wpqb = $self->whammy_per_quarter_bar();
    my $newsol = new Solution;
    $newsol->score($oldsol->score());
    $newsol->song($oldsol->song());
    my $song = $self->song();
    ##my $newo = $song->calc_phrase_sp_ticks($i) / 480.0 * 2.0 / 7.5;
    my $newo = $song->calc_phrase_sp_ticks($i) / 480.0 * 2.0 / $wpqb;
    my $newc = 2.0;
    my $na = $song->notearr();
    my $spa = $song->sparr();
    my ($si,$ei) = @{$spa->[$i]};
    my ($oldc,$oldo) = ($oldsol->compsp(),$oldsol->optsp());
    my $c = $newc+$oldc;             $c = 8 if $c > 8;
    my $t = $newc+$oldc+$newo+$oldo; $t = 8 if $t > 8;
    my $o = $t - $c;
    $newsol->compsp($c);
    $newsol->optsp($o);
    my $oldact = $oldsol->activations();
    $newsol->activations([@$oldact]);
    $newsol->genpathstr();
    return $newsol;

}

sub add_act_to_sol {
    my ($self,$oldsol,$act) = @_;
    my $next = $act->nextSPidx();
    my $newsol = new Solution;
    $newsol->song($oldsol->song());
    my $song = $self->song();
    my $score = $oldsol->score() + $act->totScore();
    $newsol->score($score);
    $newsol->compsp(0);
    $newsol->optsp(0);
    my $oldact = $oldsol->activations();
    $newsol->activations([@$oldact,$act]);
    $newsol->genpathstr();
    return($newsol,$next);
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

1;
