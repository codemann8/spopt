# $Id: SongPainter.pm,v 1.16 2009-04-25 23:22:34 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongPainter.pm,v $

package Spopt::SongPainter;

use strict;

use Image::Magick;
use FindBin;
use Time::HiRes qw ( gettimeofday tv_interval );
use POSIX qw( strftime );

our $VERSION = do { my @r=(q$Revision: 1.16 $=~/\d+/g); sprintf '%d.'.'%03d'x$#r,@r };

my $QUANTUM_DEPTH;

my $PIXEL_WIDTH = 1024;

my $BEATS_PER_ROW = 24;
my $LEFT_MARGIN_PIXELS = 16;
my $PIXELS_PER_BEAT = 40;
my $HEADER_PIXELS = 90;
my $FOOTER_PIXELS = 40;
my $FOOTER_MARGIN_PIXELS = 40;
my $PIXELS_PER_SINGLE_ROW = 114;

my $HELV_FONT;
my $TIMES_FONT;
if ($^O eq "MSWin32") {
	$HELV_FONT = 'Arial';
	$TIMES_FONT = 'Times-New-Roman';
}
else {
	$HELV_FONT = 'Helvetica';
	$TIMES_FONT = 'Times';
}

my $FOOTER_BLURB_LEFT  = 
    'Generated on: ' . POSIX::strftime('%Y-%m-%d %T', localtime) . ".\n" .
    "'spopt' written by debr5836/tma/codemann8 (spopt\@moto-coda.org).\n" .
    "SongPainter.pm v$VERSION.";
my $FOOTER_BLURB_RIGHT =
    "http://www.slowhero.com/\n"  .
    "http://www.scorehero.com/\n" .
    'http://pathhero.codemann8.com/';

my @STAFF_LINES_a = (
    -1,         # special for "purple" notes
    24 + 0,
    24 + 1*12,
    24 + 2*12,
    24 + 3*12,
    24 + 4*12,
);

my %noteInfo_h = (
    'P' => { 'col' => '#9b30ff80', 'pos' => 0 },
    'R' => { 'col' => 'red',       'pos' => 1 },
    'G' => { 'col' => 'green',     'pos' => 2 },
    'Y' => { 'col' => 'yellow',    'pos' => 3 },
    'B' => { 'col' => 'blue',      'pos' => 4 },
    'O' => { 'col' => 'orange',    'pos' => 5 },
);

my @timers;

sub new    { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop  { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }

# song() : song object from Song.pm
sub song      { my $self = shift; return $self->_prop('song',@_);  }

# filename() : define the output filename
sub filename  { my $self = shift; return $self->_prop('filename',@_);  }

# debug() : turns on various debug options, file dumps, etc
sub debug     { my $self = shift; return $self->_prop('debug',@_);  }

# timing() : output timing information
sub timing    { my $self = shift; return $self->_prop('timing',@_);  }

# sol() : solution object from Optimizer.pm
sub sol       { my $self = shift; return $self->_prop('sol',@_);  }

# title() : main title for the chart
sub title     { my $self = shift; return $self->_prop('title',@_);  }

# subtitle() : subtitle for the chart (usually the difficulty)
sub subtitle  { my $self = shift; return $self->_prop('subtitle',@_);  }

# outline_only() : defines if star power phrases highlights are fills (rectangles) or outlines (lines)
sub outline_only  { my $self = shift; return $self->_prop('outline_only',@_);  }

# note_order() : define the note order on the chart. 
#   options: 'guitar', 'drum', or 'custom'.
#   'custom' takes a list of letters corresponding to the colour, 
#   e.g. $painter->note_order('custom', [ qw( P G R Y B O ) ]);
sub note_order {
    my $self = shift; 
    my $order = shift;
    my $order_a;
    if ( $order eq 'guitar' ) { @$order_a = qw( P G R Y B O ) };
    if ( $order eq 'drum'   ) { @$order_a = qw( P R Y B O G ) };
    if ( $order eq 'custom' ) { @$order_a = shift };
    
    for my $pos ( 0 .. scalar @$order_a ) {
        my $note = $order_a->[$pos];
        $noteInfo_h{ $note }->{'pos'} = $pos;
    }
    return $self->_prop('note_order',@_); 
}

# define the amount of star power gained per quarter bar of whammy for the sp calculator
sub whammy_per_quarter_bar  { my $self = shift; return $self->_prop('whammy_per_quarter_bar',@_);  }

sub clear_unrestricted    { my $self = shift; $self->{unrestricted}   = []; }
sub clear_partial         { my $self = shift; $self->{partial}        = []; }
sub clear_trailing        { my $self = shift; $self->{trailing}       = []; }
sub clear_spsqueeze       { my $self = shift; $self->{spsqueeze}      = []; }
sub clear_nwunrestricted  { my $self = shift; $self->{nwunrestricted} = []; }
sub clear_nwpartial       { my $self = shift; $self->{nwpartial}      = []; }
sub clear_nwtrailing      { my $self = shift; $self->{nwtrailing}     = []; }
sub clear_activation      { my $self = shift; $self->{activation}     = []; }
sub clear_squeeze         { my $self = shift; $self->{squeeze}        = []; }

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

    $self->song('');
    $self->filename('');
    $self->title('');
    $self->subtitle('');
    $self->sol('NONE');

    $self->note_order('guitar');
    $self->outline_only(0);
    $self->whammy_per_quarter_bar(7.5);
    $self->debug(0);
    $self->timing(0);

    $self->clear_unrestricted();
    $self->clear_partial();
    $self->clear_trailing();
    $self->clear_spsqueeze();
    $self->clear_nwunrestricted();
    $self->clear_nwpartial();
    $self->clear_nwtrailing();
    $self->clear_activation();
    $self->clear_squeeze();
}

# start a timer event
sub _set_timer {
    my $self  = shift;
    push @timers, [gettimeofday];
}

# pull last timer event and calculate time taken
sub _get_timer {
    my $self = shift;
    my $level = shift;
    $level = defined $level ? $level : 1 ;

    my @caller_a = caller 1;
    my $time = tv_interval( pop @timers );
    if ( $self->timing >= $level ) {
        printf "%-40s: %.3f\n", $caller_a[3], $time;
    }
}

sub paintsol {
    my ($self,$sol) = @_;
    $self->_set_timer();
    $self->sol($sol);
    if ( $self->timing ) { };
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
    $self->_get_timer();
}

sub _highlight_activation {
    my ($self,$ract,$spcursor) = @_;
    $self->_set_timer();
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
    $self->_get_timer();
    return $nextspidx;
}

sub paintsong {
    my $self = shift;
    $self->_set_timer();
    my $song = $self->song();
    my $na = $song->notearr();
    # check for an empty chart
    if ( scalar @$na == 0 ) {
	print "No notes in this chart.\n";
	return 1;
    }

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
    $self->_printFooter();
    $self->_paintSectionLabels();
    $self->_merge_images();
    $self->_save_file();
    $self->_get_timer();
}

sub _paintSectionLabels {
    my $self = shift;
    $self->_set_timer();
    my $song = $self->song();
    my $ra = $song->sectionnames();
    foreach my $rra (@$ra) {
	my ($meas,$txt) = @$rra;
	$meas = int ($meas + 0.5); ## round to the nearest measure to be sure to have room to type the text
        my $basex = $self->{_measureCoords}{$meas}{x};
        my $basey = $self->{_measureCoords}{$meas}{y};
        $self->_drawText(
            '_im_song',
            'Black',
            $HELV_FONT,
            10,
            $txt,
            $basex + 20,
            $basey + $STAFF_LINES_a[1] - 5,
        );
    }
    $self->_get_timer();
}

sub _merge_images {
    my $self = shift;
    $self->_set_timer();
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
        my $opacity = 200;
        if ( $QUANTUM_DEPTH == 16 ) { $opacity *= 256 };
        $x = $self->{_im_song}->Composite(image => $self->{_im_lo},  compose=>'Dissolve', opacity=>$opacity, x=>0, y=>0);
        warn $x if $x;
    }
    
    else {
        my $opacity = 100;
        if ( $QUANTUM_DEPTH == 16 ) { $opacity *= 256 };
        $x = $self->{_im_song}->Composite(image => $self->{_im_lo},  compose=>'Dissolve', opacity=>$opacity, x=>0, y=>0);
        warn $x if $x;
    }
    $self->_get_timer();
}

