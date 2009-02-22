# $Id: Pwl.pm,v 1.2 2009-02-22 00:52:26 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/Pwl.pm,v $

package Spopt::Pwl;
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
1;
