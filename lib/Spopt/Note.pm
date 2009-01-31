#!/usr/bin/perl5

package Note;
use strict;

our $MIN_SUSTAIN_SEPARATION = 161;
our $GH3_MIN_SUSTAIN_SEPARATION = 32;
##our $GH3_MIN_SUSTAIN_SEPARATION = 161;
our $EPS = 1e-7;

sub new        { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop      { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }

## Source fields
sub green      { my $self = shift; return $self->_prop('green',@_);     }
sub red        { my $self = shift; return $self->_prop('red',@_);       }
sub yellow     { my $self = shift; return $self->_prop('yellow',@_);    }
sub blue       { my $self = shift; return $self->_prop('blue',@_);      }
sub orange     { my $self = shift; return $self->_prop('orange',@_);    }
sub purple     { my $self = shift; return $self->_prop('purple',@_);    }
sub startTick  { my $self = shift; return $self->_prop('startTick',@_); }
sub endTick    { my $self = shift; return $self->_prop('endTick',@_);   }
sub star       { my $self = shift; return $self->_prop('star',@_);      }
sub mult       { my $self = shift; return $self->_prop('mult',@_);      }
sub multsust   { my $self = shift; return $self->_prop('multsust',@_);  }
sub prevTempo  { my $self = shift; return $self->_prop('prevTempo',@_); }
sub currTempo  { my $self = shift; return $self->_prop('currTempo',@_); }
sub nextTempo  { my $self = shift; return $self->_prop('nextTempo',@_); }
sub idx        { my $self = shift; return $self->_prop('idx',@_);       }

## Derived fields
sub notestr         { my $self = shift; return $self->_prop("notestr",@_);        }
sub chordsize       { my $self = shift; return $self->_prop("chordsize",@_);      }
sub sustain         { my $self = shift; return $self->_prop("sustain",@_);        }

sub lenTick         { my $self = shift; return $self->_prop("lenTick",@_);        }
sub lenBeat         { my $self = shift; return $self->_prop("lenBeat",@_);        }
sub lenMeas         { my $self = shift; return $self->_prop("lenMeas",@_);        }

sub startBeat       { my $self = shift; return $self->_prop("startBeat",@_);      }
sub startMeas       { my $self = shift; return $self->_prop("startMeas",@_);      }
sub endBeat         { my $self = shift; return $self->_prop("endBeat",@_);        }
sub endMeas         { my $self = shift; return $self->_prop("endMeas",@_);        }

sub baseSpTick      { my $self = shift; return $self->_prop("baseSpTick",@_);     }
sub baseSpBeat      { my $self = shift; return $self->_prop("baseSpBeat",@_);     }

sub baseNoteScore   { my $self = shift; return $self->_prop("baseNoteScore",@_);  }
sub baseSustScore   { my $self = shift; return $self->_prop("baseSustScore",@_);  }
sub baseTotScore    { my $self = shift; return $self->_prop("baseTotScore",@_);   }

sub playNoteScore   { my $self = shift; return $self->_prop("playNoteScore",@_);  }
sub playSustScore   { my $self = shift; return $self->_prop("playSustScore",@_);  }
sub playTotScore    { my $self = shift; return $self->_prop("playTotScore",@_);  }

sub GHExNoteScore   { my $self = shift; return $self->_prop("GHExNoteScore",@_);  }
sub GHExSustScore   { my $self = shift; return $self->_prop("GHExSustScore",@_);  }
sub GHExTotScore    { my $self = shift; return $self->_prop("GHExTotScore",@_);  }

sub multNoteScore   { my $self = shift; return $self->_prop("multNoteScore",@_);      }
sub multSustScore   { my $self = shift; return $self->_prop("multSustScore",@_);      }
sub multTotScore    { my $self = shift; return $self->_prop("multTotScore",@_);       }

## Squeeze related fields
sub squeezedSpTick       { my $self = shift; return $self->_prop("squeezedSpTick",@_); }
sub squeezedSpBeat       { my $self = shift; return $self->_prop("squeezedSpBeat",@_); }
sub totSpBeat            { my $self = shift; return $self->_prop("totSpBeat",@_);      }
sub totSpTick            { my $self = shift; return $self->_prop("totSpTick",@_);      }
sub effectiveSPStartTick { my $self = shift; return $self->_prop("effectiveSPStartTick",@_);      }
sub effectiveSPStartBeat { my $self = shift; return $self->_prop("effectiveSPStartBeat",@_);      }
sub effectiveSPStartMeas { my $self = shift; return $self->_prop("effectiveSPStartMeasure",@_);      }
sub SpEndTick            { my $self = shift; return $self->_prop("SpEndTick",@_);      }
sub SpEndBeat            { my $self = shift; return $self->_prop("SpEndBeat",@_);      }
sub SpEndMeas            { my $self = shift; return $self->_prop("SpEndMeasure",@_);      }

sub leftStartBeat   { my $self = shift; return $self->_prop("leftStartBeat",@_);  }
sub leftStartMeas   { my $self = shift; return $self->_prop("leftStartMeas",@_);  }
sub leftStartTick   { my $self = shift; return $self->_prop("leftStartTick",@_);  }
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
    $self->purple(0);
    $self->startTick(0);
    $self->endTick(0);
    $self->star(0);
    $self->mult(1);
    $self->multsust(1);
    $self->prevTempo("");
    $self->currTempo("");
    $self->nextTempo("");
    $self->idx(0);
}

