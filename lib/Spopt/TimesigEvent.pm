# $Id: TimesigEvent.pm,v 1.2 2009-02-22 00:52:26 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/TimesigEvent.pm,v $

package Spopt::TimesigEvent;
use strict;

sub new    { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop  { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub tick   { my $self = shift; return $self->_prop("tick",@_);  }
sub bpm    { my $self = shift; return $self->_prop("bpm",@_); }

sub _init {
    my $self = shift;
    $self->tick(0);
    $self->bpm(0);
}

sub populateFromMidiEvent {
    my ($self,$me) = @_;
    $self->tick($me->tick());
    $self->bpm($me->argint1());
}

1;
