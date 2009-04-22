# $Id: GuitarHero2DLC.pm,v 1.1 2009-04-22 12:05:20 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHero2DLC.pm,v $

package Spopt::SongInfo::GuitarHero2DLC;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Ace Of Spades",                       file => "aceofspades.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Bark At The Moon",                    file => "barkatthemoon.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Hey You",                             file => "heyyou.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Frankenstein",                        file => "frankenstein.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Killer Queen",                        file => "killerqueen.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Take It Off",                         file => "takeitoff.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Higher Ground",                       file => "higherground.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Infected",                            file => "infected.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Stellar",                             file => "stellar.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "I Wanna Be Sedated",                  file => "iwannabesedated.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Smoke On the Water",                  file => "smokeonthewater.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "You've Got Another Thing Comin'",     file => "yougotanotherthingcomin.mid" };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Famous Last Words",                   file => "famouslastwords.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Teenagers",                           file => "teenagers.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "This Is How I Disappear",             file => "thisishowidisappear.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Bury The Hatchet",                    file => "burythehatchet.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Detonation",                          file => "detonation.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Ex's And Oh's",                       file => "exsandohs.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Sin Documentos",                      file => "sindocumentos.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Sept",                                file => "sept.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Exile",                               file => "exile.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "Memories Of The Grove",               file => "memoriesofthe.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "State of Massachusetts",              file => "stateofmass.mid"  };
    push @{$self->{songarr}}, { game => "gh2-dlc",    tier => 9, name => "You Should Be Ashamed Of Myself",     file => "youshouldbeashamed.mid" };
    
    @{$self->{tier_titles}{"gh2-dlc"}} = ( "Opening Licks",
                                            "Amp-Warmers",
			                    "String Snappers",
			                    "Thrash and Burn",
			                    "Return of the Shred",
			                    "Relentless Riffs",
			                    "Furious Fretwork",
			                    "Face-Melters",
			                    "Bonus Tracks",
			                    "DLC" );

}

1;