sub calc_unsqueezed_data {
    my $self = shift;
    my $song = shift;
    my $game = $song->game();

    my $min_sust_sep = $game =~ m/gh3|ghwt/ ? $GH3_MIN_SUSTAIN_SEPARATION : $MIN_SUSTAIN_SEPARATION; 

    ## Do note string and chord size first
    my $notestr = "";
    my $chordsize = 0;
    if ($self->green())  { $notestr .= "G"; $chordsize++; }
    if ($self->red())    { $notestr .= "R"; $chordsize++; }
    if ($self->yellow()) { $notestr .= "Y"; $chordsize++; }
    if ($self->blue())   { $notestr .= "B"; $chordsize++; }
    if ($self->orange()) { $notestr .= "O"; $chordsize++; }
    if ($self->purple()) { $notestr .= "P"; $chordsize++; }
    $self->notestr($notestr);
    $self->chordsize($chordsize);

    my ( $st, $et ) = ( $self->startTick(), $self->endTick() );

    ## Now we do a simple check to see if the note is a sustain
    my $sustain = 0;
    if ( !$self->purple() && $et - $st >= $min_sust_sep ){
        $sustain = 1;
    } else {
        $et = $st;
    }
    $self->sustain($sustain);

    ## Now we do all of the beat/meas conversions
    my $sb = $song->t2b($st);
    my $eb = $song->t2b($et);
    my $sm = $song->b2m($sb);
    my $em = $song->b2m($eb);

    ## To deal with the qb files, we had to cheat and have non-integer ticks
    ## Now we can move them back to integer ticks
    $st = int ($st + 0.5);
    $et = int ($et + 0.5);
    $self->startTick($st);
    $self->endTick($et);
    $self->lenTick($et-$st);


    $self->startBeat($sb);
    $self->endBeat($eb);
    $self->startMeas($sm);
    $self->endMeas($em);
    $self->lenBeat($eb-$sb);
    $self->lenMeas($em-$sm);

    if ($game =~ m/gh3|ghwt/ && $self->star() && $self->sustain()) {
       $self->baseSpTick($et-$st-120 > 0 ? $et-$st-120 : 0);
       $self->baseSpBeat($et-$st-120 > 0 ? $song->t2b($et-120)-$sb : 0);
    }

    else {
       $self->baseSpTick($self->star() ? $et-$st : 0); 
       $self->baseSpBeat($self->star() ? $eb-$sb : 0); 
    }


    ##my $bss = $sustain ? int ( 25 * $chordsize * ($eb-$sb) + 0.5 + $EPS ) : 0;
    ## $bss = $sustain ? int ( 25 * $chordsize * ($eb-$sb) + $EPS ) : 0;

    my $bns = 50 * $chordsize;
    my $bss = $sustain ? $chordsize * int ( 25 * ($eb-$sb) + $EPS ) : 0;
    if ($game =~ m/gh3|ghwt/) { $bss = $sustain ? int ( 25 * ($eb-$sb) + 0.5 + $EPS ) : 0; }
    my $bts = $bns + $bss;

    my $ghexns = $bns;
    my $ghexss = $sustain ? int ( 25 * $chordsize * ($eb-$sb) + $EPS ) : 0;
    if ($game =~ m/gh3|ghwt/) { $ghexss = $sustain ? int ( 25 * ($eb-$sb) + $EPS ) : 0; }
    my $ghexts = $ghexns+$ghexss;

    my $pns = $bns;
    my $pss = $sustain ? $chordsize * int ( 25 * ($eb-$sb) + 0.5 + $EPS ) : 0;
    if ($game =~ m/gh3|ghwt/) { $pss = $sustain ? int ( 25 * ($eb-$sb) + 0.5 + $EPS ) : 0; }
    my $pts = $pns+$pss;

    my $mult = $self->mult();
    my $multsust = $self->multsust();
    my $mns = $mult * $pns;
    my $mss = $multsust * $pss;
    my $mts = $mns + $mss;

    $self->baseNoteScore($bns);
    $self->baseSustScore($bss);
    $self->baseTotScore($bts);

    $self->GHExNoteScore($ghexns);
    $self->GHExSustScore($ghexss);
    $self->GHExTotScore($ghexts);

    $self->playNoteScore($pns);
    $self->playSustScore($pss);
    $self->playTotScore($pts);

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
    $self->effectiveSPStartTick($st);
    $self->effectiveSPStartBeat($sb);
    $self->effectiveSPStartMeas($sm);
    $self->SpEndTick($st + $self->totSpTick());
    $self->SpEndBeat($sb + $self->totSpBeat());
    $self->SpEndMeas($song->t2m($st + $self->totSpTick));
}

