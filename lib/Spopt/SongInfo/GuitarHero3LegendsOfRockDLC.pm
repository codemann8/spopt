# $Id: GuitarHero3LegendsOfRockDLC.pm,v 1.1 2009-04-22 12:05:20 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHero3LegendsOfRockDLC.pm,v $

package Spopt::SongInfo::GuitarHero3LegendsOfRockDLC;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;

    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'All My Life',                     file => 'dlc3.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Pretender',                   file => 'dlc4.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'This is a call',                  file => 'dlc5.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Slither',                         file => 'dlc6.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'She Builds Quick Machines',       file => 'dlc7.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Messages',                        file => 'dlc8.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Tom Morello Guitar Battle',       file => 'dlc1.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Slash Guitar Battle',             file => 'dlc2.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Devil Went Down To Georgia',  file => 'dlc17.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Carcinogen Crush',                file => 'dlc14.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Tina',                            file => 'dlc15.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Putting Holes In Happiness',      file => 'dlc16.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Halo Theme MJOLNIR Mix',          file => 'dlc19.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Ernten Was Wir Säen',             file => 'dlc26.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'So Payaso',                       file => 'dlc18.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Antisocial',                      file => 'dlc9.mid.qb.xen'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Pretty Handsome Awkward',         file => 'dlc11.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'No More Sorrow',                  file => 'dlc12.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Sleeping Giant',                  file => 'dlc13.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'We Three Kings',                  file => 'dlc36.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Any Way You Want It',             file => 'dlc10.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Jukebox Hero',                    file => 'dlc24.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Peace Of Mind',                   file => 'dlc25.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Dream On',                        file => 'dlc37.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Excuse Me Mr.',                   file => 'dlc29.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Don\'t Speak',                    file => 'dlc30.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Sunday Morning',                  file => 'dlc31.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Arsonist',                    file => 'dlc27.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Hole in the Earth',               file => 'dlc28.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Almost Easy',                     file => 'dlc32.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Famous for Nothing',              file => 'dlc38.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => '(F)lannigan\'s Ball',             file => 'dlc39.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Johnny, I Hardly Knew Ya',        file => 'dlc40.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Nine Lives',                      file => 'dlc49.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Photograph (Live)',               file => 'dlc50.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Rock of Ages (Live)',             file => 'dlc51.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Exo-Politics',                    file => 'dlc33.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Stockholm Syndrome',              file => 'dlc34.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Super Massive Black Hole',        file => 'dlc35.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Stay Clean',                      file => 'dlc45.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => '(We Are) The Road Crew',          file => 'dlc46.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Motörhead',                       file => 'dlc47.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Shoot the Runner',                file => 'dlc68.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Problems (Live at Brixton)',      file => 'dlc69.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'I Predict a Riot',                file => 'dlc70.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Violet Hill',                     file => 'dlc71.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Yellow',                          file => 'dlc72.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'God Put A Smile Upon Your Face',  file => 'dlc73.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'I Am Murloc',                     file => 'dlc75.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Top Gun Anthem',                  file => 'dlc74.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Surfing With The Alien',          file => 'dlc62.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'For the Love of God',             file => 'dlc63.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Soothsayer',                      file => 'dlc66.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Heroes of Our Time',              file => 'dlc80.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Operation Ground and Pound',      file => 'dlc81.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Revolution Deathsquad',           file => 'dlc82.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'My Apocalypse',                   file => 'dlc83.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'All Nightmare Long',              file => 'dlc84.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'That Was Just Your Life',         file => 'dlc85.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Day That Never Comes',        file => 'dlc86.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Broken, Beat & Scarred',          file => 'dlc87.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Judas Kiss',                  file => 'dlc88.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The End of the Line',             file => 'dlc89.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Unforgiven III',              file => 'dlc90.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Cyanide',                         file => 'dlc91.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Suicide & Redemption J.H.',       file => 'dlc92.mid.qb.xen' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Suicide & Redemption K.H.',       file => 'dlc93.mid.qb.xen' };

    @{$self->{tier_titles}{"gh3-dlc"}} = (     "Starting Out Small",
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

