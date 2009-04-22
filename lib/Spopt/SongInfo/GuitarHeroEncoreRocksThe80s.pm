# $Id: GuitarHeroEncoreRocksThe80s.pm,v 1.1 2009-04-22 12:05:20 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHeroEncoreRocksThe80s.pm,v $

package Spopt::SongInfo::GuitarHeroEncoreRocksThe80s;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;
    
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 0, name => "(Bang Your Head) Metal Health",   file => "bangyourhead.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 0, name => "We Got The Beat",                 file => "wegotthebeat.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 0, name => "I Ran (So Far Away)",             file => "iran.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 0, name => "Balls To The Wall",               file => "ballstothewall.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 0, name => "18 And Life",                     file => "18andlife.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 1, name => "No One Like You",                 file => "noonelikeyou.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 1, name => "Shakin'",                         file => "shakin.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 1, name => "Heat Of The Moment",              file => "heatofthemoment.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 1, name => "Radar Love",                      file => "radarlove.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 1, name => "Because, It's Midnite",           file => "becauseitsmidnite.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 2, name => "Holy Diver",                      file => "holydiver.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 2, name => "Turning Japanese",                file => "turningjapanese.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 2, name => "Hold On Loosely",                 file => "holdonloosely.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 2, name => "The Warrior",                     file => "thewarrior.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 2, name => "I Wanna Rock",                    file => "iwannarock.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 3, name => "What I Like About You",           file => "whatilikeaboutyou.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 3, name => "Synchronicity II",                file => "synchronicity2.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 3, name => "Ballroom Blitz",                  file => "ballroomblitz.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 3, name => "Only A Lad",                      file => "onlyalad.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 3, name => "Round And Round",                 file => "roundandround.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 4, name => "Ain't Nothin But A Good Time",    file => "aintnothinbut.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 4, name => "Lonely Is The Night",             file => "lonelyisthenight.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 4, name => "Bathroom Wall",                   file => "bathroomwall.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 4, name => "Los Angeles",                     file => "losangeles.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 4, name => "Wrathchild",                      file => "wrathchild.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 5, name => "Electric Eye",                    file => "electriceye.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 5, name => "Police Truck",                    file => "policetruck.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 5, name => "Seventeen",                       file => "seventeen.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 5, name => "Caught In A Mosh",                file => "caughtinamosh.mid" };
    push @{$self->{songarr}}, { game => "ghrt80s-ps2", tier => 5, name => "Play With Me",                    file => "playwithme.mid" };

    @{$self->{tier_titles}{"ghrt80s-ps2"}} = ( "Opening Licks",
                                               "Amp-Warmers",
                                               "String Snappers",
			                       "Return of the Shred",
			                       "Relentless Riffs",
			                       "Furious Fretwork",
			                       "Bonus Tracks" );

}

1;

