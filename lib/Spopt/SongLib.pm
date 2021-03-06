# $Id: SongLib.pm,v 1.16 2009-02-22 00:52:26 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongLib.pm,v $

package Spopt::SongLib;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 0, name => "Shout at the Devil",                  file => "shoutatthedevil.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 0, name => "Mother",                              file => "mother.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 0, name => "Surrender",                           file => "surrender.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 0, name => "Woman",                               file => "woman.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 0, name => "Tonight I'm Gonna Rock You Tonight",  file => "tonightimgonna.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 1, name => "Strutter",                            file => "strutter.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 1, name => "Heart-Shaped Box",                    file => "heartshapedbox.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 1, name => "Message in a Bottle",                 file => "messageinabottle.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 1, name => "You Really Got Me",                   file => "youreallygotme.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 1, name => "Carry on Wayward Son",                file => "carryonwayward.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 2, name => "Monkey Wrench",                       file => "monkeywrench.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 2, name => "Them Bones",                          file => "thembones.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 2, name => "Search and Destroy",                  file => "searchanddestroy.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 2, name => "Tattooed Love Boys",                  file => "tattooedloveboys.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 2, name => "War Pigs",                            file => "warpigs.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 3, name => "Cherry Pie",                          file => "cherrypie.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 3, name => "Who Was in My Room Last Night",       file => "whowasinmyroom.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 3, name => "Girlfriend",                          file => "girlfriend.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 3, name => "Can't You Hear Me Knockin'",          file => "cantyouhearme.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 3, name => "Sweet Child O' Mine",                 file => "sweetchild.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 4, name => "Killing in the Name",                 file => "killinginthenameof.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 4, name => "John the Fisherman",                  file => "johnthefisherman.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 4, name => "Freya",                               file => "freya.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 4, name => "Bad Reputation",                      file => "badreputation.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 4, name => "Last Child",                          file => "lastchild.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 5, name => "Crazy on You",                        file => "crazyonyou.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 5, name => "Trippin' On a Hole in a Paper Heart", file => "trippinonahole.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 5, name => "Rock This Town",                      file => "rockthistown.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 5, name => "Jessica",                             file => "jessica.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 5, name => "Stop",                                file => "stop.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 6, name => "Madhouse",                            file => "madhouse.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 6, name => "Carry Me Home",                       file => "carrymehome.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 6, name => "Laid to Rest",                        file => "laidtorest.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 6, name => "Psychobilly Freakout",                file => "psychobilly.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 6, name => "YYZ",                                 file => "yyz.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 7, name => "Beast and the Harlot",                file => "beastandtheharlot.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 7, name => "Institutionalized",                   file => "institutionalized.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 7, name => "Misirlou",                            file => "misirlou.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 7, name => "Hangar 18",                           file => "hangar18.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 7, name => "Free Bird",                           file => "freebird.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Raw Dog",                             file => "rawdog.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Arterial Black",                      file => "arterialblack.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Collide",                             file => "collide.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Elephant Bones",                      file => "elephantbones.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Fall of Pangea",                      file => "fallofpangea.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "FTK",                                 file => "ftk.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Gemini",                              file => "gemini.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Push Push (Lady Lightning)",          file => "ladylightning.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Laughtrack",                          file => "laughtrack.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Less Talk More Rokk",                 file => "lesstalkmorerokk.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Jordan",                              file => "jordan.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Mr. Fix It",                          file => "mrfixit.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "The New Black",                       file => "newblack.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "One for the Road",                    file => "onefortheroad.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Parasite",                            file => "parasite.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Radium Eyes",                         file => "radiumeyes.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Red Lottery",                         file => "redlottery.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Six",                                 file => "six.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Soy Bomb",                            file => "soybomb.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "The Light That Blinds",               file => "thelightthatblinds.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Thunderhorse",                        file => "thunderhorse.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Trogdor",                             file => "trogdor.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "X-Stream",                            file => "xstream.mid" };
    push @{$self->{songarr}}, { game => "gh2-ps2",     tier => 8, name => "Yes We Can",                          file => "yeswecan.mid" };
    
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 0, name => "Surrender",                           file => "surrender.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 0, name => "Possum Kingdom",                      file => "possum.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 0, name => "Heart-Shaped Box",                    file => "heartshapedbox.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 0, name => "Salvation",                           file => "salvation.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 0, name => "Strutter",                            file => "strutter.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 0, name => "Shout at the Devil",                  file => "shoutatthedevil.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 1, name => "Mother",                              file => "mother.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 1, name => "Life Wasted",                         file => "lifewasted.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 1, name => "Cherry Pie",                          file => "cherrypie.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 1, name => "Woman",                               file => "woman.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 1, name => "You Really Got Me",                   file => "youreallygotme.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 1, name => "Tonight I'm Gonna Rock You Tonight",  file => "tonightimgonna.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 2, name => "Carry On Wayward Son",                file => "carryonwayward.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 2, name => "Search and Destroy",                  file => "searchanddestroy.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 2, name => "Message in a Bottle",                 file => "messageinabottle.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 2, name => "Billion Dollar Babies",               file => "billiondollar.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 2, name => "Them Bones",                          file => "thembones.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 2, name => "War Pigs",                            file => "warpigs.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 3, name => "Monkey Wrench",                       file => "monkeywrench.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 3, name => "Hush",                                file => "hush.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 3, name => "Girlfriend",                          file => "girlfriend.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 3, name => "Who Was in My Room Last Night",       file => "whowasinmyroom.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 3, name => "Can't You Hear Me Knockin'",          file => "cantyouhearme.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 3, name => "Sweet Child O' Mine",                 file => "sweetchild.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 4, name => "Rock and Roll Hoochie Koo",           file => "rockandroll.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 4, name => "Tattooed Love Boys",                  file => "tattooedloveboys.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 4, name => "John the Fisherman",                  file => "johnthefisherman.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 4, name => "Jessica",                             file => "jessica.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 4, name => "Bad Reputation",                      file => "badreputation.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 4, name => "Last Child",                          file => "lastchild.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 5, name => "Crazy on You",                        file => "crazyonyou.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 5, name => "Trippin' On a Hole in a Paper Heart", file => "trippinonahole.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 5, name => "Dead!",                               file => "dead.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 5, name => "Killing in the Name",                 file => "killinginthenameof.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 5, name => "Freya",                               file => "freya.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 5, name => "Stop",                                file => "stop.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 6, name => "Madhouse",                            file => "madhouse.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 6, name => "The Trooper",                         file => "trooper.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 6, name => "Rock This Town",                      file => "rockthistown.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 6, name => "Laid to Rest",                        file => "laidtorest.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 6, name => "Psychobilly Freakout",                file => "psychobilly.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 6, name => "YYZ",                                 file => "yyz.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 7, name => "Beast and the Harlot",                file => "beastandtheharlot.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 7, name => "Carry Me Home",                       file => "carrymehome.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 7, name => "Institutionalized",                   file => "institutionalized.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 7, name => "Misirlou",                            file => "misirlou.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 7, name => "Hangar 18",                           file => "hangar18.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 7, name => "Free Bird",                           file => "freebird.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Raw Dog",                             file => "rawdog.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Arterial Black",                      file => "arterialblack.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Collide",                             file => "collide.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Drink Up",                            file => "drinkup.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Elephant Bones",                      file => "elephantbones.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Fall of Pangea",                      file => "fallofpangea.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "FTK",                                 file => "ftk.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Gemini",                              file => "gemini.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Kicked to the Curb",                  file => "kicked.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Push Push (Lady Lightning)",          file => "ladylightning.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Laughtrack",                          file => "laughtrack.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Less Talk More Rokk",                 file => "lesstalkmorerokk.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Jordan",                              file => "jordan.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Mr. Fix It",                          file => "mrfixit.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "The New Black",                       file => "newblack.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "One for the Road",                    file => "onefortheroad.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Parasite",                            file => "parasite.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Radium Eyes",                         file => "radiumeyes.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Red Lottery",                         file => "redlottery.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Six",                                 file => "six.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Soy Bomb",                            file => "soybomb.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "The Light That Blinds",               file => "thelightthatblinds.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Thunderhorse",                        file => "thunderhorse.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Trogdor",                             file => "trogdor.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "X-Stream",                            file => "xstream.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 8, name => "Yes We Can",                          file => "yeswecan.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Ace Of Spades",                       file => "aceofspades.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Bark At The Moon",                    file => "barkatthemoon.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Hey You",                             file => "heyyou.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Frankenstein",                        file => "frankenstein.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Killer Queen",                        file => "killerqueen.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Take It Off",                         file => "takeitoff.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Higher Ground",                       file => "higherground.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Infected",                            file => "infected.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Stellar",                             file => "stellar.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "I Wanna Be Sedated",                  file => "iwannabesedated.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Smoke On the Water",                  file => "smokeonthewater.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "You've Got Another Thing Comin'",     file => "yougotanotherthingcomin.mid" };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Famous Last Words",                   file => "famouslastwords.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Teenagers",                           file => "teenagers.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "This Is How I Disappear",             file => "thisishowidisappear.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Bury The Hatchet",                    file => "burythehatchet.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Detonation",                          file => "detonation.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Ex's And Oh's",                       file => "exsandohs.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Sin Documentos",                      file => "sindocumentos.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Sept",                                file => "sept.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Exile",                               file => "exile.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "Memories Of The Grove",               file => "memoriesofthe.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "State of Massachusetts",              file => "stateofmass.mid"  };
    push @{$self->{songarr}}, { game => "gh2-x360",    tier => 9, name => "You Should Be Ashamed Of Myself",     file => "youshouldbeashamed.mid" };
    
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

    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 0,  name => "Slow Ride",                       file => "slowride.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 0,  name => "Talk Dirty to Me",                file => "talkdirtytome.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 0,  name => "Hit Me WIth Your Best Shot",      file => "hitmewithyourbestshot.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 0,  name => "Story of My Life",                file => "storyofmylife.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 0,  name => "Rock and Roll All Nite",          file => "rocknrollallnite.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 1,  name => "Mississippi Queen",               file => "mississippiqueen.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 1,  name => "School's Out",                    file => "schoolsout.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 1,  name => "Sunshine of Your Love",           file => "sunshineofyourlove.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 1,  name => "Barracuda",                       file => "barracuda.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 1,  name => "Bulls on Parade",                 file => "bullsonparade.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 2,  name => "When You Were Young",             file => "whenyouwereyoung.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 2,  name => "Miss Murder",                     file => "missmurder.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 2,  name => "The Seeker",                      file => "theseeker.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 2,  name => "Lay Down",                        file => "laydown.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 2,  name => "Paint It Black",                  file => "paintitblack.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 3,  name => "Paranoid",                        file => "paranoid.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 3,  name => "Anarchy in the U.K.",             file => "anarchyintheuk.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 3,  name => "Kool Thing",                      file => "koolthing.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 3,  name => "My Name is Jonas",                file => "mynameisjonas.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 3,  name => "Even Flow",                       file => "evenflow.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 4,  name => "Holiday in Cambodia",             file => "holidayincambodia.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 4,  name => "Rock You Like a Hurricane",       file => "rockulikeahurricane.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 4,  name => "Same Old Song and Dance",         file => "sameoldsonganddance.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 4,  name => "La Grange",                       file => "lagrange.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 4,  name => "Welcome to the Jungle",           file => "welcometothejungle.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 5,  name => "Black Magic Woman",               file => "blackmagicwoman.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 5,  name => "Cherub Rock",                     file => "cherubrock.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 5,  name => "Black Sunshine",                  file => "blacksunshine.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 5,  name => "The Metal",                       file => "themetal.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 5,  name => "Pride and Joy",                   file => "pridenjoy.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 6,  name => "Before I Forget",                 file => "beforeiforget.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 6,  name => "Stricken",                        file => "stricken.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 6,  name => "3's & 7's",                       file => "threesandsevens.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 6,  name => "Knights of Cydonia",              file => "knightsofcydonia.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 6,  name => "Cult of Personality",             file => "cultofpersonality.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 7,  name => "Raining Blood",                   file => "rainingblood.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 7,  name => "Cliffs of Dover",                 file => "cliffsofdover.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 7,  name => "The Number of the Beast",         file => "numberofthebeast.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 7,  name => "One",                             file => "one.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 8,  name => "Sabotage",                        file => "sabotage.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 8,  name => "Reptilia",                        file => "reptilia.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 8,  name => "Suck My Kiss",                    file => "suckmykiss.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 8,  name => "Cities on Flame with Rock and Roll",  file => "citiesonflame.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 8,  name => "Helicopter",                      file => "helicopter.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 8,  name => "Monsters",                        file => "monsters.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Avalancha",                       file => "avalancha.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "In the Belly of a Shark",         file => "bellyofashark.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Can't Be Saved",                  file => "cantbesaved.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Closer",                          file => "closer.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Don't Hold Back",                 file => "dontholdback.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Down n' Dirty",                   file => "downndirty.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "F.C.P.R.E.M.I.X.",                file => "fcpremix.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Generation Rock",                 file => "generationrock.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Go That Far",                     file => "gothatfar.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Hier Kommt Alex",                 file => "hierkommtalex.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "I'm in the Band",                 file => "imintheband.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Impulse",                         file => "impulse.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "In Love",                         file => "inlove.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Mauvais Garcon",                  file => "mauvaisgarcon.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Metal Heavy Lady",                file => "metalheavylady.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Minus Celcius",                   file => "minuscelsius.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "My Curse",                        file => "mycurse.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Nothing for Me Here",             file => "nothingformehere.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Prayer of the Refugee",           file => "prayeroftherefugee.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Radio Song",                      file => "radiosong.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Ruby",                            file => "ruby.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "She Bangs the Drums",             file => "shebangsadrum.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Take This Life",                  file => "takethislife.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "The Way It Ends",                 file => "thewayitends.mid" };
    push @{$self->{songarr}}, { game => "gh3-ps2", tier => 9,  name => "Through the Fire and Flames",     file => "thrufireandflames.mid" };

    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'All My Life',                     file => 'dlc3.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Pretender',                   file => 'dlc4.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'This is a call',                  file => 'dlc5.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Slither',                         file => 'dlc6.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'She Builds Quick Machines',       file => 'dlc7.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Messages',                        file => 'dlc8.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Tom Morello Guitar Battle',       file => 'dlc1.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Slash Guitar Battle',             file => 'dlc2.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Devil Went Down To Georgia',  file => 'dlc17.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Carcinogen Crush',                file => 'dlc14.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Tina',                            file => 'dlc15.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Putting Holes In Happiness',      file => 'dlc16.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Halo Theme MJOLNIR Mix',          file => 'dlc19.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Ernten Was Wir Säen',             file => 'dlc26.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'So Payaso',                       file => 'dlc18.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Antisocial',                      file => 'dlc9.mid'  };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Pretty Handsome Awkward',         file => 'dlc11.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'No More Sorrow',                  file => 'dlc12.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Sleeping Giant',                  file => 'dlc13.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'We Three Kings',                  file => 'dlc36.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Any Way You Want It',             file => 'dlc10.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Jukebox Hero',                    file => 'dlc24.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Peace Of Mind',                   file => 'dlc25.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Dream On',                        file => 'dlc37.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Excuse Me Mr.',                   file => 'dlc29.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Don\'t Speak',                    file => 'dlc30.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Sunday Morning',                  file => 'dlc31.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Arsonist',                    file => 'dlc27.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Hole in the Earth',               file => 'dlc28.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Almost Easy',                     file => 'dlc32.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Famous for Nothing',              file => 'dlc38.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => '(F)lannigan\'s Ball',             file => 'dlc39.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Johnny, I Hardly Knew Ya',        file => 'dlc40.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Nine Lives',                      file => 'dlc49.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Photograph (Live)',               file => 'dlc50.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Rock of Ages (Live)',             file => 'dlc51.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Exo-Politics',                    file => 'dlc33.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Stockholm Syndrome',              file => 'dlc34.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Super Massive Black Hole',        file => 'dlc35.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Stay Clean',                      file => 'dlc45.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => '(We Are) The Road Crew',          file => 'dlc46.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Motörhead',                       file => 'dlc47.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Shoot the Runner',                file => 'dlc68.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Problems (Live at Brixton)',      file => 'dlc69.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'I Predict a Riot',                file => 'dlc70.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Violet Hill',                     file => 'dlc71.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Yellow',                          file => 'dlc72.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'God Put A Smile Upon Your Face',  file => 'dlc73.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'I Am Murloc',                     file => 'dlc75.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Top Gun Anthem',                  file => 'dlc74.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Surfing With The Alien',          file => 'dlc62.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'For the Love of God',             file => 'dlc63.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Soothsayer',                      file => 'dlc66.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Heroes of Our Time',              file => 'dlc80.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Operation Ground and Pound',      file => 'dlc81.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Revolution Deathsquad',           file => 'dlc82.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'My Apocalypse',                   file => 'dlc83.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'All Nightmare Long',              file => 'dlc84.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'That Was Just Your Life',         file => 'dlc85.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Day That Never Comes',        file => 'dlc86.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Broken, Beat & Scarred',          file => 'dlc87.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Judas Kiss',                  file => 'dlc88.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The End of the Line',             file => 'dlc89.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'The Unforgiven III',              file => 'dlc90.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Cyanide',                         file => 'dlc91.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Suicide & Redemption J.H.',       file => 'dlc92.mid' };
    push @{$self->{songarr}}, { game => 'gh3-dlc', tier => 10, name => 'Suicide & Redemption K.H.',       file => 'dlc93.mid' };

    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'Dream Police',                  file => 'dreampolice.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'All the Young Dudes',           file => 'alltheyoungdudes.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'Make It',                       file => 'makeit.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'Uncle Salty',                   file => 'unclesalty.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 0, name => 'Draw The Line',                 file => 'drawtheline.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'I Hate Myself For Loving You',  file => 'ihatemyselfforlovingyou.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'All Day and All of the Night',  file => 'alldayandallofthenight.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'No Surprize',                   file => 'nosurprize.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'Movin\' Out',                   file => 'movinout.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 1, name => 'Sweet Emotion',                 file => 'sweetemotion.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Complete Control',              file => 'completecontrol.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Personality Crisis',            file => 'personalitycrisis.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Livin\' on the Edge',           file => 'livinontheedge.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Rag Doll',                      file => 'ragdoll.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 2, name => 'Love In An Elevator',           file => 'loveinanelevator.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'She Sells Sanctuary',           file => 'shesellssanctuary.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'King of Rock',                  file => 'kingofrock.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'Nobody\'s Fault',               file => 'nobodysfault.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'Bright Light Fright',           file => 'brightlightfright.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 3, name => 'Walk This Way (Run DMC)',       file => 'walkthiswayrundmc.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Hard to Handle',                file => 'hardtohandle.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Always On The Run',             file => 'alwaysontherun.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Back In The Saddle',            file => 'backinthesaddle.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Beyond Beautiful',              file => 'beyondbeautiful.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 4, name => 'Dream On',                      file => 'dreamon.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Cat Scratch Fever',             file => 'catscratchfever.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Sex Type Thing',                file => 'sextypething.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Mama Kin',                      file => 'mamakin.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Toys in the Attic',             file => 'toysintheattic.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 5, name => 'Train Kept a Rollin\'',         file => 'trainkeptarollin.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Walk This Way',                 file => 'walkthisway.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Rats In The Cellar',            file => 'ratsinthecellar.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Kings and Queens',              file => 'kingsandqueens.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Combination',                   file => 'combination.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Let The Music Do The Talking',  file => 'letthemusicdothetalking.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Shakin\' My Cage',              file => 'shakinmycage.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Pink',                          file => 'pink.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Talk Talkin\'',                 file => 'talktalking.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Mercy',                         file => 'mercy.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Pandora\'s Box',                file => 'pandorasbox.mid' };
    push @{$self->{songarr}}, { game => 'gh3-aerosmith', tier => 6, name => 'Joe Perry Guitar Battle',       file => 'joeperryguitarbattle.mid' };

    @{$self->{tier_titles}{"gh2-x360"}} = ( "Opening Licks",
                                            "Amp-Warmers",
			                    "String Snappers",
			                    "Thrash and Burn",
			                    "Return of the Shred",
			                    "Relentless Riffs",
			                    "Furious Fretwork",
			                    "Face-Melters",
			                    "Bonus Tracks",
			                    "DLC" );

    @{$self->{tier_titles}{"gh2-ps2"}} = (  "Opening Licks",
                                            "Amp-Warmers",
			                    "String Snappers",
			                    "Thrash and Burn",
			                    "Return of the Shred",
			                    "Relentless Riffs",
			                    "Furious Fretwork",
			                    "Face-Melters",
			                    "Bonus Tracks" );

    @{$self->{tier_titles}{"gh-ps2"}} = (   "Opening Licks",
                                            "Axe-Grinders",
			                    "Thrash and Burn",
			                    "Return of the Shred",
			                    "Fret Burners",
			                    "Face-Melters",
			                    "Bonus Tracks" );

    @{$self->{tier_titles}{"ghrt80s-ps2"}} = ( "Opening Licks",
                                               "Amp-Warmers",
                                               "String Snappers",
			                       "Return of the Shred",
			                       "Relentless Riffs",
			                       "Furious Fretwork",
			                       "Bonus Tracks" );

    @{$self->{tier_titles}{"gh3-ps2"}} = (     "Starting Out Small",
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

    @{$self->{tier_titles}{"gh3-aerosmith"}} = (     "Getting The Band Together",
                                                     "First Taste Of Success",
                                                     "The Triumphant Return",
                                                     "International Superstars",
                                                     "The Great American Band",
                                                     "Rock \'N Roll Legends",
                                                     "The Vault" );

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

    push @{$self->{songarr}}, { game => 'ghwt', tier => 0, name => 'Livin\' On A Prayer', file => 'livingonaprayer.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 0, name => 'About A Girl (Unplugged)', file => 'aboutagirl.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 0, name => 'Mountain Song', file => 'mountainsong.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 1, name => 'Beautiful Disaster', file => 'beautifuldisaster.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 1, name => 'Obstacle 1', file => 'obstacle1.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 1, name => 'The One I Love', file => 'theoneilove.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 2, name => 'Some Might Say', file => 'somemightsay.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 2, name => 'Today', file => 'today.mid' };
    # push @{$self->{songarr}}, { game => 'ghwt', tier => 2, name => 'today_perf2.mid', file => 'today_perf2.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 2, name => 'What I\'ve Done', file => 'whativedone.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 3, name => 'Band On The Run', file => 'bandontherun.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 3, name => 'You\'re Gonna Say Yeah', file => 'youregonnasayyeah.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 3, name => 'Up Around The Bend', file => 'uparoundthebend.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 3, name => 'No Sleep Till Brooklyn', file => 'nosleeptillbrooklyn.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 4, name => 'The Joker', file => 'thejoker.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 4, name => 'Freak On A Leash', file => 'freakonaleash.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 4, name => 'Misery Business', file => 'miserybusiness.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 4, name => 'Hotel California', file => 'hotelcalifornia.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 5, name => 'Parabola', file => 'parabola.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 5, name => 'Schism', file => 'schism.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 5, name => 'Vicarious', file => 'vicarious.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Eye Of The Tiger', file => 'eyeofthetiger.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Spiderwebs', file => 'spiderwebs.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'One Way Or Another', file => 'onewayoranother.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Do It Again', file => 'doitagain.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Zakk Wylde Guitar Duel', file => 'bosszakk.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'Stillborn', file => 'stillborn.mid' };
    # push @{$self->{songarr}}, { game => 'ghwt', tier => 6, name => 'stillborn_perf2.mid', file => 'stillborn_perf2.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'The Middle', file => 'themiddle.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'Hey Man Nice Shot', file => 'heymanniceshot.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'Feel The Pain', file => 'feelthepain.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'Dammit', file => 'dammit.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 7, name => 'Everlong', file => 'everlong.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Heartbreaker', file => 'heartbreaker.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'American Woman', file => 'americanwoman.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Ramblin\' Man', file => 'ramblinman.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Go Your Own Way', file => 'goyourownway.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Ted Nugent Guitar Duel', file => 'bossted.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 8, name => 'Stranglehold', file => 'stranglehold.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'L\'Via L\'Viaquez', file => 'lvialviaquez.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'Kick Out The Jams', file => 'kickoutthejams.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'Santeria', file => 'santeria.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'On The Road Again (Live)', file => 'ontheroadagain.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 9, name => 'Love Me Two Times', file => 'lovemetwotimes.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'Monsoon', file => 'monsoon.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'Aggro', file => 'aggro.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'Rooftops (A Liberation Broadcast)', file => 'rooftops.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'Good God', file => 'goodgod.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 10, name => 'One Armed Scissor', file => 'onearmedscissor.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'The Kill', file => 'thekill.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'Shiver', file => 'shiver.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'Rebel Yell', file => 'rebelyell.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'Demolition Man (Live)', file => 'demolitionman.mid' };
    # push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'demolitionman_perf2.mid', file => 'demolitionman_perf2.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 11, name => 'Beat It', file => 'beatit.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Lazy Eye', file => 'lazyeye.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Too Much, Too Young, Too Fast', file => 'toomuchtooyoung.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Float On', file => 'floaton.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Nuvole E Lenzuola', file => 'nuvole.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 12, name => 'Pretty Vacant', file => 'prettyvacant.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Are You Gonna Go My Way', file => 'areyougonnagomyway.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Sweet Home Alabama (Live)', file => 'sweethomealabama.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Assassin', file => 'assassin.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Escuela de Calor', file => 'escueladecalor.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'The Wind Cries Mary', file => 'windcriesmary.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 13, name => 'Purple Haze (Live)', file => 'purplehaze.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'Toy Boy', file => 'toyboy.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'Hail To The Freaks', file => 'hailtothefreaks.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'VinterNoll2', file => 'vinternoll2.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'Hollywood Nights', file => 'hollywoodnights.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 14, name => 'Soul Doubt', file => 'souldoubt.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Love Removal Machine', file => 'loveremovalmachine.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Our Truth', file => 'ourtruth.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Antisocial', file => 'antisocial.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Prisoner Of Society', file => 'prisonerofsociety.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Mr. Crowley', file => 'mrcrowley.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 15, name => 'Crazy Train', file => 'crazytrain.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Re-Education (Through Labor)', file => 'reedthroughlabor.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'La Bamba', file => 'labamba.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Scream Aim Fire', file => 'screamaimfire.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Overkill', file => 'overkill.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Trapped Under Ice', file => 'trappedunderice.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'B.Y.O.B.', file => 'byob.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 16, name => 'Hot For Teacher', file => 'hotforteacher.mid' };

    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Love Spreads', file => 'lovespreads.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Never Too Late', file => 'nevertoolate.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Weapon Of Choice', file => 'weaponofchoice.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Pull Me Under', file => 'pullmeunder.mid' };
    push @{$self->{songarr}}, { game => 'ghwt', tier => 17, name => 'Satch Boogie', file => 'satchboogie.mid' };
}

1;

