# $Id: MidiEvent.pm,v 1.3 2009-02-22 00:52:26 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/MidiEvent.pm,v $

package Spopt::MidiEvent;
use strict;

sub new        { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop      { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }

sub track {
    if (@_==2) { $_[0]->{_track}=$_[1]; }
    return $_[0]->{_track};
}

sub tick {
    if (@_==2) { $_[0]->{_tick}=$_[1]; }
    return $_[0]->{_tick};
}

sub eventstr {
    if (@_==2) { $_[0]->{_eventstr}=$_[1]; }
    return $_[0]->{_eventstr};
}

sub argstr {
    if (@_==2) { $_[0]->{_argstr}=$_[1]; }
    return $_[0]->{_argstr};
}

sub argint1 {
    if (@_==2) { $_[0]->{_argint1}=$_[1]; }
    return $_[0]->{_argint1};
}

sub argint2 {
    if (@_==2) { $_[0]->{_argint2}=$_[1]; }
    return $_[0]->{_argint2};
}

sub argint3 {
    if (@_==2) { $_[0]->{_argint3}=$_[1]; }
    return $_[0]->{_argint3};
}

sub argint4 {
    if (@_==2) { $_[0]->{_argint4}=$_[1]; }
    return $_[0]->{_argint4};
}

sub _init {
    my $self = shift;
    %$self = ("_track" => 0, "_tick" => 0, "_eventstr" => "", "_argstr" => "", "_argint1" => 0, "_argint2" => 0, "_argint3" => 0, "_argint4" => 0);
}
1;