sub _printTitles() {
    my $self = shift;
    $self->_set_timer();
    my $title = $self->title();
    my $subtitle = $self->subtitle();
    $self->_drawCenteredText('_im_song','black',$TIMES_FONT,50,$title,512,40) if $title;
    $self->_drawCenteredText('_im_song','black',$TIMES_FONT,30,$subtitle,512,80) if $subtitle;
    $self->_get_timer();
}

sub _printFooter() {
    my $self = shift;
    $self->_set_timer();
    my $footer_position = $HEADER_PIXELS + $self->{'_numrows'} * $PIXELS_PER_SINGLE_ROW + $FOOTER_MARGIN_PIXELS;
    $self->_drawText(
        '_im_song',
        '#333333',
        $HELV_FONT,
        12,
        $FOOTER_BLURB_LEFT,
        $LEFT_MARGIN_PIXELS + 10,
        $footer_position
    );
    $self->_drawText(
        '_im_song',
        '#333333',
        $HELV_FONT,
        12,
        $FOOTER_BLURB_RIGHT,
        $PIXEL_WIDTH - $LEFT_MARGIN_PIXELS - 200,
        $footer_position
    );
    $self->_get_timer();
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
    $self->_set_timer();
    my $song = $self->song();
    my $na = $song->notearr();
    my $last_measure = int($na->[-1]->endMeas() + 1e-7);
    $self->{_lastMeasure} = $last_measure;
    $self->_get_timer();
}

