# $Id: Activation.pm,v 1.2 2009-02-22 00:52:26 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/Activation.pm,v $

package Spopt::Activation;
use strict;

sub new    { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; return $self;}
sub _prop  { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }

sub song                { my $self = shift; return $self->_prop("song",@_);  }

sub compulsorySP        { my $self = shift; return $self->_prop("compulsorySP",@_);  }
sub optionalSPAvailable { my $self = shift; return $self->_prop("optionalSPAvailable",@_);  }
sub optionalSPUsed      { my $self = shift; return $self->_prop("optionalSPUsed",@_);  }
sub compressed_flag     { my $self = shift; return $self->_prop("compressed",@_);  }
sub lastSPidx           { my $self = shift; return $self->_prop("lastSPidx",@_);  }

sub startTick           { my $self = shift; return $self->_prop("startTick",@_);  }
sub endTick             { my $self = shift; return $self->_prop("endTick",@_);  }
sub leftNoteIdxLimit    { my $self = shift; return $self->_prop("leftNoteIdxLimit",@_);  }
sub rightNoteIdxLimit   { my $self = shift; return $self->_prop("rightNoteIdxLimit",@_);  }

sub nextSPidx           { my $self = shift; return $self->_prop("nextSPidx",@_);  }
sub noteScore           { my $self = shift; return $self->_prop("noteScore",@_);  }
sub sustScore           { my $self = shift; return $self->_prop("sustScore",@_);  }
sub totScore            { my $self = shift; return $self->_prop("totScore",@_);  }
sub startNoteIdx        { my $self = shift; return $self->_prop("startNoteIdx",@_);  }
sub endNoteIdx          { my $self = shift; return $self->_prop("endNoteIdx",@_);  }
sub displayLeftTick     { my $self = shift; return $self->_prop("displayLeftTick",@_);  }
sub displayRightTick    { my $self = shift; return $self->_prop("displayRightTick",@_);  }
sub displayLeftStr      { my $self = shift; return $self->_prop("displayLeftStr",@_);  }
sub displayRightStr     { my $self = shift; return $self->_prop("displayRightStr",@_);  }

sub sprintme {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();

    my $startmeas = $song->t2m($self->displayLeftTick());
    my $endmeas   = $song->t2m($self->displayRightTick());

    my $realstartmeas = $song->t2m($self->startTick());
    my $realendmeas   = $song->t2m($self->endTick());

    my $si = $self->startNoteIdx();
    my $ei = $self->endNoteIdx();
    my $ss = $self->displayLeftStr();
    my $es = $self->displayRightStr();

    my $out = sprintf "From meas %8.4f \%-10s to meas %8.4f %-10s  (%8.4f-%8.4f) Score: \%5d   (%4.1f+%4.1f)*200",
                                                                                           $startmeas, "$ss",
                                                                                           $endmeas,   "$es",
											   $realstartmeas,
											   $realendmeas,
                                                                                           $self->totScore(),
                                                                                           $self->noteScore() / 200.0,
                                                                                           $self->sustScore() / 200.0;

    return $out;
}

sub sprintme_debug {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();

    my $startmeas1 = $song->t2m($self->startTick());
    my $endmeas1   = $song->t2m($self->endTick());

    my $startmeas = $song->t2m($self->displayLeftTick());
    my $endmeas   = $song->t2m($self->displayRightTick());

    my $si = $self->startNoteIdx();
    my $ei = $self->endNoteIdx();
    my $ss = $self->displayLeftStr();
    my $es = $self->displayRightStr();

    my $out = sprintf "%8.4f-%8.4f %3d-%3d Score: \%5d (%4.1f+%4.1f)*200", $startmeas1, $endmeas1, $si, $ei,
                                                                                           $self->totScore(),
                                                                                           $self->noteScore() / 200.0,
                                                                                           $self->sustScore() / 200.0;
}


