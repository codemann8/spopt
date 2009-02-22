# $Id: Solution.pm,v 1.3 2009-02-22 00:52:26 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/Solution.pm,v $

package Spopt::Solution;
use strict;

sub new    { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop  { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }

sub song        { my $self = shift; return $self->_prop("song",@_);  }
sub score       { my $self = shift; return $self->_prop("score",@_);  }
sub compsp      { my $self = shift; return $self->_prop("compsp",@_);  }
sub optsp       { my $self = shift; return $self->_prop("optsp",@_);  }
sub pathstr     { my $self = shift; return $self->_prop("pathstr",@_);  }
sub activations { my $self = shift; return $self->_prop("activations",@_);  }

sub _init {
    my $self = shift;
    $self->score(0);
    $self->compsp(0);
    $self->optsp(0);
    $self->pathstr("");
    $self->song("");
    $self->activations([]);
}

sub genpathstr {
    my $self = shift;
    my $str = "";
    my $act = $self->activations();
    return "" unless (@$act > 0);
    for my $i (0 .. @$act-1) {
	my $a = $act->[$i];
        my $prefix = $act->[$i]->compressed_flag() ? "C" : "";
	my $num = ($i == 0 ? $a->lastSPidx() + 1 : $a->lastSPidx() - $act->[$i-1]->nextSPidx() + 1);
	my $skip = $a->nextSPidx() - $a->lastSPidx() > 1 ? sprintf("-S\%d",$a->nextSPidx()-$a->lastSPidx()-1) : "";
	if ($str) { $str .= "-${prefix}${num}$skip"; }
	else      { $str .= "${prefix}${num}$skip";  }
    }
    $self->pathstr($str);
}
    

sub genpathstr_final {
    my $self = shift;
    $self->genpathstr();
    my $act = $self->activations();
    return unless @$act > 0;
    my $song = $act->[0]->song();
    my $spa = $song->sparr();
    my $numsp = scalar @$spa;
    return if $act->[-1]->nextSPidx() == $numsp;
    my $str = $self->pathstr();
    $str .= sprintf "-ES\%d", $numsp - $act->[-1]->nextSPidx();
    $self->pathstr($str);
}

sub sprintme {
    my $self = shift;
    my $song = $self->song();
    my $mf = $song->midifile();
    my $filename = $mf->file();
    $filename =~ s/^.*\///;
    my ($base,$fours,$fives,$perfect) = $song->estimate_scores();
    my $pathstr = $self->pathstr();
    my $score = $self->score();
    my $act = $self->activations();

    my $out  = "";
    $out .= sprintf "File:                    \%s\n", $filename;
    $out .= sprintf "Solution Path:           \%s\n", $pathstr;
    $out .= sprintf "Estimated Base score     %6d\n", $base;
    $out .= sprintf "Estimated 4* cutoff      %6d\n", $fours;
    $out .= sprintf "Estimated 5* cutoff      %6d\n", $fives;
    $out .= sprintf "Estimated Perfect w/o SP %6d\n", $perfect;
    $out .= sprintf "Estimated SP Score       %6d\n", $score;
    $out .= sprintf "Estimated Total Score    %6d\n", $perfect+$score;
    $out .= sprintf "Activations:\n";
    for my $i (0 .. @$act-1) {
	my $actstr = $act->[$i]->sprintme();
	$out .= sprintf(" #\%d $actstr\n", $i+1);
    }
    return $out;
}

sub totscore {
    my $self = shift;
    my $song = $self->song();
    my ($base,$fours,$fives,$perfect) = $song->estimate_scores();
    return $perfect + $self->score();
}

1;