sub _calc_stats_per_measure {
    my $self = shift;
    $self->_set_timer();
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
    $self->_get_timer();
}

sub _calc_sp_multscore_stat_per_meas {
    my $self = shift;
    $self->_set_timer();
    my $sol = $self->sol();
    my $ract = $sol->activations();
    foreach my $act (@$ract) { $self->_dist_sp_activation($act); }
    $self->_get_timer();
}

sub _make_multmeasscore_cumulative() {
    my $self = shift;
    $self->_set_timer();
    my $song = $self->song();
    my $na = $song->notearr();
    my $lm = $self->{_lastMeasure};
    next if $lm == 1;
    for my $i ( 2 .. $lm) { $self->{_multmeasscore}[$i] += $self->{_multmeasscore}[$i-1]; }
    $self->_get_timer();
}

sub _calc_notescore_stat_per_meas {
    my $self = shift;
    $self->_set_timer();
    my $song = $self->song();
    my $na = $song->notearr();
    foreach my $n (@$na) {
	my $meas = int ($n->startMeas()+1e-7); 
	$self->{_basemeasscore}[$meas] += $n->baseNoteScore();
	$self->{_multmeasscore}[$meas] += $n->multNoteScore();
    }
    $self->_get_timer();
}

sub _calc_sustscore_stat_per_meas {
    my $self = shift;
    $self->_set_timer();
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
    $self->_get_timer();
}

sub _dist_sp_activation {
    my ($self,$act) = @_;
    $self->_set_timer();
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
    $self->_get_timer();
}

sub _dist_basesust_score {
    my ($self,$points,$chordsize,$startBeat,$endBeat) = @_;
    $self->_set_timer();
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
            my $bs = $chordsize * int ( $points * $overlap / $numbeats / $chordsize );
	    $bs = $running_points if $bs > $running_points;
	    $self->{_basemeasscore}[$i] += $bs;
	    $running_points -= $bs;
	}
    }
    $self->{_basemeasscore}[$rightmeas] += $running_points;
    $self->_get_timer();
}

sub _dist_multsust_score {
    my ($self,$points,$chordsize,$mult,$startBeat,$endBeat) = @_;
    $self->_set_timer();
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
    $self->_get_timer();
}

sub _calc_sp_stat_per_meas {
    my $self = shift;
    $self->_set_timer();
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
    $self->_get_timer();
}

