# $Id: GuitarHeroMetallica.pm,v 1.3 2009-04-28 08:34:48 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/BandHero.pm,v $

package Spopt::SongInfo::BandHero;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;

    @{$self->{'tier_titles'}{'bh'}} = (
        'The Forum',
        'Tushino Air Field',
        'Metallica at Tushino',
        'Hammersmith Apollo',
        'Damaged Justice Tour',
        'The Meadowlands',
        'Donnington Park',
        'The Ice Cave',
        'The Stone Nightclub',
    );

	#codemann8 - TODO:Incomplete
    @{$self->{'songarr'}} = (
        {
        game   => 'bh',
        tier   => 1,
        name   => q{ABC},
        artist => q{Van Halen},
        year   => 2008,
        file   => 'abc.mid.qb',
        },
    );
}

1;