sub notecalc_squeezed_data {
    my ($self,$prev,$song,$squeeze_seconds,$sp_squeeze_seconds,$whammy_delay,$whammy_percent) = @_;

    ## Use the current tempo to estimate the number of squeeze ticks
    my $trial_left    = $self->startTick() - $self->_secs2ticks($squeeze_seconds,$self->currTempo());
    my $trial_right   = $self->startTick() + $self->_secs2ticks($squeeze_seconds,$self->currTempo());

    ## Now if we check if we made an error, and we correct for it.
    if ($trial_left < $self->currTempo()->tick()) {
	unless  ($self->currTempo()->tempo() == $self->prevTempo()->tempo()) {
	    my $pre_tempo_switch_seconds = $self->_ticks2secs($self->startTick() - $self->currTempo()->tick(),$self->currTempo());
	    $trial_left = $self->currTempo()->tick() - $self->_secs2ticks($squeeze_seconds-$pre_tempo_switch_seconds,$self->prevTempo());
	}
    }

    if ($trial_right > $self->nextTempo()->tick()) {
	unless ($self->currTempo()->tempo() == $self->nextTempo()->tempo()) {
	    my $pre_tempo_switch_seconds = $self->_ticks2secs($self->nextTempo()->tick() - $self->startTick(),$self->currTempo());
	    $trial_right = $self->nextTempo()->tick() + $self->_secs2ticks($squeeze_seconds-$pre_tempo_switch_seconds,$self->nextTempo());
	}
    }

    $self->leftStartTick($trial_left);
    $self->leftStartBeat($song->t2b($trial_left));
    $self->leftStartMeas($song->t2m($trial_left));

    $self->rightStartTick($trial_right);
    $self->rightStartBeat($song->t2b($trial_right));
    $self->rightStartMeas($song->t2m($trial_right));

    ## SP Squeezes are a little funnier, since we have a few more fields, and since we have to consider the interference with the previous bit
    if ($self->star() and $self->sustain()) {

        my $trial_sp_left = $self->startTick() - $self->_secs2ticks($sp_squeeze_seconds,$self->currTempo());
        if ($trial_sp_left < $self->currTempo()->tick()) {
            unless ($self->currTempo()->tempo() == $self->prevTempo()->tempo()) {
                my $pre_tempo_switch_seconds = $self->_ticks2secs($self->startTick() - $self->currTempo()->tick(),$self->currTempo());
                $trial_sp_left = $self->currTempo()->tick() - $self->_secs2ticks($sp_squeeze_seconds-$pre_tempo_switch_seconds,$self->prevTempo());
	    }
        }

        if ($self->idx() > 0 and $prev->star() and $prev->sustain() and $prev->SpEndTick() > $trial_sp_left) { $trial_sp_left = $prev->SpEndTick(); }

	## Now we do all the BS with restricted whammying
	if ($whammy_delay > 0) {
	    if ($self->SpEndTick()-$trial_sp_left <= 480 * $whammy_delay) { $trial_sp_left = $self->SpEndTick() - 1e-5;     }
	    else                                                          { $trial_sp_left += 480 * $whammy_delay; }
	}

	if ($whammy_percent < 1.00) {
	    my $curlen = $self->SpEndTick() - $trial_sp_left;
	    my $newlen = $curlen * $whammy_percent;
	    $trial_sp_left = $newlen == 0 ? $self->SpEndTick()-1e-5 : $self->SpEndTick()-$newlen;
	}

        $self->squeezedSpTick($self->startTick()-$trial_sp_left);
        $self->squeezedSpBeat(($self->startTick()-$trial_sp_left)/480.0);
        $self->effectiveSPStartTick($trial_sp_left);
        $self->effectiveSPStartBeat($song->t2b($trial_sp_left));
        $self->effectiveSPStartMeas($song->t2m($trial_sp_left));
	##$self->totSpTick($self->baseSpTick()+$self->squeezedSpTick());
        ##$self->totSpBeat($self->baseSpBeat()+$self->squeezedSpBeat());
	$self->totSpTick($self->SpEndTick()-$trial_sp_left);
	$self->totSpBeat(($self->SpEndTick()-$trial_sp_left)/480.0);
    }
}

