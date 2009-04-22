# $Id: GuitarHeroAerosmith.pm,v 1.1 2009-04-22 12:05:20 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHeroAerosmith.pm,v $

package Spopt::SongInfo::GuitarHeroAerosmith;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;

    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'Dream Police',                  file => 'dreampolice.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'All the Young Dudes',           file => 'alltheyoungdudes.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'Make It',                       file => 'makeit.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'Uncle Salty',                   file => 'unclesalty.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'Draw The Line',                 file => 'drawtheline.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'I Hate Myself For Loving You',  file => 'ihatemyselfforlovingyou.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'All Day and All of the Night',  file => 'alldayandallofthenight.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'No Surprize',                   file => 'nosurprize.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'Movin\' Out',                   file => 'movinout.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'Sweet Emotion',                 file => 'sweetemotion.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Complete Control',              file => 'completecontrol.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Personality Crisis',            file => 'personalitycrisis.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Livin\' on the Edge',           file => 'livinontheedge.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Rag Doll',                      file => 'ragdoll.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Love In An Elevator',           file => 'loveinanelevator.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'She Sells Sanctuary',           file => 'shesellssanctuary.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'King of Rock',                  file => 'kingofrock.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'Nobody\'s Fault',               file => 'nobodysfault.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'Bright Light Fright',           file => 'brightlightfright.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'Walk This Way (Run DMC)',       file => 'walkthiswayrundmc.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Hard to Handle',                file => 'hardtohandle.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Always On The Run',             file => 'alwaysontherun.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Back In The Saddle',            file => 'backinthesaddle.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Beyond Beautiful',              file => 'beyondbeautiful.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Dream On',                      file => 'dreamon.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Cat Scratch Fever',             file => 'catscratchfever.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Sex Type Thing',                file => 'sextypething.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Mama Kin',                      file => 'mamakin.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Toys in the Attic',             file => 'toysintheattic.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Train Kept a Rollin\'',         file => 'trainkeptarollin.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Walk This Way',                 file => 'walkthisway.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Rats In The Cellar',            file => 'ratsinthecellar.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Kings and Queens',              file => 'kingsandqueens.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Combination',                   file => 'combination.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Let The Music Do The Talking',  file => 'letthemusicdothetalking.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Shakin\' My Cage',              file => 'shakinmycage.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Pink',                          file => 'pink.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Talk Talkin\'',                 file => 'talktalking.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Mercy',                         file => 'mercy.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Pandora\'s Box',                file => 'pandorasbox.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Joe Perry Guitar Battle',       file => 'joeperryguitarbattle.mid.qb.xen' };

    @{$self->{tier_titles}{"gh3-aerosmith"}} = (     "Getting The Band Together",
                                                     "First Taste Of Success",
                                                     "The Triumphant Return",
                                                     "International Superstars",
                                                     "The Great American Band",
                                                     "Rock \'N Roll Legends",
                                                     "The Vault" );

}

1;