sub _initialize_im {
    my $self = shift;
    $self->_set_timer();
    my $x = $PIXEL_WIDTH;
    my $y = $self->{_numrows} * $PIXELS_PER_SINGLE_ROW + $HEADER_PIXELS + $FOOTER_MARGIN_PIXELS + $FOOTER_PIXELS;
    my $im = Image::Magick->new(size=>"${x}x$y");
    $QUANTUM_DEPTH = $im->QuantumDepth();
    $im->Read("xc:white");
    ##my $pointstr = sprintf "\%d,\%d \%d,\%d", 0,0,$x-1,$y-1;
    ##$im->Draw("primitive"   => "rectangle",
    ##"points"      => $pointstr,
    ##"stroke"      => "white",
    ##"fill"        => "white",
    ##"strokewidth" => 1);
    $self->_get_timer();
    return $im;
}

sub _save_file {
    my $self = shift;
    $self->_set_timer();
    my $im = $self->{_im_song};
    my $filename = $self->filename();
    ##my $x = $im->Write($self->{filename});
    my $x = $im->Write($filename);
    warn "$x" if "$x";
    $self->_get_timer();
}

sub _map_measures_to_coords {
    my $self = shift;
    $self->_set_timer();
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
    $self->_get_timer();
}

sub _map_notes_to_measures {
    my $self = shift;
    $self->_set_timer();
    my $song = $self->song();
    my $na = $song->notearr();
    $self->{_measNotes} = {};
    foreach my $n (@$na) {
	my $ss = int($n->startMeas()+1e-7);
	my $ee = int($n->endMeas()+1e-7);
	for my $i ($ss .. $ee) { push @{$self->{_measNotes}{$i}}, $n; }
    }
    $self->_get_timer();
}

sub _print_measures {
    my $self = shift;
    $self->_set_timer();
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
    $self->_get_timer();
}

sub _print_tempos {
    my $self = shift;
    $self->_set_timer();
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
        my $staff1 = $basey + $STAFF_LINES_a[1];
	$self->_draw_tempo($tempo,$basex+$offset,$staff1-20);
        #print '===' . "\n"; ## DEBUG
        #print '$meas='.$meas."\n"; ## DEBUG
        #print '$STAFF_LINES_a[1]=' . $STAFF_LINES_a[1] ."\n"; ## DEBUG
        #print '$basex=' . $basex ."\n"; ## DEBUG
        #print '$basey=' . $basey ."\n"; ## DEBUG
        #print '$tempo=' . $tempo ."\n"; ##DEBUG
        #print '$offset=' . $offset ."\n"; ##DEBUG
        #print '$staff1=' . $staff1 ."\n"; ## DEBUG
    }
    $self->_get_timer();
}

sub _filter_tempos() {
    my $self = shift;
    $self->_set_timer();

    my $tarr = shift;

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
    $self->_get_timer();
}

sub _highlight_regions { 
    my $self = shift;
    $self->_set_timer();
    my ($i,$name,$imtag,$color) = @_;
    my $song = $self->song();
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $bpm = $song->bpm($i);
    my $right = int($basex + $PIXELS_PER_BEAT * $bpm + 1e-7);
    my $staff1 = $basey + $STAFF_LINES_a[1];
    my $staff2 = $basey + $STAFF_LINES_a[2]; 
    my $staff3 = $basey + $STAFF_LINES_a[3]; 
    my $staff4 = $basey + $STAFF_LINES_a[4]; 
    my $staff5 = $basey + $STAFF_LINES_a[5]; 

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
    $self->_get_timer(2);
}

sub _drawTimeSignature {
    my ($self,$i) = @_;
    $self->_set_timer();
    my $song = $self->song();
    if ($i == 0 or $i == 1 or $song->bpm($i) != $song->bpm($i-1)) {
        my $basex = $self->{_measureCoords}{$i}{x};
        my $basey = $self->{_measureCoords}{$i}{y};
        my $staff3 = $basey + $STAFF_LINES_a[3];
        my $staff5 = $basey + $STAFF_LINES_a[5];
	my $bpm = $song->bpm($i);
        $self->_drawText("_im_song","gray80",$TIMES_FONT,32,"$bpm",$basex+3,$staff3);
        $self->_drawText("_im_song","gray80",$TIMES_FONT,32,"4"   ,$basex+3,$staff5);
    }
    $self->_get_timer(2);
}

