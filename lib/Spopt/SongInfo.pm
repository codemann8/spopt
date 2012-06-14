# $Id: SongInfo.pm,v 1.1 2009-04-22 12:05:20 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo.pm,v $

use strict;
package Spopt::SongInfo;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;
    
    my @gameList = (
        'GuitarHero',
        'GuitarHero2',
        'GuitarHero2DLC',
        'GuitarHero3LegendsOfRock',
        'GuitarHero3LegendsOfRockDLC',
        'GuitarHeroAerosmith',
        'GuitarHeroEncoreRocksThe80s',
        'GuitarHeroOnTour',
        'GuitarHeroOnTourDecades',
        'GuitarHeroWorldTour',
        'GuitarHeroWorldTourDLC',
        'GuitarHeroMetallica',
		'GuitarHeroSmashHits',
		'GuitarHero5',
		'GuitarHeroVanHalen',
		'BandHero',
        'RockBand',
        'RockBand2',
        'RockBandACDCLive',
        'RockBandDLC',
    );

    for my $game ( @gameList ) {
        my $module = "Spopt::SongInfo::$game";
        my $object = eval "require $module; return $module->new()";
        if ($@) { die $@,"\n"; };
        push @{$self->{'songarr'}}, $object->get_songarr();
    }
}

1;

