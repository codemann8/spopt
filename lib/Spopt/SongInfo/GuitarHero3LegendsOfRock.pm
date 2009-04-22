# $Id: GuitarHero3LegendsOfRock.pm,v 1.1 2009-04-22 12:05:20 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHero3LegendsOfRock.pm,v $

package Spopt::SongInfo::GuitarHero3LegendsOfRock;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;

    push @{$self->{songarr}}, { game => "gh3-x360", tier => 0,  name => "Slow Ride",                       file => "slowride.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 0,  name => "Talk Dirty to Me",                file => "talkdirtytome.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 0,  name => "Hit Me WIth Your Best Shot",      file => "hitmewithyourbestshot.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 0,  name => "Story of My Life",                file => "storyofmylife.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 0,  name => "Rock and Roll All Nite",          file => "rocknrollallnite.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 1,  name => "Mississippi Queen",               file => "mississippiqueen.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 1,  name => "School's Out",                    file => "schoolsout.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 1,  name => "Sunshine of Your Love",           file => "sunshineofyourlove.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 1,  name => "Barracuda",                       file => "barracuda.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 1,  name => "Bulls on Parade",                 file => "bullsonparade.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 2,  name => "When You Were Young",             file => "whenyouwereyoung.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 2,  name => "Miss Murder",                     file => "missmurder.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 2,  name => "The Seeker",                      file => "theseeker.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 2,  name => "Lay Down",                        file => "laydown.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 2,  name => "Paint It Black",                  file => "paintitblack.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 3,  name => "Paranoid",                        file => "paranoid.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 3,  name => "Anarchy in the U.K.",             file => "anarchyintheuk.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 3,  name => "Kool Thing",                      file => "koolthing.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 3,  name => "My Name is Jonas",                file => "mynameisjonas.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 3,  name => "Even Flow",                       file => "evenflow.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 4,  name => "Holiday in Cambodia",             file => "holidayincambodia.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 4,  name => "Rock You Like a Hurricane",       file => "rockulikeahurricane.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 4,  name => "Same Old Song and Dance",         file => "sameoldsonganddance.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 4,  name => "La Grange",                       file => "lagrange.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 4,  name => "Welcome to the Jungle",           file => "welcometothejungle.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 5,  name => "Black Magic Woman",               file => "blackmagicwoman.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 5,  name => "Cherub Rock",                     file => "cherubrock.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 5,  name => "Black Sunshine",                  file => "blacksunshine.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 5,  name => "The Metal",                       file => "themetal.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 5,  name => "Pride and Joy",                   file => "pridenjoy.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 6,  name => "Before I Forget",                 file => "beforeiforget.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 6,  name => "Stricken",                        file => "stricken.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 6,  name => "3's & 7's",                       file => "threesandsevens.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 6,  name => "Knights of Cydonia",              file => "knightsofcydonia.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 6,  name => "Cult of Personality",             file => "cultofpersonality.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 7,  name => "Raining Blood",                   file => "rainingblood.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 7,  name => "Cliffs of Dover",                 file => "cliffsofdover.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 7,  name => "The Number of the Beast",         file => "numberofthebeast.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 7,  name => "One",                             file => "one.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 8,  name => "Sabotage",                        file => "sabotage.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 8,  name => "Reptilia",                        file => "reptilia.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 8,  name => "Suck My Kiss",                    file => "suckmykiss.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 8,  name => "Cities on Flame with Rock and Roll",  file => "citiesonflame.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 8,  name => "Helicopter",                      file => "helicopter.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 8,  name => "Monsters",                        file => "monsters.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Avalancha",                       file => "avalancha.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "In the Belly of a Shark",         file => "bellyofashark.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Can't Be Saved",                  file => "cantbesaved.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Closer",                          file => "closer.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Don't Hold Back",                 file => "dontholdback.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Down n' Dirty",                   file => "downndirty.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "F.C.P.R.E.M.I.X.",                file => "fcpremix.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Generation Rock",                 file => "generationrock.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Go That Far",                     file => "gothatfar.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Hier Kommt Alex",                 file => "hierkommtalex.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "I'm in the Band",                 file => "imintheband.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Impulse",                         file => "impulse.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "In Love",                         file => "inlove.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Mauvais Garcon",                  file => "mauvaisgarcon.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Metal Heavy Lady",                file => "metalheavylady.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Minus Celcius",                   file => "minuscelsius.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "My Curse",                        file => "mycurse.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Nothing for Me Here",             file => "nothingformehere.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Prayer of the Refugee",           file => "prayeroftherefugee.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Radio Song",                      file => "radiosong.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Ruby",                            file => "ruby.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "She Bangs the Drums",             file => "shebangsadrum.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Take This Life",                  file => "takethislife.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "The Way It Ends",                 file => "thewayitends.mid.qb.xen" };
    push @{$self->{songarr}}, { game => "gh3-x360", tier => 9,  name => "Through the Fire and Flames",     file => "thrufireandflames.mid.qb.xen" };

    @{$self->{tier_titles}{"gh3-x360"}} = (     "Starting Out Small",
                                               "Your First Real Gig",
                                               "Making the Video",
                                               "European Invasion",
                                               "Bighouse Blues",
                                               "The Hottest Band on Earth",
                                               "Live in Japan",
                                               "Battle for Your Soul",
                                               "Co-op Encores",
                                               "Bonus Tracks",
                                               "DLC" );

}

1;