sub _draw_tempo {
    my ($self,$tempo,$x,$y) = @_;
    $self->_set_timer();

    my $font = "$FindBin::Bin/../assets/fonts/tindtre/TEMPILTR.TTF";
    #my $font = "$FindBin::Bin/../assets/fonts/tmpindlt/TEMPIL__.TTF";
	if ($^O eq "MSWin32") {
		$self->_drawText(   '_im_song', 'black',$HELV_FONT,10,"t",$x,$y+3);
	}
	else {
		$self->_drawText(   '_im_song', 'black',$font,10,"%",$x,$y+3);
	}
    $self->_drawText(   '_im_song', 'black',$HELV_FONT,10,"=$tempo",$x+6,$y+3);
    $self->_get_timer(2);
}

sub _drawMeasureSustains {
    my ($self,$i) = @_;
    $self->_set_timer();
    my $rmn = $self->{_measNotes}{$i};
    my $song = $self->song();
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $bpm = $song->bpm($i);
    my $right = int($basex + $PIXELS_PER_BEAT * $bpm + 1e-7);

    foreach my $n (@$rmn) {
	next unless $n->sustain();
        next if $n->purple();

	my $nleft = $n->startMeas();
	my $nright = $n->endMeas();
	$nleft = $i if $nleft < $i;
	$nright = $i+1 if $nright > $i+1;
	my $x1 = int ( 1e-7 + $basex + ($nleft-$i)  * ($right-$basex) );
	my $x2 = int ( 1e-7 + $basex + ($nright-$i) * ($right-$basex) );

        my @noteCode_a;
        if ( $n->green()  ) { push @noteCode_a, 'G'; };
        if ( $n->red()    ) { push @noteCode_a, 'R'; };
        if ( $n->yellow() ) { push @noteCode_a, 'Y'; };
        if ( $n->blue()   ) { push @noteCode_a, 'B'; };
        if ( $n->orange() ) { push @noteCode_a, 'O'; };
        if ( $n->purple() ) { push @noteCode_a, 'P'; };

        for my $noteCode ( @noteCode_a ) {
            my $noteCol    = $noteInfo_h{ $noteCode }->{'col'};
            my $notePosRef = $noteInfo_h{ $noteCode }->{'pos'};
            my $notePos    = $STAFF_LINES_a[ $notePosRef ] + $basey;

            $self->_drawLine(
                '_im_song', # base image to draw on
                $noteCol,   # colour of the note
                3,          # width of the note in pixels, not including border?
                $x1,        # x position for start of note
                $notePos,   # y position for start of note
                $x2,        # x position for end of note
                $notePos,   # y position for end of note
            );
        }
    }
    $self->_get_timer(2);
}

sub _paintMeasureScores {
    my ($self,$i) = @_;
    $self->_set_timer();
    my $song = $self->song();
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $bpm = $song->bpm($i);
    my $left = $basex;
    my $right = int($left + $PIXELS_PER_BEAT * $bpm + 1e-7);
    my $top = $basey + $STAFF_LINES_a[1];
    my $bot = $basey + $STAFF_LINES_a[5];
    ##my $scoretxt = sprintf "\%d/\%d", $self->{_basemeasscore}[$i],$self->{_multmeasscore}[$i];
    my $basescoretxt = sprintf "\%d", $self->{_basemeasscore}[$i];
    my $multscoretxt = sprintf "\%d", $self->{_multmeasscore}[$i];
    my $sptxt    = sprintf "%.2fSP", $self->{_spmeas}[$i];

    $self->_drawRightText("_im_song", "grey60",   $HELV_FONT,10,$basescoretxt,$right-3,$basey+$STAFF_LINES_a[5]+10);
    $self->_drawRightText("_im_song", "DarkGreen",$HELV_FONT,10,$multscoretxt,$right-3,$basey+$STAFF_LINES_a[5]+20);
    if ($self->{_spmeas}[$i] > 0) {
        $self->_drawRightText("_im_song", "SteelBlue3",$HELV_FONT,10,$sptxt,$right-3,$basey+$STAFF_LINES_a[5]+30);
    }
    $self->_get_timer(2);
}