sub scoreMe {
    my $self = shift;
    my $song = $self->song();
    my $na = $song->notearr();
    my $spa = $song->sparr();

    my $nextSPidx = $self->lastSPidx() + 1;
    while ( $nextSPidx < @$spa and $self->rightNoteIdxLimit() >= $spa->[$nextSPidx][0] and $self->endTick() > $na->[$spa->[$nextSPidx][0]]->leftStartTick()-1 )  { $nextSPidx++; }
    $self->nextSPidx($nextSPidx);

    my $lastnote = @$na-1;

    my $startTick = $self->startTick();
    my $endTick   = $self->endTick();
    my $left_note_idx  = $song->find_note_idx_after_squeezed($startTick);
    my $right_note_idx = $song->find_note_idx_before_squeezed($endTick);

    my ($illegal,$dum1,$dum2) = (0,0,0);
    if ($left_note_idx >=0 and $right_note_idx >=0) { 

	$right_note_idx  = $lastnote if $right_note_idx > $lastnote;
	$left_note_idx   = $self->leftNoteIdxLimit()  if $left_note_idx  < $self->leftNoteIdxLimit();
	$right_note_idx  = $self->rightNoteIdxLimit() if $right_note_idx > $self->rightNoteIdxLimit();

	## We allow a slight exception to the limit rule for sustains
        if ($left_note_idx > 0 and $na->[$left_note_idx-1]->sustain() and $na->[$left_note_idx-1]->endTick() > $startTick) { $left_note_idx--; }

	## We deal with the consequences of our exception here
	if ($left_note_idx < $self->leftNoteIdxLimit()) {
	   ($illegal,$dum1,$dum2) = $na->[$left_note_idx]->score_note($startTick,$endTick);  
        }

	if  ($right_note_idx < $left_note_idx)  { $self->_invalid_score();} 

	elsif  ($right_note_idx == $left_note_idx) {
	    my ($ns,$ss,$ts) = $na->[$left_note_idx]->score_note($startTick,$endTick); 
	    $self->totScore($ts-$illegal);
	    $self->noteScore($ns-$illegal);
	    $self->sustScore($ss);
	    $self->startNoteIdx($left_note_idx);
	    $self->endNoteIdx($right_note_idx);
	}

	elsif ($right_note_idx - $left_note_idx < 1 + 1e-7) { 
	    my ($ns1,$ss1,$ts1) = $na->[$left_note_idx]->score_note($startTick,$endTick); 
	    my ($ns2,$ss2,$ts2) = $na->[$right_note_idx]->score_note($startTick,$endTick); 
	    $self->totScore($ts1+$ts2-$illegal);
	    $self->noteScore($ns1+$ns2-$illegal);
	    $self->sustScore($ss1+$ss2);
	    $self->startNoteIdx($left_note_idx);
	    $self->endNoteIdx($right_note_idx);
	}

	else {
	    my ($ns1,$ss1,$ts1) = $na->[$left_note_idx]->score_note($startTick,$endTick); 
	    my ($ns2,$ss2,$ts2) = $na->[$right_note_idx]->score_note($startTick,$endTick); 
	    my ($ns3,$ss3,$ts3) = $song->score_range($left_note_idx+1,$right_note_idx-1);
	    $self->totScore($ts1+$ts2+$ts3-$illegal);
	    $self->noteScore($ns1+$ns2+$ns3-$illegal);
	    $self->sustScore($ss1+$ss2+$ss3);
	    $self->startNoteIdx($left_note_idx);
	    $self->endNoteIdx($right_note_idx);
	}
    }

    else { $self->_invalid_score(); }
    $self->displayLeftTick($self->startTick());
    $self->displayRightTick($self->endTick());



    my $lnotestr = $na->[$left_note_idx]->notestr();
    my $rnotestr = $na->[$right_note_idx]->notestr();

    if ($illegal) {
	$self->displayLeftTick($na->[$left_note_idx]->rightStartTick()+2);
	$self->displayLeftStr("($lnotestr sust)");
    }

    elsif ( $startTick < $na->[$left_note_idx]->rightStartTick() ) {
	$self->displayLeftTick($na->[$left_note_idx]->startTick());
	$self->displayLeftStr("($lnotestr note)");
    }

    else {
	$self->displayLeftStr("($lnotestr sust)");
    }


    
    if (not $na->[$right_note_idx]->sustain()) {
	$self->displayRightTick($na->[$right_note_idx]->startTick());
	$self->displayRightStr("($rnotestr note)");
    }

    elsif ($endTick < $na->[$right_note_idx]->startTick()) {
	$self->displayRightTick($na->[$right_note_idx]->startTick());
	$self->displayRightStr("($rnotestr note)");
    }

    else {
	$self->displayRightStr("($rnotestr sust)");
    }

}

sub _invalid_score {
    my $self = shift;
    $self->totScore(-2);
    $self->noteScore(-2);
    $self->sustScore(-2);
    $self->startNoteIdx(-1);
    $self->endNoteIdx(-1);
}

1;
