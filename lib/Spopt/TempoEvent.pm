# $Id: TempoEvent.pm,v 1.2 2009-02-22 00:52:26 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/TempoEvent.pm,v $

package Spopt::TempoEvent;
use strict;

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
