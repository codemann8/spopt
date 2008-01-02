#!/usr/bin/perl5

our $OUTDIR = "/cygdrive/c/web/GuitarHeroRev0.7";
our %SONGS;

$TIER_TITLE{"gh2-x360"} = [ "Opening Licks",
                           "Amp-Warmers",
			   "String Snappers",
			   "Thrash and Burn",
			   "Return of the Shred",
			   "Relentless Riffs",
			   "Furious Fretwork",
			   "Face-Melters",
			   "Bonus Tracks",
			   "DLC" ];

$TIER_TITLE{"gh2-ps2"} = [ "Opening Licks",
                           "Amp-Warmers",
			   "String Snappers",
			   "Thrash and Burn",
			   "Return of the Shred",
			   "Relentless Riffs",
			   "Furious Fretwork",
			   "Face-Melters",
			   "Bonus Tracks" ];

$TIER_TITLE{"gh-ps2"} = [ "Opening Licks",
                          "Axe-Grinders",
			  "Thrash and Burn",
			  "Return of the Shred",
			  "Fret Burners",
			  "Face-Melters",
			  "Bonus Tracks" ];

$TIER_TITLE{"ghrt80s-ps2"} = [ "Opening Licks",
                               "Amp-Warmers",
                               "String Snappers",
			       "Return of the Shred",
			       "Relentless Riffs",
			       "Furious Fretwork",
			       "Bonus Tracks" ];