sub _drawMeasureGrid {
    my ($self,$i) = @_;
    $self->_set_timer();
    my $song = $self->song();
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $bpm = $song->bpm($i);

    my $left = $basex;
    my $right = int($left + $PIXELS_PER_BEAT * $bpm + 1e-7);
    my $top = $basey + $STAFF_LINES_a[1];
    my $bot = $basey + $STAFF_LINES_a[5];

    my $staff1 = $basey + $STAFF_LINES_a[1];
    my $staff2 = $basey + $STAFF_LINES_a[2];
    my $staff3 = $basey + $STAFF_LINES_a[3];
    my $staff4 = $basey + $STAFF_LINES_a[4];
    my $staff5 = $basey + $STAFF_LINES_a[5];

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
    $self->_drawText("_im_song", "DarkRed",$HELV_FONT,10,"$i",$left,$staff1-5);
    #my ($self,$color,$family,$size,$text,$x,$y) = @_;
    $self->_get_timer(2);
}

sub _drawMeasureNotes {
    my ($self,$i) = @_;
    $self->_set_timer();
    my $rmn = $self->{_measNotes}{$i};
    my $song = $self->song();
    my $bpm = $song->bpm($i);
    my $basex = $self->{_measureCoords}{$i}{x};
    my $basey = $self->{_measureCoords}{$i}{y};
    my $right = int($basex + $PIXELS_PER_BEAT * $bpm + 1e-7);

    my $staff1 = $basey + $STAFF_LINES_a[1];
    my $staff2 = $basey + $STAFF_LINES_a[2];
    my $staff3 = $basey + $STAFF_LINES_a[3];
    my $staff4 = $basey + $STAFF_LINES_a[4];
    my $staff5 = $basey + $STAFF_LINES_a[5];

    foreach my $n (@$rmn) {
	my $nleft = $n->startMeas();
	next unless $nleft > $i - 1e-7;
	next unless $nleft < $i+1 + 1e-7;
	my $x = int ( 1e-7 + $basex + ($nleft-$i)  * ($right-$basex) );

        my @noteCode_a;
        if ( $n->green()  ) { push @noteCode_a, 'G'; };
        if ( $n->red()    ) { push @noteCode_a, 'R'; };
        if ( $n->yellow() ) { push @noteCode_a, 'Y'; };
        if ( $n->blue()   ) { push @noteCode_a, 'B'; };
        if ( $n->orange() ) { push @noteCode_a, 'O'; };
        if ( $n->purple() ) { push @noteCode_a, 'P'; };

        for my $noteCode ( @noteCode_a ) {
            my $noteCol    = $noteInfo_h{ $noteCode }->{'col'};
            my $notePosRef = $noteInfo_h{ $noteCode }->{'pos'};
            my $notePos    = $STAFF_LINES_a[ $notePosRef ] + $basey;

            if ( $n->star() ) {
                if ( $notePosRef == 0 ) {
                    # draw a lined star note (i.e. "purple" note)
                    $self->_drawNoteLineStar(
                        '_im_song',
                        $noteCol,
                        $x,
                        $STAFF_LINES_a[1] + $basey, # hardcoded to start on the top line
                    ); 
                }
                else {
                    # draw a regular star note
                    $self->_drawNoteStar(
                        '_im_song',
                        $noteCol,
                        $x,
                        $notePos,
                    );
                }
            }
            else {
                if ( $notePosRef == 0 ) {
                    # draw a lined note (i.e. "purple" note)
                    $self->_drawNoteLine(
                        '_im_song',
                        $noteCol,
                        $x,
                        $STAFF_LINES_a[1] + $basey, # hardcoded to start on the top line
                    ); 
                }
                else {
                    # draw a regular note
                    $self->_drawNoteCircle(
                        '_im_song',
                        $noteCol,
                        $x,
                        $notePos,
                    );
                }
            }
        }
    }
    $self->_get_timer(2);
}

sub _drawLine {
    my ($self,$imagestr,$color,$width,$x1,$y1,$x2,$y2) = @_;
    $self->_set_timer();
    if ($self->debug()) { print "Drawing Line ($color,$width,$x1,$y1,$x2,$y2)\n"; }
    my $im =    $self->{$imagestr};
    my $x = $im->Draw("primitive"   => "line",
	      "points"      => "$x1,$y1 $x2,$y2",
	      "antialias"   => "false",
	      "stroke"      => $color,
	      "strokewidth" => $width);
    warn "$x" if "$x";
    $self->_get_timer(2);
}