sub _secs2ticks {
    my ($self,$secs,$tempo) = @_;
    return int($secs * 1e6 / $tempo->tempo() * 480); 
}

sub _ticks2secs {
    my ($self,$ticks,$tempo) = @_;
    return $ticks / 480 * $tempo->tempo() / 1e6;
}


sub score_note {
    my ($self,$lefttick,$righttick) = @_;
    my ($ns,$ss,$ts) = (0,0,0);
    if ($lefttick <= $self->rightStartTick() and $righttick >= $self->leftStartTick()) {
	$ns += $self->multNoteScore();
	if ($self->sustain()) {
	    my $fraction = 1.00 * ($righttick - $self->startTick()) / ($self->endTick() - $self->startTick());
	    $fraction = 1.00 if $fraction > 1.00; $fraction = 0 if $fraction < 0;
	    $ss = $self->multsust() * int ( $self->playSustScore() * $fraction );
	}
    }

    elsif ($self->sustain() and $lefttick > $self->rightStartTick() and $lefttick < $self->endTick()) {
	my $right_end = $righttick > $self->endTick() ? $self->endTick() : $righttick;
	my $fraction = 1.00 * ($right_end - $lefttick) / ($self->endTick() - $self->startTick());
	$ss = $self->multsust() * int ( $self->playSustScore() * $fraction );
    }
    return ($ns,$ss,$ns+$ss);
}

sub calc_sp_tick {
    my ($self,$righttick) = @_;
    return 0.00 unless $self->sustain() and $self->totSpTick() > 0;
    my $fraction = 1.00 * ( $righttick - $self->SpEndTick() + $self->totSpTick() ) / ( $self->totSpTick() );
    $fraction = 1.00 if $fraction > 1.00; $fraction = 0 if $fraction < 0;
    return int ($fraction * $self->totSpTick());
}

#sub _init {
#    my $self = shift;
#    $self->{mult}           = 0;
#    $self->{multsust}       = 0;
#
#    $self->{baseNoteScore}  = 0;
#    $self->{baseSustScore}  = 0;
#    $self->{baseTotScore}   = 0;
#
#    $self->{noteScore}      = 0;
#    $self->{sustScore}      = 0;
#    $self->{totScore}       = 0;
#
#}
1;