push @{$SONGS{"gh2-ps2"}}, { tier => 0, name => "Shout at the Devil",                  file => "shoutatthedevil.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 0, name => "Mother",                              file => "mother.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 0, name => "Surrender",                           file => "surrender.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 0, name => "Woman",                               file => "woman.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 0, name => "Tonight I'm Gonna Rock You Tonight",  file => "tonightimgonna.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 1, name => "Strutter",                            file => "strutter.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 1, name => "Heart-Shaped Box",                    file => "heartshapedbox.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 1, name => "Message in a Bottle",                 file => "messageinabottle.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 1, name => "You Really Got Me",                   file => "youreallygotme.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 1, name => "Carry on Wayward Son",                file => "carryonwayward.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 2, name => "Monkey Wrench",                       file => "monkeywrench.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 2, name => "Them Bones",                          file => "thembones.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 2, name => "Search and Destroy",                  file => "searchanddestroy.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 2, name => "Tattooed Love Boys",                  file => "tattooedloveboys.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 2, name => "War Pigs",                            file => "warpigs.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 3, name => "Cherry Pie",                          file => "cherrypie.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 3, name => "Who Was in My Room Last Night",       file => "whowasinmyroom.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 3, name => "Girlfriend",                          file => "girlfriend.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 3, name => "Can't You Hear Me Knockin'",          file => "cantyouhearme.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 3, name => "Sweet Child O' Mine",                 file => "sweetchild.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 4, name => "Killing in the Name",                 file => "killinginthenameof.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 4, name => "John the Fisherman",                  file => "johnthefisherman.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 4, name => "Freya",                               file => "freya.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 4, name => "Bad Reputation",                      file => "badreputation.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 4, name => "Last Child",                          file => "lastchild.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 5, name => "Crazy on You",                        file => "crazyonyou.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 5, name => "Trippin' On a Hole in a Paper Heart", file => "trippinonahole.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 5, name => "Rock This Town",                      file => "rockthistown.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 5, name => "Jessica",                             file => "jessica.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 5, name => "Stop",                                file => "stop.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 6, name => "Madhouse",                            file => "madhouse.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 6, name => "Carry Me Home",                       file => "carrymehome.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 6, name => "Laid to Rest",                        file => "laidtorest.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 6, name => "Psychobilly Freakout",                file => "psychobilly.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 6, name => "YYZ",                                 file => "yyz.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 7, name => "Beast and the Harlot",                file => "beastandtheharlot.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 7, name => "Institutionalized",                   file => "institutionalized.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 7, name => "Misirlou",                            file => "misirlou.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 7, name => "Hangar 18",                           file => "hangar18.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 7, name => "Free Bird",                           file => "freebird.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Raw Dog",                             file => "rawdog.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Arterial Black",                      file => "arterialblack.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Collide",                             file => "collide.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Elephant Bones",                      file => "elephantbones.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Fall of Pangea",                      file => "fallofpangea.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "FTK",                                 file => "ftk.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Gemini",                              file => "gemini.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Push Push (Lady Lightning)",          file => "ladylightning.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Laughtrack",                          file => "laughtrack.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Less Talk More Rokk",                 file => "lesstalkmorerokk.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Jordan",                              file => "jordan.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Mr. Fix It",                          file => "mrfixit.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "The New Black",                       file => "newblack.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "One for the Road",                    file => "onefortheroad.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Parasite",                            file => "parasite.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Radium Eyes",                         file => "radiumeyes.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Red Lottery",                         file => "redlottery.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Six",                                 file => "six.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Soy Bomb",                            file => "soybomb.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "The Light That Blinds",               file => "thelightthatblinds.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Thunderhorse",                        file => "thunderhorse.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Trogdor",                             file => "trogdor.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "X-Stream",                            file => "xstream.mid" };
push @{$SONGS{"gh2-ps2"}}, { tier => 8, name => "Yes We Can",                          file => "yeswecan.mid" };

push @{$SONGS{"gh2-x360"}},{ tier => 0, name => "Surrender",                           file => "surrender.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 0, name => "Possum Kingdom",                      file => "possum.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 0, name => "Heart-Shaped Box",                    file => "heartshapedbox.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 0, name => "Salvation",                           file => "salvation.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 0, name => "Strutter",                            file => "strutter.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 0, name => "Shout at the Devil",                  file => "shoutatthedevil.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 1, name => "Mother",                              file => "mother.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 1, name => "Life Wasted",                         file => "lifewasted.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 1, name => "Cherry Pie",                          file => "cherrypie.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 1, name => "Woman",                               file => "woman.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 1, name => "You Really Got Me",                   file => "youreallygotme.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 1, name => "Tonight I'm Gonna Rock You Tonight",  file => "tonightimgonna.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 2, name => "Carry On Wayward Son",                file => "carryonwayward.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 2, name => "Search and Destroy",                  file => "searchanddestroy.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 2, name => "Message in a Bottle",                 file => "messageinabottle.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 2, name => "Billion Dollar Babies",               file => "billiondollar.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 2, name => "Them Bones",                          file => "thembones.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 2, name => "War Pigs",                            file => "warpigs.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 3, name => "Monkey Wrench",                       file => "monkeywrench.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 3, name => "Hush",                                file => "hush.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 3, name => "Girlfriend",                          file => "girlfriend.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 3, name => "Who Was in My Room Last Night",       file => "whowasinmyroom.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 3, name => "Can't You Hear Me Knockin'",          file => "cantyouhearme.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 3, name => "Sweet Child O' Mine",                 file => "sweetchild.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 4, name => "Rock and Roll Hoochie Koo",           file => "rockandroll.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 4, name => "Tattooed Love Boys",                  file => "tattooedloveboys.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 4, name => "John the Fisherman",                  file => "johnthefisherman.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 4, name => "Jessica",                             file => "jessica.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 4, name => "Bad Reputation",                      file => "badreputation.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 4, name => "Last Child",                          file => "lastchild.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 5, name => "Crazy on You",                        file => "crazyonyou.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 5, name => "Trippin' On a Hole in a Paper Heart", file => "trippinonahole.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 5, name => "Dead!",                               file => "dead.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 5, name => "Killing in the Name",                 file => "killinginthenameof.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 5, name => "Freya",                               file => "freya.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 5, name => "Stop",                                file => "stop.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 6, name => "Madhouse",                            file => "madhouse.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 6, name => "The Trooper",                         file => "trooper.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 6, name => "Rock This Town",                      file => "rockthistown.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 6, name => "Laid to Rest",                        file => "laidtorest.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 6, name => "Psychobilly Freakout",                file => "psychobilly.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 6, name => "YYZ",                                 file => "yyz.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 7, name => "Beast and the Harlot",                file => "beastandtheharlot.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 7, name => "Carry Me Home",                       file => "carrymehome.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 7, name => "Institutionalized",                   file => "institutionalized.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 7, name => "Misirlou",                            file => "misirlou.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 7, name => "Hangar 18",                           file => "hangar18.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 7, name => "Free Bird",                           file => "freebird.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Raw Dog",                             file => "rawdog.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Arterial Black",                      file => "arterialblack.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Collide",                             file => "collide.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Drink Up",                            file => "drinkup.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Elephant Bones",                      file => "elephantbones.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Fall of Pangea",                      file => "fallofpangea.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "FTK",                                 file => "ftk.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Gemini",                              file => "gemini.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Kicked to the Curb",                  file => "kicked.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Push Push (Lady Lightning)",          file => "ladylightning.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Laughtrack",                          file => "laughtrack.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Less Talk More Rokk",                 file => "lesstalkmorerokk.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Jordan",                              file => "jordan.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Mr. Fix It",                          file => "mrfixit.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "The New Black",                       file => "newblack.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "One for the Road",                    file => "onefortheroad.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Parasite",                            file => "parasite.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Radium Eyes",                         file => "radiumeyes.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Red Lottery",                         file => "redlottery.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Six",                                 file => "six.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Soy Bomb",                            file => "soybomb.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "The Light That Blinds",               file => "thelightthatblinds.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Thunderhorse",                        file => "thunderhorse.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Trogdor",                             file => "trogdor.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "X-Stream",                            file => "xstream.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 8, name => "Yes We Can",                          file => "yeswecan.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Ace Of Spades",                       file => "aceofspades.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Bark At The Moon",                    file => "barkatthemoon.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Hey You",                             file => "heyyou.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Frankenstein",                        file => "frankenstein.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Killer Queen",                        file => "killerqueen.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Take It Off",                         file => "takeitoff.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Higher Ground",                       file => "higherground.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Infected",                            file => "infected.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Stellar",                             file => "stellar.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "I Wanna Be Sedated",                  file => "iwannabesedated.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Smoke On the Water",                  file => "smokeonthewater.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "You've Got Another Thing Comin'",     file => "yougotanotherthingcomin.mid" };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Famous Last Words",                   file => "famouslastwords.mid"  };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Teenagers",                           file => "teenagers.mid"  };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "This Is How I Disappear",             file => "thisishowidisappear.mid"  };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Bury The Hatchet",                    file => "burythehatchet.mid"  };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Detonation",                          file => "detonation.mid"  };
push @{$SONGS{"gh2-x360"}},{ tier => 9, name => "Ex's And Oh's",                       file => "exsandohs.mid"  };

push @{$SONGS{"gh-ps2"}},  { tier => 0, name => "I Love Rock & Roll",                  file => "iloverockandroll.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 0, name => "I Wanna Be Sedated",                  file => "iwannabesedated.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 0, name => "Thunder Kiss 65",                     file => "thunderkiss65.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 0, name => "Smoke On The Water",                  file => "smokeonthewater.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 0, name => "Infected",                            file => "infected.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 1, name => "Iron Man",                            file => "ironman.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 1, name => "More Than A Feeling",                 file => "morethanafeeling.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 1, name => "You Got Another Thing Comin'",        file => "yougotanotherthingcomin.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 1, name => "Take Me Out",                         file => "takemeout.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 1, name => "Sharp Dressed Man",                   file => "sharpdressedman.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 2, name => "Killer Queen",                        file => "killerqueen.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 2, name => "Hey You",                             file => "heyyou.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 2, name => "Stellar",                             file => "stellar.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 2, name => "Heart Full of Black",                 file => "heartfullofblack.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 2, name => "Symphony Of Destruction",             file => "symphofdestruction.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 3, name => "Ziggy Stardust",                      file => "ziggystardust.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 3, name => "Fat Lip",                             file => "fatlip.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 3, name => "Cochise",                             file => "cochise.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 3, name => "Take It Off",                         file => "takeitoff.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 3, name => "Unsung",                              file => "unsung.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 4, name => "Spanish Castle Magic",                file => "spanishcastlemagic.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 4, name => "Higher Ground",                       file => "higherground.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 4, name => "No One Knows",                        file => "nooneknows.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 4, name => "Ace Of Spades",                       file => "aceofspades.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 4, name => "Crossroads",                          file => "crossroads.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 5, name => "Godzilla",                            file => "godzilla.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 5, name => "Texas Flood",                         file => "texasflood.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 5, name => "Frankenstein",                        file => "frankenstein.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 5, name => "Cowboys From Hell",                   file => "cowboysfromhell.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 5, name => "Bark At The Moon",                    file => "barkatthemoon.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Fire It Up",                          file => "fireitup.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Cheat on the Church",                 file => "cheatonthechurch.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Caveman Rejoice",                     file => "cavemanrejoice.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Eureka, I've Found Love",             file => "eureka.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "All of This",                         file => "allofthis.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Behind The Mask",                     file => "behindthemask.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "The Breaking Wheel",                  file => "breakingwheel.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Callout",                             file => "callout.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Decontrol",                           file => "decontrol.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Even Rats",                           file => "evenrats.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Farewell Myth",                       file => "farewellmyth.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Fly On The Wall",                     file => "flyonthewall.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Get Ready 2 Rokk",                    file => "getready2rokk.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Guitar Hero",                         file => "guitarhero.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Hey",                                 file => "hey.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Sail Your Ship By",                   file => "sailyourshipby.mid" };
push @{$SONGS{"gh-ps2"}},  { tier => 6, name => "Story of My Love",                    file => "storyofmylove.mid" };

push @{$SONGS{"ghrt80s-ps2"}}, { tier => 0, name => "(Bang Your Head) Metal Health",   file => "bangyourhead.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 0, name => "We Got The Beat",                 file => "wegotthebeat.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 0, name => "I Ran (So Far Away)",             file => "iran.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 0, name => "Balls To The Wall",               file => "ballstothewall.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 0, name => "18 And Life",                     file => "18andlife.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 1, name => "No One Like You",                 file => "noonelikeyou.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 1, name => "Shakin'",                         file => "shakin.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 1, name => "Heat Of The Moment",              file => "heatofthemoment.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 1, name => "Radar Love",                      file => "radarlove.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 1, name => "Because, It's Midnite",           file => "becauseitsmidnite.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 2, name => "Holy Diver",                      file => "holydiver.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 2, name => "Turning Japanese",                file => "turningjapanese.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 2, name => "Hold On Loosely",                 file => "holdonloosely.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 2, name => "The Warrior",                     file => "thewarrior.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 2, name => "I Wanna Rock",                    file => "iwannarock.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 3, name => "What I Like About You",           file => "whatilikeaboutyou.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 3, name => "Synchronicity II",                file => "synchronicity2.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 3, name => "Ballroom Blitz",                  file => "ballroomblitz.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 3, name => "Only A Lad",                      file => "onlyalad.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 3, name => "Round And Round",                 file => "roundandround.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 4, name => "Ain't Nothin But A Good Time",    file => "aintnothinbut.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 4, name => "Lonely Is The Night",             file => "lonelyisthenight.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 4, name => "Bathroom Wall",                   file => "bathroomwall.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 4, name => "Los Angeles",                     file => "losangeles.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 4, name => "Wrathchild",                      file => "wrathchild.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 5, name => "Electric Eye",                    file => "electriceye.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 5, name => "Police Truck",                    file => "policetruck.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 5, name => "Seventeen",                       file => "seventeen.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 5, name => "Caught In A Mosh",                file => "caughtinamosh.mid" };
push @{$SONGS{"ghrt80s-ps2"}}, { tier => 5, name => "Play With Me",                    file => "playwithme.mid" };

our @DB = ();

for my $game (qw(gh-ps2 gh2-ps2 gh2-x360 ghrt80s-ps2)) {
    foreach my $diff (qw(easy medium hard expert)) {
	my $maxtier = $game eq "gh-ps2" ? 6 : $game eq "ghrt80s-ps2" ? 6 : $game eq "gh2-ps2" ? 8 : $game eq "gh2-x360" ? 9 : 0;
	for my $i (0 .. $maxtier) {
	    my $tier_title = $TIER_TITLE{$game}[$i];
	    my @songs = grep { $_->{tier} == $i } @{$SONGS{$game}};
	    foreach my $rs (@songs) {
		my ($tiernum,$name,$file) = ($rs->{tier}, $rs->{name}, $rs->{file});
		my $basefile = $file; $basefile =~ s/.mid$//;
		my $nospscore = 0;
		my ($nosp,$base,$lw,$ns,$bs,$bgrs,$ni,$ub) = &get_scores($game,$diff,$basefile);
		push @DB, [$game,$diff,$tiernum,$tier_title,$name,$file,$nosp,$lw,$ns,$bs,$bgrs,$ni,$ub,$base];
	    }
	}
    }
}

open AAA, ">/home/Dave/gh/res.tsv";
foreach my $ra (@DB) {
    my $line = join "\t", @$ra;
    $line .= "\n";
    print AAA $line;
}
close AAA;

open AAA, ">/home/Dave/gh/res.csv";
foreach my $ra (@DB) {
    $ra->[4] = '"' . $ra->[4] . '"';
    my $line = join ",", @$ra;
    $line .= "\n";
    print AAA $line;
}
close AAA;



sub get_scores {
    my ($game,$diff,$basefile) = @_;
    my $nospscore = 0;
    my $basescore = 0;
    my @algscores = ();
    foreach my $alg (qw(lazy-whammy no-squeeze big-squeeze bigger-squeeze nearly-ideal upper-bound)) {
	my $file = "$OUTDIR/$game/$diff/$basefile.$alg.summary.html";
	open QQQ, "$file";
	my @lines = <QQQ>; chomp @lines;
	close QQQ;
	my @spscores  = grep { m/Estimated Perfect w.o SP/ } @lines;
	my @totscores = grep { m/Estimated Total Score/    } @lines;
	my @basescores = grep { m/Estimated Base score/    } @lines;
	$basescores[0] =~ m/score\s+(\d+)/; $basescore = $1;
	$spscores[0] =~ m/SP\s+(\d+)/; $nospscore = $1;
	$totscores[0] =~ m/Total Score\s+(\d+)/; push @algscores, $1;
    }
    return ($nospscore,$basescore,@algscores);
}