sub _drawRect {
    my ($self,$imagestr,$color,$x1,$y1,$x2,$y2) = @_;
    $self->_set_timer();
    if ($self->debug()) { print "Drawing Rect ($color,$x1,$y1,$x2,$y2)\n"; }
    my $im =    $self->{$imagestr};
    my $x = $im->Draw("primitive"   => "rectangle",
	      "points"      => "$x1,$y1 $x2,$y2",
	      "antialias"   => "false",
	      "fill"        => $color,
	      "stroke"      => $color,
	      "strokewidth" => 0.5);
    warn "$x" if "$x";
    $self->_get_timer(2);
}

sub _drawNoteCircle {
    my ($self,$imagestr,$color,$x,$y) = @_;
    $self->_set_timer();
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
    $self->_get_timer(2);
}

sub _drawNoteStar {
    my ($self,$imagestr,$color,$x,$y) = @_;
    $self->_set_timer();
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
    $self->_get_timer(2);
}

sub _drawNoteLine {
    my ($self,$imagestr,$color,$x,$y) = @_;
    $self->_set_timer();
    my $im = $self->{$imagestr};

    my $width = 4;
    my $xOffset = 2;
    my $height = $STAFF_LINES_a[5] - $STAFF_LINES_a[1];
    my $yOverlap = 3;

    my $topLeftX = $x - $xOffset;
    my $topLeftY = $y - $yOverlap;
    my $bottomRightX = $x + $width - $xOffset;
    my $bottomRightY = $y + $height + $yOverlap;

    if ($self->debug()) { print "Drawing NoteLine ($color,$topLeftX,$topLeftY,$bottomRightX,$bottomRightY)\n"; }

    my $pointstr = sprintf '%d,%d %d,%d %d,%d', $topLeftX, $topLeftY, $bottomRightX, $bottomRightY, 1, 2;
    $x = $im->Draw(
        'primitive'   => 'roundrectangle',
	'points'      => $pointstr,
	'stroke'      => $color,
	#'stroke'      => 'black',
	'strokewidth' => 0.5,
	'antialias'   => 'false',
	'fill'        => $color
    );
    warn "$x" if "$x";
    $self->_get_timer(2);
}

sub _drawNoteLineStar {
    _drawNoteLine(@_);
}

sub _drawText {
    my ($self,$imagestr,$color,$family,$size,$text,$x,$y) = @_;
    $self->_set_timer();
    if ($self->debug()) { print "Drawing text ($color,$family,$size,$text,$x,$y)\n"; }
    my $im =    $self->{$imagestr};
    $x = $im->Annotate( 
        text      => $text,
        family    => $family,
        font      => $family,
        fill      => $color,
        pointsize => $size,
        x         => $x,
        y         => $y
    );
    warn "$x" if "$x";
    $self->_get_timer(2);
}

sub _drawRightText {
    my ($self,$imagestr,$color,$family,$size,$text,$x,$y) = @_;
    $self->_set_timer();
    if ($self->debug()) { print "Drawing text ($color,$family,$size,$text,$x,$y)\n"; }
    my $im =    $self->{$imagestr};
    $x = $im->Annotate(
        text      => $text,
        family    => $family,
        fill      => $color,
        pointsize => $size,
        align     => "Right",
        gravity   => "South",
        x         => $x,
        y         => $y
    );
    warn "$x" if "$x";
    $self->_get_timer(2);
}

sub _drawCenteredText {
    my ($self,$imagestr,$color,$family,$size,$text,$x,$y) = @_;
    $self->_set_timer();
    if ($self->debug()) { print "Drawing text ($color,$family,$size,$text,$x,$y)\n"; }
    my $im =    $self->{$imagestr};
    $x = $im->Annotate(
        text      => $text,
        family    => $family,
        fill      => $color,
        pointsize => $size,
        align     => "Center",
        gravity   => "South",
        x         => $x,
        y         => $y
    );
    warn "$x" if "$x";
    $self->_get_timer(2);
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
