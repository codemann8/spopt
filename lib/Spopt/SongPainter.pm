package SongPainter;

use strict;

our $PIXEL_WIDTH = 1024;

our $BEATS_PER_ROW = 24;
our $LEFT_MARGIN_PIXELS = 16;
our $PIXELS_PER_BEAT = 40;
our $HEADER_PIXELS = 90;
our $FOOTER_PIXELS = 40;
our $PIXELS_PER_SINGLE_ROW = 114;

our $SINGLE_STAFF_LINE_1 = 24 + 0;
our $SINGLE_STAFF_LINE_2 = 24 + 1*12;
our $SINGLE_STAFF_LINE_3 = 24 + 2*12;
our $SINGLE_STAFF_LINE_4 = 24 + 3*12;
our $SINGLE_STAFF_LINE_5 = 24 + 4*12;

sub new    { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop  { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }

sub song      { my $self = shift; return $self->_prop("song",@_);  }
sub filename  { my $self = shift; return $self->_prop("filename",@_);  }
sub greenbot  { my $self = shift; return $self->_prop("greenbot",@_);  }
sub debug     { my $self = shift; return $self->_prop("debug",@_);  }
sub sol       { my $self = shift; return $self->_prop("sol",@_);  }
sub title     { my $self = shift; return $self->_prop("title",@_);  }
sub subtitle  { my $self = shift; return $self->_prop("subtitle",@_);  }
sub outline_only  { my $self = shift; return $self->_prop("outline_only",@_);  }

sub whammy_per_quarter_bar  { my $self = shift; return $self->_prop("whammy_per_quarter_bar",@_);  }


sub clear_unrestricted    { my $self = shift; $self->{unrestricted} = []; }
sub clear_partial         { my $self = shift; $self->{partial}   = []; }
sub clear_trailing        { my $self = shift; $self->{trailing}   = []; }
sub clear_spsqueeze       { my $self = shift; $self->{spsqueeze}   = []; }
sub clear_nwunrestricted  { my $self = shift; $self->{nwunrestricted} = []; }
sub clear_nwpartial       { my $self = shift; $self->{nwpartial}   = []; }
sub clear_nwtrailing      { my $self = shift; $self->{nwtrailing}   = []; }
sub clear_activation      { my $self = shift; $self->{activation}   = []; }
sub clear_squeeze         { my $self = shift; $self->{squeeze}   = []; }

sub add_unrestricted    { my ($self,$start,$stop) = @_; push @{$self->{unrestricted}},   [$start,$stop]; }
sub add_partial         { my ($self,$start,$stop) = @_; push @{$self->{partial}},        [$start,$stop]; }
sub add_trailing        { my ($self,$start,$stop) = @_; push @{$self->{trailing}},       [$start,$stop]; }
sub add_spsqueeze       { my ($self,$start,$stop) = @_; push @{$self->{spsqueeze}},      [$start,$stop]; }
sub add_nwunrestricted  { my ($self,$start,$stop) = @_; push @{$self->{nwunrestricted}}, [$start,$stop]; }
sub add_nwpartial       { my ($self,$start,$stop) = @_; push @{$self->{nwpartial}},      [$start,$stop]; }
sub add_nwtrailing      { my ($self,$start,$stop) = @_; push @{$self->{nwtrailing}},     [$start,$stop]; }
sub add_activation      { my ($self,$start,$stop) = @_; push @{$self->{activation}},     [$start,$stop]; }
sub add_squeeze         { my ($self,$start,$stop) = @_; push @{$self->{squeeze}},        [$start,$stop]; }

sub _init {
    my $self = shift;
    $self->song("");
    $self->filename("");
    $self->title("");
    $self->subtitle("");
    $self->sol("NONE");
    $self->clear_unrestricted();
    $self->clear_partial();
    $self->clear_trailing();
    $self->clear_spsqueeze();
    $self->clear_nwunrestricted();
    $self->clear_nwpartial();
    $self->clear_nwtrailing();
    $self->clear_activation();
    $self->clear_squeeze();
    $self->outline_only(0);
    $self->greenbot(1);
    $self->whammy_per_quarter_bar(7.5);
    $self->debug(0);
}


sub paintsol {
    my ($self,$sol) = @_;
    $self->sol($sol);
    my $sp = $self;
    my $song = $self->song();
    my $na = $song->notearr();
    my $spa = $song->sparr();
    my $ract = $sol->activations();
    my $maxspidx = scalar(@$spa)-1;
    my $spcursor = 0;

    ## make the filename the title if it isn't set yet
    unless ($self->title()) {
	my $mf = $song->midifile();
	my $filename = $mf->file();
	$filename =~ s/.*\///;
	if ($filename) { $self->title($filename); }
    }

    ## Put the difficulty, the estimated score, and the pathstr for the solution in the subtitle
    my $diff = $song->diff();
    my $pathstr = $sol->pathstr();
    my $totscore = $sol->totscore();
    $self->subtitle("Diff:$diff     EstScore:$totscore     Path:$pathstr") unless $self->subtitle();

    ## Add the star phrases
    foreach my $ra (@$ract) { $spcursor = $self->_highlight_activation($ra,$spcursor); }

    ## Add the activations
    foreach my $ra (@$ract) {
	my $start = $ra->startTick();
	my $end   = $ra->endTick();
	my $sqstart = $ra->displayLeftTick();
	my $sqend   = $ra->displayRightTick();
	my $startmeas = $song->t2m($start);
	my $endmeas   = $song->t2m($end);
	my $sqstartmeas = $song->t2m($sqstart);
	my $sqendmeas   = $song->t2m($sqend);
	$sp->add_activation($startmeas,$endmeas);
	if ($sqstart < $start) { $sp->add_squeeze($sqstartmeas,$startmeas); }
	if ($sqend > $end)     { $sp->add_squeeze($endmeas,$sqendmeas);     }
    }

    $sp->paintsong();
}

sub _highlight_activation {
    my ($self,$ract,$spcursor) = @_;
    my $song = $self->song();
    my $spa = $song->sparr();
    my $na  = $song->notearr();
    my $wpqb = $self->whammy_per_quarter_bar();

    my $ract_starttick = $ract->startTick();
    my $ract_endtick   = $ract->endTick();

    my $actstartmeas = $song->t2m($ract->startTick());
    my $actendmeas   = $song->t2m($ract->endTick());

    my $lastspidx = $ract->lastSPidx();
    my $nextspidx = $ract->nextSPidx();
    my $optsp_used = $ract->optionalSPUsed();
    my $redmeas = 0;

    if ($ract->compressed_flag() == 0) { $redmeas = 1e10; }
    else {
        $redmeas = $na->[$spa->[$spcursor][0]]->leftStartMeas();
        ## Find the red measure breakpoint
        for my $i ( $spcursor .. $lastspidx ) {
            my $rsp = $spa->[$i];
            my ($s,$e) = @$rsp;
            for my $j ($s .. $e) {
                last if $optsp_used <= 0;
                next unless $na->[$j]->sustain();
                my $startsptick = $na->[$j]->effectiveSPStartTick();
                my $endsptick    = $na->[$j]->SpEndTick();
                my $additional_sptick = ($endsptick-$startsptick);
		##my $additional_spmeas = $additional_sptick / 480.0 * 2.0 / 7.5;
                my $additional_spmeas = $additional_sptick / 480.0 * 2.0 / $wpqb;
                if ($additional_spmeas < $optsp_used-1e-7) { $optsp_used -= $additional_spmeas; }
                else {
            	    ## We've found the breakpoint, we just need to calculate it.
		    ##my $optsp_ticks = 7.5 / 2.0 * 480 * $optsp_used;
            	    my $optsp_ticks = $wpqb / 2.0 * 480 * $optsp_used;
            	    my $breakpoint_tick = $startsptick + $optsp_ticks;
            	    $redmeas = $song->t2m($breakpoint_tick);
            	    $optsp_used = 0;
                }
            }

            if ($optsp_used > 0) { $redmeas =  $na->[$e]->endMeas(); }
        }
    }

    for my $i ( $spcursor .. $lastspidx ) {
        my $rsp = $spa->[$i];
        my ($s,$e) = @$rsp;
        my $start    = $na->[$s]->startTick();
        my $firstend = $na->[$e]->startTick();
        my $end      = $na->[$e]->endTick();

	## Hack to get the highlights on the single-tick wide sections
	if ($start == $firstend and $firstend == $end) { $start -= 60; $firstend += 60; $end += 60; }

        my $startmeas      = $song->t2m($start);
        my $firstendmeas   = $song->t2m($firstend);
        my $endmeas        = &__min($song->t2m($end),$actstartmeas);

	if     ($startmeas >= $redmeas)    { $self->add_nwunrestricted($startmeas,$firstendmeas); }
	elsif  ($firstendmeas <= $redmeas) { $self->add_unrestricted($startmeas,$firstendmeas); }
	else  {
	    $self->add_unrestricted($startmeas,$redmeas); 
	    $self->add_nwunrestricted($redmeas,$firstendmeas); 
	}

	if ($endmeas > $firstendmeas) {
	    if     ($firstendmeas >= $redmeas) { $self->add_nwtrailing($firstendmeas,$endmeas); }
	    elsif  ($endmeas      <= $redmeas) { $self->add_trailing($firstendmeas,$endmeas); }
	    else  {
	        $self->add_trailing($firstendmeas,$redmeas); 
	        $self->add_nwtrailing($redmeas,$endmeas); 
	    }
	}

	for my $j ($s .. $e) {
	    next unless $na->[$j]->squeezedSpTick() > 20;
	    next if $na->[$j]->startTick() > $ract_starttick;
	    my $sm = $song->t2m($na->[$j]->effectiveSPStartTick());
	    my $em = $song->t2m($na->[$j]->startTick());
	    $self->add_spsqueeze($sm,$em);
	}


    }

    if ($nextspidx-$lastspidx > 1) {
        for my $i ($lastspidx + 1 .. $nextspidx - 1) {
    	    my $rsp = $spa->[$i];
    	    my ($s,$e) = @$rsp;
    	    my $start    = $na->[$s]->startTick();
    	    my $end      = $na->[$e]->endTick();

	    ## Hack to get the highlights on the single-tick wide sections
	    if ($start == $end) { $start -= 60; $end += 60; }

    	    my $startmeas      = $song->t2m($start);
    	    my $endmeas        = $song->t2m($end);
	    next if $startmeas >= $actstartmeas;
	    $endmeas = &__min($endmeas,$actstartmeas);
	    if     ($startmeas >= $redmeas)    { $self->add_nwpartial($startmeas,$endmeas); }
	    elsif  ($endmeas <= $redmeas) { $self->add_partial($startmeas,$endmeas); }
	    else  {
	        $self->add_partial($startmeas,$redmeas); 
	        $self->add_nwpartial($redmeas,$endmeas); 
	    }

	    for my $j ($s .. $e) {
	        next unless $na->[$j]->squeezedSpTick() > 20;
	        next if $na->[$j]->startTick() > $ract_starttick;
	        my $sm = $song->t2m($na->[$j]->effectiveSPStartTick());
	        my $em = $song->t2m($na->[$j]->startTick());
	        $self->add_spsqueeze($sm,$em);
	    }
        }
    }
    return $nextspidx;
}

sub paintsong {
    my $self = shift;
    $self->_calc_last_measure();
    $self->_calc_stats_per_measure();
    $self->_map_measures_to_coords();
    $self->_map_notes_to_measures();

    $self->{_im_song} = $self->_initialize_im();
    $self->{_im_hi}   = $self->_initialize_im();
    $self->{_im_med}  = $self->_initialize_im();
    $self->{_im_lo}  = $self->_initialize_im();

    $self->{_im_hi}->Transparent(color=>'white');
    $self->{_im_med}->Transparent(color=>'white');
    $self->{_im_lo}->Transparent(color=>'white');

    $self->_print_measures();
    $self->_print_tempos();
    $self->_printTitles();
    $self->_paintSectionLabels();
    $self->_merge_images();
    $self->_save_file();
}

sub _paintSectionLabels {
    my ($self) = shift;
    my $song = $self->song();
    my $ra = $song->sectionnames();
    foreach my $rra (@$ra) {
	my ($meas,$txt) = @$rra;
	$meas = int ($meas + 0.5); ## round to the nearest measure to be sure to have room to type the text
        my $basex = $self->{_measureCoords}{$meas}{x};
        my $basey = $self->{_measureCoords}{$meas}{y};
        $self->_drawText("_im_song", "Black","Helvetica",10,"$txt",$basex+20,$basey+$SINGLE_STAFF_LINE_1-5);
    }
}

sub _merge_images {
    my $self = shift;
    my $x;
    my $debug = $self->debug();

    if ($debug) {
        $self->{_im_hi}->Write("debug1.png");
        $self->{_im_med}->Write("debug2.png");
        $self->{_im_lo}->Write("debug3.png");
    }

    $x = $self->{_im_lo}->Composite(image => $self->{_im_med},   compose=>'Over', x=>0, y=>0);
    warn $x if $x;
    $x = $self->{_im_lo}->Composite(image => $self->{_im_hi},    compose=>'Over', x=>0, y=>0);
    warn $x if $x;

    if ($self->outline_only()) {
        $x = $self->{_im_song}->Composite(image => $self->{_im_lo},  compose=>'Dissolve', opacity=>32000, x=>0, y=>0);
        warn $x if $x;
    }
    
    else {
        $x = $self->{_im_song}->Composite(image => $self->{_im_lo},  compose=>'Dissolve', opacity=>20000, x=>0, y=>0);
        warn $x if $x;
    }
}

sub _printTitles() {
    my $self = shift;
    my $title = $self->title();
    my $subtitle = $self->subtitle();
    # hack:
    # added to distinguish the chart when generating coop, altp1 and altp2 blanks - tma
    # $subtitle .= ' main';
    $self->_drawCenteredText("_im_song","black","Times",50,$title,512,40) if $title;
    $self->_drawCenteredText("_im_song","black","Times",30,$subtitle,512,80) if $subtitle;
}

sub _calc_overlap {
    my ($self,$a1,$a2,$b1,$b2) = @_;
    return 0 if $b1 >= $a2;
    return 0 if $a1 >= $b2;
    return 0 if $a2-$a1 <= 0;
    return 0 if $b2-$b1 <= 0;
    my $left = $a1 > $b1 ? $a1 : $b1;
    my $right = $a2 < $b2 ? $a2 : $b2;
    return $right - $left;
}

sub _calc_last_measure {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();
    my $last_measure = int($na->[-1]->endMeas() + 1e-7);
    $self->{_lastMeasure} = $last_measure;
}

sub _calc_stats_per_measure {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();
    my $lm = $self->{_lastMeasure};
    for my $i ( 1 .. $lm) {
	$self->{_basemeasscore}[$i] = 0;
	$self->{_multmeasscore}[$i] = 0;
	$self->{_spmeas}[$i] = 0;
    }

    $self->_calc_notescore_stat_per_meas();
    $self->_calc_sustscore_stat_per_meas();
    if ($self->sol() ne "NONE") { $self->_calc_sp_multscore_stat_per_meas(); }
    $self->_make_multmeasscore_cumulative();
    $self->_calc_sp_stat_per_meas();
}

sub _calc_sp_multscore_stat_per_meas {
    my $self = shift;
    my $sol = $self->sol();
    my $ract = $sol->activations();
    foreach my $act (@$ract) { $self->_dist_sp_activation($act); }
}

sub _make_multmeasscore_cumulative() {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();
    my $lm = $self->{_lastMeasure};
    next if $lm == 1;
    for my $i ( 2 .. $lm) { $self->{_multmeasscore}[$i] += $self->{_multmeasscore}[$i-1]; }
}

sub _calc_notescore_stat_per_meas {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();
    foreach my $n (@$na) {
	my $meas = int ($n->startMeas()+1e-7); 
	$self->{_basemeasscore}[$meas] += $n->baseNoteScore();
	$self->{_multmeasscore}[$meas] += $n->multNoteScore();
    }
}

sub _calc_sustscore_stat_per_meas {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();

    foreach my $n (@$na) {
	next unless $n->sustain();
	my $mult          = $n->multsust();
	my $chordsize     = $n->chordsize();
	my $basesustscore = $n->baseSustScore();
	my $multsustscore = $n->multSustScore();
	my $startBeat     = $n->startBeat();
	my $endBeat       = $n->endBeat();
	$self->_dist_basesust_score($basesustscore,$chordsize,$startBeat,$endBeat);
	$self->_dist_multsust_score($multsustscore,$chordsize,$mult,$startBeat,$endBeat);
    }
}

sub _dist_sp_activation {
    my ($self,$act) = @_;
    my $song = $self->song();
    my $na = $song->notearr();
    my $leftlimit =      $act->leftNoteIdxLimit();
    my $left_note_idx =  $act->startNoteIdx();
    my $right_note_idx = $act->endNoteIdx();
    my $startTick =      $act->startTick();
    my $endTick   =      $act->endTick();

    ## Do the notes first, then do the sustains 2nd
    my ($ns1,$ss1,$ts1) = $na->[$left_note_idx]->score_note($startTick,$endTick);
    my ($ns2,$ss2,$ts2) = $na->[$right_note_idx]->score_note($startTick,$endTick);

    my $ln = ($ns1 > 0 and $left_note_idx >= $leftlimit) ? $left_note_idx : $left_note_idx+1;
    if ($ln < $right_note_idx) {
	for my $i ($ln .. $right_note_idx) {
	    my $n = $na->[$i];
	    my $startMeas  = $n->startMeas();
	    my $meas = int($startMeas+1e-7);
	    $self->{_multmeasscore}[$meas] += $n->multNoteScore();
	}
    }

    ## Now we do the sustains for the first and last note
    my @endpoints = ([$na->[$left_note_idx],$ss1]);
    if ($left_note_idx < $right_note_idx) { push @endpoints, [$na->[$right_note_idx],$ss2]; }
    foreach my $ra (@endpoints) {
	my ($n,$score) = @$ra;
	next unless $score > 0;
	my $ltick = &__max($startTick,$n->startTick());
	my $rtick = &__min($endTick,$n->endTick());
	my $leftbeat  = $song->t2b($ltick);
	my $rightbeat = $song->t2b($rtick);
	my $mult = $n->multsust();
	my $chordsize = $n->chordsize();
	$self->_dist_multsust_score($score,$chordsize,$mult,$leftbeat,$rightbeat);
    }

    ## Now we do the sustains for all the notes in the middle
    if ($right_note_idx - $left_note_idx > 1) {
	for my $i ( $left_note_idx+1 .. $right_note_idx-1) {
	    my $n = $na->[$i];
	    if ($n->sustain()) {
	        my $mult          = $n->multsust();
	        my $chordsize     = $n->chordsize();
	        my $multsustscore = $n->multSustScore();
	        my $startBeat     = $n->startBeat();
	        my $endBeat       = $n->endBeat();
	        $self->_dist_multsust_score($multsustscore,$chordsize,$mult,$startBeat,$endBeat);
	    }
	}
    }
}

sub _dist_basesust_score {
    my ($self,$points,$chordsize,$startBeat,$endBeat) = @_;
    my $song = $self->song();
    my $startMeas = $song->b2m($startBeat);
    my $endMeas   = $song->b2m($endBeat);
    my $leftmeas      = int ($startMeas+1e-7);
    my $rightmeas     = int ($endMeas+1e-7);
    my $numbeats = $endBeat - $startBeat;
    return if $numbeats <= 0;
    my $running_points = $points;
    
    if ($rightmeas > $leftmeas) {
        for my $i ($leftmeas .. $rightmeas-1) {
            my $leftbeat  = $song->m2b($i);
            my $rightbeat = $song->m2b($i+1);
            my $overlap = $self->_calc_overlap($startBeat,$endBeat,$leftbeat,$rightbeat);
	    my $bs = $chordsize * int ($points * $overlap/$numbeats/$chordsize);
	    $bs = $running_points if $bs > $running_points;
	    $self->{_basemeasscore}[$i] += $bs;
	    $running_points -= $bs;
	}
    }
    $self->{_basemeasscore}[$rightmeas] += $running_points;
}

sub _dist_multsust_score {
    my ($self,$points,$chordsize,$mult,$startBeat,$endBeat) = @_;
    my $song = $self->song();
    my $startMeas = $song->b2m($startBeat);
    my $endMeas   = $song->b2m($endBeat);
    my $leftmeas      = int ($startMeas+1e-7);
    my $rightmeas     = int ($endMeas+1e-7);
    my $numbeats = $endBeat - $startBeat;
    return if $numbeats <= 0;
    my $running_points = $points;
    
    if ($rightmeas > $leftmeas) {
        for my $i ($leftmeas .. $rightmeas-1) {
            my $leftbeat  = $song->m2b($i);
            my $rightbeat = $song->m2b($i+1);
            my $overlap = $self->_calc_overlap($startBeat,$endBeat,$leftbeat,$rightbeat);
	    my $ms = $chordsize * $mult * int ($points * $overlap/$numbeats/$chordsize/$mult);
	    $ms = $running_points if $ms > $running_points;
	    $self->{_multmeasscore}[$i] += $ms;
	    $running_points -= $ms;
	}
    }
    $self->{_multmeasscore}[$rightmeas] += $running_points;
}

sub _calc_sp_stat_per_meas {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();

    foreach my $n (@$na) {
	next unless $n->sustain();
	next unless $n->star();
	my $totsp         = $n->SpEndBeat() - $n->effectiveSPStartBeat();
	my $startMeas     = $n->effectiveSPStartMeas();
	my $endMeas       = $n->SpEndMeas();
	my $startBeat     = $n->effectiveSPStartBeat();
	my $endBeat       = $n->SpEndBeat();

	my $leftmeas      = int ($startMeas+1e-7);
	my $rightmeas     = int ($endMeas+1-1e-7);

	if ($rightmeas > $leftmeas) {
	    for my $i ($leftmeas .. $rightmeas-1) {
	        my $leftbeat  = $song->m2b($i);
	        my $rightbeat = $song->m2b($i+1);
	        my $overlap = $self->_calc_overlap($startBeat,$endBeat,$leftbeat,$rightbeat);
		$overlap = $totsp if $overlap > $totsp; $overlap = 0 if $overlap < 0;
	        $self->{_spmeas}[$i] += $overlap;
		$totsp -= $overlap;
	    }
	}
	$self->{_spmeas}[$rightmeas] += $totsp;
    }
}

sub _initialize_im {
    my ($self) = @_;
    my $x = $PIXEL_WIDTH;
    my $y = $self->{_numrows} * $PIXELS_PER_SINGLE_ROW + $HEADER_PIXELS + $FOOTER_PIXELS;
    my $im = Image::Magick->new(size=>"${x}x$y");
    $im->Read("xc:white");
    return $im;
    ##my $pointstr = sprintf "\%d,\%d \%d,\%d", 0,0,$x-1,$y-1;
    ##$im->Draw("primitive"   => "rectangle",
    ##"points"      => $pointstr,
    ##"stroke"      => "white",
    ##"fill"        => "white",
    ##"strokewidth" => 1);
}

sub _save_file {
    my ($self) = @_;
    my $im = $self->{_im_song};
    my $filename = $self->filename();
    ##my $x = $im->Write($self->{filename});
    my $x = $im->Write($filename);
    warn "$x" if "$x";
}

sub _map_measures_to_coords {
    my $self = shift;
    my $song = $self->song();
    $self->{_measureCoords} = {};
    my $last_measure = $self->{_lastMeasure};
    my ($row,$beats) = (0,0);
    for my $i ( 1 .. $last_measure ) { 
	my $meas_beats = $song->bpm($i);
	if (($beats + $meas_beats) > $BEATS_PER_ROW + 1e-7) { $row++; $beats = 0; }
	$self->{_measureCoords}{$i}{x}   = $LEFT_MARGIN_PIXELS + $beats * $PIXELS_PER_BEAT;
	$self->{_measureCoords}{$i}{y}   = $HEADER_PIXELS + $row * $PIXELS_PER_SINGLE_ROW;
	$self->{_measureCoords}{$i}{row} = $row;
	$beats += $meas_beats;
    }

    $self->{_numrows} = $row+1;
}

sub _map_notes_to_measures {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();
    $self->{_measNotes} = {};
    foreach my $n (@$na) {
	my $ss = int($n->startMeas()+1e-7);
	my $ee = int($n->endMeas()+1e-7);
	for my $i ($ss .. $ee) { push @{$self->{_measNotes}{$i}}, $n; }
    }
}

sub _print_measures {
    my $self = shift;
    my $song = $self->song();
    my $last_measure = $self->{_lastMeasure};
    for my $i ( 1 .. $last_measure ) {
	for my $ra ( ["unrestricted",   "_im_hi",          "#009800"],
	             ["trailing",       "_im_lo",          "#009800"],
	             ["partial",        "_im_lo",          "#009800"],
	             ["spsqueeze",      "_im_hi",          "#804000"],
	             ["nwunrestricted", "_im_hi",          "yellow2"],
	             ["nwtrailing",     "_im_lo",          "yellow2"],
	             ["nwpartial",      "_im_lo",          "yellow2"],
	             ["activation",     "_im_med",         "RoyalBlue"],
	             ["squeeze",        "_im_med",         "Purple"] ) {
	    $self->_highlight_regions($i,@$ra);
	}
    }

    for my $i ( 1 .. $last_measure ) { $self->_drawMeasureGrid($i);     }
    for my $i ( 1 .. $last_measure ) { $self->_drawTimeSignature($i);   }
    for my $i ( 1 .. $last_measure ) { $self->_drawMeasureSustains($i); }
    for my $i ( 1 .. $last_measure ) { $self->_drawMeasureNotes($i);    }
    for my $i ( 1 .. $last_measure ) { $self->_paintMeasureScores($i);    }
}

sub _print_tempos {
    my $self = shift;
    my $song = $self->song();
    my $tarr = $song->tempoarr();

    ## Do a quick filter of all of the tempos after the end of the last note
    my $na = $song->notearr();
    my $numnotes = scalar(@$na);
    my $lasttick = $na->[$numnotes-1]->endTick();
    @$tarr = grep { $_->tick() <= $lasttick }  @$tarr;

    ## Get all the tempos per measure
    $self->_filter_tempos($tarr);
    foreach my $tt (sort @$tarr) {
	my $tick = $tt->tick();
	my $tempo = $tt->tempo();
	$tempo = int (60 * 1e6 / $tempo + 0.5); ## convert from us/qn to qn/min
	my $meas = int($song->t2m($tick)+1e-7);
	my $offset = $PIXELS_PER_BEAT * ($song->t2b($tick) - $song->m2b($meas));
        my $basex = $self->{_measureCoords}{$meas}{x};
        my $basey = $self->{_measureCoords}{$meas}{y};
        my $staff1 = $basey + $SINGLE_STAFF_LINE_1;
	$self->_draw_tempo($tempo,$basex+$offset,$staff1-20);
        #print '===' . "\n"; ## DEBUG
        #print '$meas='.$meas."\n"; ## DEBUG
        #print '$SINGLE_STAFF_LINE_1=' . $SINGLE_STAFF_LINE_1 ."\n"; ## DEBUG
        #print '$basex=' . $basex ."\n"; ## DEBUG
        #print '$basey=' . $basey ."\n"; ## DEBUG
        #print '$tempo=' . $tempo ."\n"; ##DEBUG
        #print '$offset=' . $offset ."\n"; ##DEBUG
        #print '$staff1=' . $staff1 ."\n"; ## DEBUG
    }
}

sub _filter_tempos() {
    my ($self,$tarr) = @_;

    my @final = ();
    my %tset = ();
    my %delta_map = ();

    return if @$tarr == 0;
    for my $i ( 0 .. scalar(@$tarr)-1 ) {
	if ($i == 0) { $delta_map{$i} = $tarr->[$i]->tempo(); }
	else         { $delta_map{$i} = abs($tarr->[$i]->tempo() - $tarr->[$i-1]->tempo()); }
	$tset{$i} = 1;
    }

    my @biggest_deltas = sort { $delta_map{$b} <=> $delta_map{$a} } (0 .. scalar(@$tarr)-1);
    foreach my $i (@biggest_deltas) {
	next unless $tset{$i};
	$tset{$i} = 0;
	push @final, $tarr->[$i];
	for (my $j = $i+1; $j < scalar(@$tarr); $j++) {
	    last if $tarr->[$j]->tick() - $tarr->[$i]->tick() >= 2*480;
	    $tset{$j} = 0;
	}
	for (my $j = $i-1; $j >= 0; $j--) {
	    last if $tarr->[$i]->tick() - $tarr->[$j]->tick() >= 2*480;
	    $tset{$j} = 0;
	}
    }

    @$tarr = @final;
}

sub _highlight_regions { 
    my ($self,$i,$name,$imtag,$color) = @_;
    my $song = $self->song();
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $bpm = $song->bpm($i);
    my $right = int($basex + $PIXELS_PER_BEAT * $bpm + 1e-7);
    my $staff1 = $basey + $SINGLE_STAFF_LINE_1;
    my $staff2 = $basey + $SINGLE_STAFF_LINE_2;
    my $staff3 = $basey + $SINGLE_STAFF_LINE_3;
    my $staff4 = $basey + $SINGLE_STAFF_LINE_4;
    my $staff5 = $basey + $SINGLE_STAFF_LINE_5;

    foreach my $ra (@{$self->{$name}}) {
	my ($s1,$s2) = @$ra;

	if ($self->outline_only()) {
	    if ($s1 >= $i and $s1 < $i+1) {
		my $lr = $basex + int ( 1.0 * ($right-$basex) * ($s1 - $i) );
		$self->_drawLine($imtag,$color,3,$lr,  $staff1-15,$lr,$staff5+3);
		##$self->_drawLine($imtag,$color,1,$lr,  $staff1-3,$lr,$staff5+3);
	    }

	    if ($s2 >= $i and $s2 < $i+1) {
		my $rr = $basex + int ( 1.0 * ($right-$basex) * ($s2 - $i) );
		$self->_drawLine($imtag,$color,3,$rr,$staff1-15,$rr,$staff5+3);
		##$self->_drawLine($imtag,$color,1,$rr,$staff1-3,$rr,$staff5+3);
	    }

	    if (($s1 < $i+1) and ($s2 > $i)) {
		my $locleft  = $s1 < $i ? $i : $s1;
		my $locright = $s2 > $i+1 ? $i+1 : $s2;
		my $lr = $basex + int ( 1.0 * ($right-$basex) * ($locleft - $i) );
		my $rr = $basex + int ( 1.0 * ($right-$basex) * ($locright - $i) );
		$self->_drawLine($imtag,$color,3,$lr,$staff1-14,$rr,$staff1-14);
                $self->_drawLine($imtag,$color,3,$lr,$staff5+3,$rr,$staff5+3);
		##$self->_drawLine($imtag,$color,1,$lr,$staff1-3,$rr,$staff1-3);
                ##$self->_drawLine($imtag,$color,1,$lr,$staff5+3,$rr,$staff5+3);
	    }
	}

	else {

	    if ($s1 >= $i and $s1 <= $i+1 and $s2 >= $i and $s2 <= $i+1 and $s1 < $s2) {
	        my $lr = $basex + int ( 1.0 * ($right-$basex) * ($s1 - $i) );
	        my $rr = $basex + int ( 1.0 * ($right-$basex) * ($s2 - $i) );
                $self->_drawRect($imtag,$color,$lr,$staff1-5,$rr,$staff5+5);
	    }

	    elsif ($s1 <= $i and $s2 > $i and $s2 < $i+1) {
	        my $rr = $basex + int ( 1.0 * ($right-$basex) * ($s2 - $i) );
                $self->_drawRect($imtag,$color,$basex,$staff1-5,$rr,$staff5+5);
	    }

	    elsif ($s1 > $i and $s1 < $i+1 and $s2 >= $i+1) {
	        my $lr = $basex + int ( 1.0 * ($right-$basex) * ($s1 - $i) );
                $self->_drawRect($imtag,$color,$lr,$staff1-5,$right,$staff5+5);
	    }

	    elsif ($s1 <= $i and $s2 >= $i+1) {
                $self->_drawRect($imtag,$color,$basex,$staff1-5,$right,$staff5+5);
	    }
	}
    }
}

sub _drawTimeSignature {
    my ($self,$i) = @_;
    my $song = $self->song();
    if ($i == 0 or $i == 1 or $song->bpm($i) != $song->bpm($i-1)) {
        my $basex = $self->{_measureCoords}{$i}{x};
        my $basey = $self->{_measureCoords}{$i}{y};
        my $staff3 = $basey + $SINGLE_STAFF_LINE_3;
        my $staff5 = $basey + $SINGLE_STAFF_LINE_5;
	my $bpm = $song->bpm($i);
        $self->_drawText("_im_song","gray80","Times",32,"$bpm",$basex+3,$staff3);
        $self->_drawText("_im_song","gray80","Times",32,"4"   ,$basex+3,$staff5);
    }
}

sub _draw_tempo {
    my ($self,$tempo,$x,$y) = @_;
    $self->_drawEllipse("_im_song", "gray65",$x,$y,3,2,-37);
    $self->_drawLine(   "_im_song", "gray65",1,$x+3,$y,$x+3,$y-9); 
    $self->_drawText(   "_im_song", "gray65","Helvetica",10,"=$tempo",$x+6,$y+3);
}

sub _drawMeasureSustains {
    my ($self,$i) = @_;
    my $rmn = $self->{_measNotes}{$i};
    my $song = $self->song();
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $bpm = $song->bpm($i);
    my $right = int($basex + $PIXELS_PER_BEAT * $bpm + 1e-7);

    my $staff1 = $basey + $SINGLE_STAFF_LINE_1;
    my $staff2 = $basey + $SINGLE_STAFF_LINE_2;
    my $staff3 = $basey + $SINGLE_STAFF_LINE_3;
    my $staff4 = $basey + $SINGLE_STAFF_LINE_4;
    my $staff5 = $basey + $SINGLE_STAFF_LINE_5;

    foreach my $n (@$rmn) {
	next unless $n->sustain();
	my $nleft = $n->startMeas();
	my $nright = $n->endMeas();
	$nleft = $i if $nleft < $i;
	$nright = $i+1 if $nright > $i+1;
	my $x1 = int ( 1e-7 + $basex + ($nleft-$i)  * ($right-$basex) );
	my $x2 = int ( 1e-7 + $basex + ($nright-$i) * ($right-$basex) );

	if ($n->green()  and $self->greenbot())     { $self->_drawLine("_im_song", "green", 3,$x1,$staff5,$x2,$staff5); }
	if ($n->red()    and $self->greenbot())     { $self->_drawLine("_im_song", "red",   3,$x1,$staff4,$x2,$staff4); }
	if ($n->yellow() and $self->greenbot())     { $self->_drawLine("_im_song", "yellow",3,$x1,$staff3,$x2,$staff3); }
	if ($n->blue()   and $self->greenbot())     { $self->_drawLine("_im_song", "blue",  3,$x1,$staff2,$x2,$staff2); }
	if ($n->orange() and $self->greenbot())     { $self->_drawLine("_im_song", "orange",3,$x1,$staff1,$x2,$staff1); }

	if ($n->green()  and not $self->greenbot()) { $self->_drawLine("_im_song", "green", 3,$x1,$staff1,$x2,$staff1); }
	if ($n->red()    and not $self->greenbot()) { $self->_drawLine("_im_song", "red",   3,$x1,$staff2,$x2,$staff2); }
	if ($n->yellow() and not $self->greenbot()) { $self->_drawLine("_im_song", "yellow",3,$x1,$staff3,$x2,$staff3); }
	if ($n->blue()   and not $self->greenbot()) { $self->_drawLine("_im_song", "blue",  3,$x1,$staff4,$x2,$staff4); }
	if ($n->orange() and not $self->greenbot()) { $self->_drawLine("_im_song", "orange",3,$x1,$staff5,$x2,$staff5); }
    }
}

sub _paintMeasureScores {
    my ($self,$i) = @_;
    my $song = $self->song();
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $bpm = $song->bpm($i);
    my $left = $basex;
    my $right = int($left + $PIXELS_PER_BEAT * $bpm + 1e-7);
    my $top = $basey + $SINGLE_STAFF_LINE_1;
    my $bot = $basey + $SINGLE_STAFF_LINE_5;
    ##my $scoretxt = sprintf "\%d/\%d", $self->{_basemeasscore}[$i],$self->{_multmeasscore}[$i];
    my $basescoretxt = sprintf "\%d", $self->{_basemeasscore}[$i];
    my $multscoretxt = sprintf "\%d", $self->{_multmeasscore}[$i];
    my $sptxt    = sprintf "%.2fSP", $self->{_spmeas}[$i];

    $self->_drawRightText("_im_song", "grey60",   "Helvetica",10,$basescoretxt,$right-3,$basey+$SINGLE_STAFF_LINE_5+10);
    $self->_drawRightText("_im_song", "DarkGreen","Helvetica",10,$multscoretxt,$right-3,$basey+$SINGLE_STAFF_LINE_5+20);
    if ($self->{_spmeas}[$i] > 0) {
        $self->_drawRightText("_im_song", "SteelBlue3","Helvetica",10,$sptxt,$right-3,$basey+$SINGLE_STAFF_LINE_5+30);
    }
}

sub _drawMeasureGrid {
    my ($self,$i) = @_;
    my $song = $self->song();
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $bpm = $song->bpm($i);

    my $left = $basex;
    my $right = int($left + $PIXELS_PER_BEAT * $bpm + 1e-7);
    my $top = $basey + $SINGLE_STAFF_LINE_1;
    my $bot = $basey + $SINGLE_STAFF_LINE_5;

    my $staff1 = $basey + $SINGLE_STAFF_LINE_1;
    my $staff2 = $basey + $SINGLE_STAFF_LINE_2;
    my $staff3 = $basey + $SINGLE_STAFF_LINE_3;
    my $staff4 = $basey + $SINGLE_STAFF_LINE_4;
    my $staff5 = $basey + $SINGLE_STAFF_LINE_5;

    ## Do the eighth notes
    for my $i (0 .. $bpm - 1 ) {
	my $eighth = int ($left + ($i + 0.5) * $PIXELS_PER_BEAT + 1e-7);
	$self->_drawLine("_im_song", "gray90",  1, $eighth,$bot,$eighth,$top);
    }

    ## Do the quarter note lines
    if ($bpm > 1 ) { 
        for my $i (1 .. $bpm - 1 ) {
            my $quarter = int ($left + ($i) * $PIXELS_PER_BEAT + 1e-7);
            $self->_drawLine("_im_song", "gray60",  1, $quarter,$bot,$quarter,$top);
        }
    }

    $self->_drawLine("_im_song", "black",   1, $left,$staff1,$right,$staff1);
    $self->_drawLine("_im_song", "gray60",  1, $left,$staff2,$right,$staff2);
    $self->_drawLine("_im_song", "gray60",  1, $left,$staff3,$right,$staff3);
    $self->_drawLine("_im_song", "gray60",  1, $left,$staff4,$right,$staff4);
    $self->_drawLine("_im_song", "black",   1, $left,$staff5,$right,$staff5);

    $self->_drawLine("_im_song", "black",   1, $left,  $bot, $left,  $top);
    $self->_drawLine("_im_song", "black",   1, $right, $bot, $right, $top);

    ## Do the measure number
    $self->_drawText("_im_song", "DarkRed","Helvetica",10,"$i",$left,$staff1-5);
    #my ($self,$color,$family,$size,$text,$x,$y) = @_;
}

sub _drawMeasureNotes {
    my ($self,$i) = @_;
    my $rmn = $self->{_measNotes}{$i};
    my $song = $self->song();
    my $bpm = $song->bpm($i);
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $right = int($basex + $PIXELS_PER_BEAT * $bpm + 1e-7);

    my $staff1 = $basey + $SINGLE_STAFF_LINE_1;
    my $staff2 = $basey + $SINGLE_STAFF_LINE_2;
    my $staff3 = $basey + $SINGLE_STAFF_LINE_3;
    my $staff4 = $basey + $SINGLE_STAFF_LINE_4;
    my $staff5 = $basey + $SINGLE_STAFF_LINE_5;

    foreach my $n (@$rmn) {
	my $nleft = $n->startMeas();
	next unless $nleft > $i - 1e-7;
	next unless $nleft < $i+1 + 1e-7;
	my $x = int ( 1e-7 + $basex + ($nleft-$i)  * ($right-$basex) );

	if ($n->green()  and not $n->star() and     $self->greenbot()) { $self->_drawNoteCircle("_im_song", "green", $x,$staff5); }
	if ($n->red()    and not $n->star() and     $self->greenbot()) { $self->_drawNoteCircle("_im_song", "red",   $x,$staff4); }
	if ($n->yellow() and not $n->star() and     $self->greenbot()) { $self->_drawNoteCircle("_im_song", "yellow",$x,$staff3); }
	if ($n->blue()   and not $n->star() and     $self->greenbot()) { $self->_drawNoteCircle("_im_song", "blue",  $x,$staff2); }
	if ($n->orange() and not $n->star() and     $self->greenbot()) { $self->_drawNoteCircle("_im_song", "orange",$x,$staff1); }

	if ($n->green()  and not $n->star() and not $self->greenbot()) { $self->_drawNoteCircle("_im_song", "green", $x,$staff1); }
	if ($n->red()    and not $n->star() and not $self->greenbot()) { $self->_drawNoteCircle("_im_song", "red",   $x,$staff2); }
	if ($n->yellow() and not $n->star() and not $self->greenbot()) { $self->_drawNoteCircle("_im_song", "yellow",$x,$staff3); }
	if ($n->blue()   and not $n->star() and not $self->greenbot()) { $self->_drawNoteCircle("_im_song", "blue",  $x,$staff4); }
	if ($n->orange() and not $n->star() and not $self->greenbot()) { $self->_drawNoteCircle("_im_song", "orange",$x,$staff5); }

	if ($n->green()  and     $n->star() and     $self->greenbot()) { $self->_drawNoteStar("_im_song", "green",   $x,$staff5); }
	if ($n->red()    and     $n->star() and     $self->greenbot()) { $self->_drawNoteStar("_im_song", "red",     $x,$staff4); }
	if ($n->yellow() and     $n->star() and     $self->greenbot()) { $self->_drawNoteStar("_im_song", "yellow",  $x,$staff3); }
	if ($n->blue()   and     $n->star() and     $self->greenbot()) { $self->_drawNoteStar("_im_song", "blue",    $x,$staff2); }
	if ($n->orange() and     $n->star() and     $self->greenbot()) { $self->_drawNoteStar("_im_song", "orange",  $x,$staff1); }

	if ($n->green()  and     $n->star() and not $self->greenbot()) { $self->_drawNoteStar("_im_song", "green",   $x,$staff1); }
	if ($n->red()    and     $n->star() and not $self->greenbot()) { $self->_drawNoteStar("_im_song", "red",     $x,$staff2); }
	if ($n->yellow() and     $n->star() and not $self->greenbot()) { $self->_drawNoteStar("_im_song", "yellow",  $x,$staff3); }
	if ($n->blue()   and     $n->star() and not $self->greenbot()) { $self->_drawNoteStar("_im_song", "blue",    $x,$staff4); }
	if ($n->orange() and     $n->star() and not $self->greenbot()) { $self->_drawNoteStar("_im_song", "orange",  $x,$staff5); }
    }
}

sub _drawLine {
    my ($self,$imagestr,$color,$width,$x1,$y1,$x2,$y2) = @_;
    if ($self->debug()) { print "Drawing Line ($color,$width,$x1,$y1,$x2,$y2)\n"; }
    my $im =    $self->{$imagestr};
    my $x = $im->Draw("primitive"   => "line",
	      "points"      => "$x1,$y1 $x2,$y2",
	      "antialias"   => "false",
	      "stroke"      => $color,
	      "strokewidth" => $width);
    warn "$x" if "$x";
}

sub _drawRect {
    my ($self,$imagestr,$color,$x1,$y1,$x2,$y2) = @_;
    if ($self->debug()) { print "Drawing Rect ($color,$x1,$y1,$x2,$y2)\n"; }
    my $im =    $self->{$imagestr};
    my $x = $im->Draw("primitive"   => "rectangle",
	      "points"      => "$x1,$y1 $x2,$y2",
	      "antialias"   => "false",
	      "fill"        => $color,
	      "stroke"      => $color,
	      "strokewidth" => 0.5);
    warn "$x" if "$x";
}

sub _drawNoteCircle {
    my ($self,$imagestr,$color,$x,$y) = @_;
    if ($self->debug()) { print "Drawing NoteCircle ($color,$x,$y)\n"; }
    my $im =    $self->{$imagestr};
    my $pointstr = sprintf "\%d,\%d \%d,\%d", $x,$y,$x+3,$y;
    $x = $im->Draw("primitive"   => "circle",
	      "points"      => $pointstr,
	      "stroke"      => "black",
	      "strokewidth" => 0.5,
	      "antialias"   => "false",
	      "fill"        => $color);
    warn "$x" if "$x";
}

sub _drawEllipse {
    my ($self,$imagestr,$color,$x,$y,$rx,$ry,$rot) = @_;
    if ($self->debug()) { print "Drawing Ellipse ($color,$x,$y,$rx,$ry,rot)\n"; }
    my $im =    $self->{$imagestr};
    my $pointstr = sprintf "\%d,\%d \%d,\%d \%d,\%d", 0,0,$rx,$ry,0,360;
    $x = $im->Draw("primitive"   => "ellipse",
	      "points"      => $pointstr,
	      "stroke"      => $color,
	      "rotate"      => $rot,
	      "translate"   => "$x,$y",
	      "strokewidth" => 0.5,
	      "antialias"   => "true",
	      "fill"        => $color);
    warn "$x" if "$x";
}

sub _drawNoteStar {
    my ($self,$imagestr,$color,$x,$y) = @_;
    if ($self->debug()) { print "Drawing NoteStar ($color,$x,$y)\n"; }
    my $im =    $self->{$imagestr};
    my $pointstr = sprintf "\%d,\%d \%d,\%d \%d,\%d \%d,\%d \%d,\%d,\%d,\%d \%d,\%d \%d,\%d \%d,\%d \%d,\%d",
                   $x+0,$y-4,
		   $x+2,$y-1,
		   $x+4,$y-1,
		   $x+2,$y+1,
		   $x+2,$y+4,
		   $x+0,$y+2,
		   $x-2,$y+4,
		   $x-2,$y+1,
		   $x-4,$y-1,
		   $x-2,$y-1;
    $x = $im->Draw("primitive"   => "polygon",
	      "points"      => $pointstr,
	      "stroke"      => "black",
	      "strokewidth" => 0.5,
	      "antialias"   => "false",
	      "fill"        => $color);
    warn "$x" if "$x";
}

sub _drawText {
    my ($self,$imagestr,$color,$family,$size,$text,$x,$y) = @_;
    if ($self->debug()) { print "Drawing text ($color,$family,$size,$text,$x,$y)\n"; }
    my $im =    $self->{$imagestr};
    $x = $im->Annotate(text      => $text,
	                  family    => $family,
			  fill      => $color,
			  pointsize => $size,
			  x         => $x,
			  y         => $y);
    warn "$x" if "$x";
}

sub _drawRightText {
    my ($self,$imagestr,$color,$family,$size,$text,$x,$y) = @_;
    if ($self->debug()) { print "Drawing text ($color,$family,$size,$text,$x,$y)\n"; }
    my $im =    $self->{$imagestr};
    $x = $im->Annotate(text      => $text,
	                  family    => $family,
			  fill      => $color,
			  pointsize => $size,
			  align     => "Right",
			  gravity   => "South",
			  x         => $x,
			  y         => $y);
    warn "$x" if "$x";
}

sub _drawCenteredText {
    my ($self,$imagestr,$color,$family,$size,$text,$x,$y) = @_;
    if ($self->debug()) { print "Drawing text ($color,$family,$size,$text,$x,$y)\n"; }
    my $im =    $self->{$imagestr};
    $x = $im->Annotate(text      => $text,
	                  family    => $family,
			  fill      => $color,
			  pointsize => $size,
			  align     => "Center",
			  gravity   => "South",
			  x         => $x,
			  y         => $y);
    warn "$x" if "$x";
}

sub __min {
    my $min = $_[0];
    foreach my $a (@_) { $min = $a if $a < $min; }
    return $min;
}

sub __max {
    my $max = $_[0];
    foreach my $a (@_) { $max = $a if $a > $max; }
    return $max;
}


1;
