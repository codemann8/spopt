# $Id: RockBand.pm,v 1.1 2009-04-22 12:05:21 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/RockBand.pm,v $

package Spopt::SongInfo::RockBand;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;
    @{$self->{'songarr'}} = ();
}

1;

