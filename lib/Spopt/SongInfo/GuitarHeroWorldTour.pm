# $Id: GuitarHeroWorldTour.pm,v 1.1 2009-04-22 12:05:21 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHeroWorldTour.pm,v $

package Spopt::SongInfo::GuitarHeroWorldTour;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;

    @{$self->{tier_titles}{'ghwt'}} = (
        'USA - Psh Psi Kappa',
        'Sweden - Wilted Orchid',
        'Poland - Bone Church',
        'Hong Kong - Pang Tang Bay',
        'Los Angeles - Amoeba Records',
        'USA - Tool',
        'Lousiana - Swamp Shack',
        'The Pacific - Rock Brigade',
        'Kentucky - Strutter\'s Farm',
        'Los Angeles - House of Blues',
        'Tahiti - Ted\'s Tiki Hut',
        'England - Will Heilm\'s Keep',
        'Canada - Recording Studio',
        'San Francisco - AT&T Park',
        'Australia - Tesla\'s Coil',
        'Germany - Ozzfest',
        'New York - Times Square',
        'Asgard - Sunno\'s Chariot',
    );

    push @{$self->{songarr}}, { game => 'ghwt', tier => 0, name => 'Livin\' On A Prayer', file => 'livingonaprayer.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 0, name => 'About A Girl (Unplugged)', file => 'aboutagirl.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 0, name => 'Mountain Song', file => 'mountainsong.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 1, name => 'Beautiful Disaster', file => 'beautifuldisaster.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 1, name => 'Obstacle 1', file => 'obstacle1.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 1, name => 'The One I Love', file => 'theoneilove.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 2, name => 'Some Might Say', file => 'somemightsay.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 2, name => 'Today', file => 'today.mid.qb' };
    # push @{$self->{songarr}}, { game => 'ghwt', tier => 2, name => 'today_perf2.mid.qb', file => 'today_perf2.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 2, name => 'What I\'ve Done', file => 'whativedone.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 3, name => 'Band On The Run', file => 'bandontherun.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 3, name => 'You\'re Gonna Say Yeah', file => 'youregonnasayyeah.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 3, name => 'Up Around The Bend', file => 'uparoundthebend.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 3, name => 'No Sleep Till Brooklyn', file => 'nosleeptillbrooklyn.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 4, name => 'The Joker', file => 'thejoker.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 4, name => 'Freak On A Leash', file => 'freakonaleash.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 4, name => 'Misery Business', file => 'miserybusiness.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 4, name => 'Hotel California', file => 'hotelcalifornia.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 5, name => 'Parabola', file => 'parabola.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 5, name => 'Schism', file => 'schism.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 5, name => 'Vicarious', file => 'vicarious.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Eye Of The Tiger', file => 'eyeofthetiger.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Spiderwebs', file => 'spiderwebs.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'One Way Or Another', file => 'onewayoranother.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Do It Again', file => 'doitagain.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Zakk Wylde Guitar Duel', file => 'bosszakk.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Stillborn', file => 'stillborn.mid.qb' };
    # push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'stillborn_perf2.mid.qb', file => 'stillborn_perf2.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'The Middle', file => 'themiddle.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'Hey Man Nice Shot', file => 'heymanniceshot.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'Feel The Pain', file => 'feelthepain.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'Dammit', file => 'dammit.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'Everlong', file => 'everlong.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Heartbreaker', file => 'heartbreaker.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'American Woman', file => 'americanwoman.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Ramblin\' Man', file => 'ramblinman.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Go Your Own Way', file => 'goyourownway.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Ted Nugent Guitar Duel', file => 'bossted.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Stranglehold', file => 'stranglehold.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'L\'Via L\'Viaquez', file => 'lvialviaquez.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'Kick Out The Jams', file => 'kickoutthejams.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'Santeria', file => 'santeria.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'On The Road Again (Live)', file => 'ontheroadagain.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'Love Me Two Times', file => 'lovemetwotimes.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'Monsoon', file => 'monsoon.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'Aggro', file => 'aggro.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'Rooftops (A Liberation Broadcast)', file => 'rooftops.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'Good God', file => 'goodgod.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'One Armed Scissor', file => 'onearmedscissor.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'The Kill', file => 'thekill.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'Shiver', file => 'shiver.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'Rebel Yell', file => 'rebelyell.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'Demolition Man (Live)', file => 'demolitionman.mid.qb' };
    # push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'demolitionman_perf2.mid.qb', file => 'demolitionman_perf2.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'Beat It', file => 'beatit.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Lazy Eye', file => 'lazyeye.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Too Much, Too Young, Too Fast', file => 'toomuchtooyoung.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Float On', file => 'floaton.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Nuvole E Lenzuola', file => 'nuvole.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Pretty Vacant', file => 'prettyvacant.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Are You Gonna Go My Way', file => 'areyougonnagomyway.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Sweet Home Alabama (Live)', file => 'sweethomealabama.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Assassin', file => 'assassin.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Escuela de Calor', file => 'escueladecalor.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'The Wind Cries Mary', file => 'windcriesmary.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Purple Haze (Live)', file => 'purplehaze.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'Toy Boy', file => 'toyboy.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'Hail To The Freaks', file => 'hailtothefreaks.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'VinterNoll2', file => 'vinternoll2.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'Hollywood Nights', file => 'hollywoodnights.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'Soul Doubt', file => 'souldoubt.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Love Removal Machine', file => 'loveremovalmachine.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Our Truth', file => 'ourtruth.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Antisocial', file => 'antisocial.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Prisoner Of Society', file => 'prisonerofsociety.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Mr. Crowley', file => 'mrcrowley.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Crazy Train', file => 'crazytrain.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Re-Education (Through Labor)', file => 'reedthroughlabor.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'La Bamba', file => 'labamba.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Scream Aim Fire', file => 'screamaimfire.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Overkill', file => 'overkill.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Trapped Under Ice', file => 'trappedunderice.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'B.Y.O.B.', file => 'byob.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Hot For Teacher', file => 'hotforteacher.mid.qb' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Love Spreads', file => 'lovespreads.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Never Too Late', file => 'nevertoolate.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Weapon Of Choice', file => 'weaponofchoice.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Pull Me Under', file => 'pullmeunder.mid.qb' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Satch Boogie', file => 'satchboogie.mid.qb' };
}

1;

