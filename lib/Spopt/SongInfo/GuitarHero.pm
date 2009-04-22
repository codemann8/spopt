# $Id: GuitarHero.pm,v 1.1 2009-04-22 12:05:20 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHero.pm,v $

package Spopt::SongInfo::GuitarHero;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;
    
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 0, name => "I Love Rock & Roll",                  file => "iloverockandroll.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 0, name => "I Wanna Be Sedated",                  file => "iwannabesedated.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 0, name => "Thunder Kiss 65",                     file => "thunderkiss65.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 0, name => "Smoke On The Water",                  file => "smokeonthewater.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 0, name => "Infected",                            file => "infected.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 1, name => "Iron Man",                            file => "ironman.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 1, name => "More Than A Feeling",                 file => "morethanafeeling.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 1, name => "You Got Another Thing Comin'",        file => "yougotanotherthingcomin.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 1, name => "Take Me Out",                         file => "takemeout.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 1, name => "Sharp Dressed Man",                   file => "sharpdressedman.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 2, name => "Killer Queen",                        file => "killerqueen.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 2, name => "Hey You",                             file => "heyyou.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 2, name => "Stellar",                             file => "stellar.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 2, name => "Heart Full of Black",                 file => "heartfullofblack.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 2, name => "Symphony Of Destruction",             file => "symphofdestruction.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 3, name => "Ziggy Stardust",                      file => "ziggystardust.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 3, name => "Fat Lip",                             file => "fatlip.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 3, name => "Cochise",                             file => "cochise.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 3, name => "Take It Off",                         file => "takeitoff.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 3, name => "Unsung",                              file => "unsung.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 4, name => "Spanish Castle Magic",                file => "spanishcastlemagic.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 4, name => "Higher Ground",                       file => "higherground.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 4, name => "No One Knows",                        file => "nooneknows.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 4, name => "Ace Of Spades",                       file => "aceofspades.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 4, name => "Crossroads",                          file => "crossroads.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 5, name => "Godzilla",                            file => "godzilla.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 5, name => "Texas Flood",                         file => "texasflood.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 5, name => "Frankenstein",                        file => "frankenstein.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 5, name => "Cowboys From Hell",                   file => "cowboysfromhell.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 5, name => "Bark At The Moon",                    file => "barkatthemoon.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Fire It Up",                          file => "fireitup.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Cheat on the Church",                 file => "cheatonthechurch.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Caveman Rejoice",                     file => "cavemanrejoice.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Eureka, I've Found Love",             file => "eureka.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "All of This",                         file => "allofthis.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Behind The Mask",                     file => "behindthemask.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "The Breaking Wheel",                  file => "breakingwheel.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Callout",                             file => "callout.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Decontrol",                           file => "decontrol.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Even Rats",                           file => "evenrats.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Farewell Myth",                       file => "farewellmyth.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Fly On The Wall",                     file => "flyonthewall.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Get Ready 2 Rokk",                    file => "getready2rokk.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Guitar Hero",                         file => "guitarhero.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Hey",                                 file => "hey.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Sail Your Ship By",                   file => "sailyourshipby.mid" };
    push @{$self->{songarr}}, { game => "gh-ps2",      tier => 6, name => "Story of My Love",                    file => "storyofmylove.mid" };
    
    @{$self->{tier_titles}{"gh-ps2"}} = (   "Opening Licks",
                                            "Axe-Grinders",
			                    "Thrash and Burn",
			                    "Return of the Shred",
			                    "Fret Burners",
			                    "Face-Melters",
			                    "Bonus Tracks" );

}

1;

