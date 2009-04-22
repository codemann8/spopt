# $Id: GuitarHeroWorldTourDLC.pm,v 1.1 2009-04-22 12:05:21 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHeroWorldTourDLC.pm,v $

package Spopt::SongInfo::GuitarHeroWorldTourDLC;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;

    @{$self->{tier_titles}{'ghwt-dlc'}} = (
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
        'DLC',
    );

    @{$self->{'songarr'}} = (
        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{My Apocalypse},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc11.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{All Nightmare Long},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc12.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{That Was Just Your Life},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc13.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{The Day That Never Comes},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc14.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Broken, Beat & Scarred},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc15.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{The Judas Kiss},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc16.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{The End Of The Line},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc17.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{The Unforgiven III},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc18.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Cyanide},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc19.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Suicide & Redemption J.H.},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc20.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Suicide & Redemption K.H.},
        artist => q{Metallica},
        year   => 2008,
        file   => 'dlc21.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Guitar Duel With Ted Nugent (Co-Op)},
        artist => q{Ted Nugent},
        year   => 2008,
        file   => 'dlc1.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Guitar Duel With Zakk Wylde (Co-Op)},
        artist => q{Zakk Wylde},
        year   => 2008,
        file   => 'dlc2.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Anything},
        artist => q{An Endless Sporadic},
        year   => 2008,
        file   => 'dlc3.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Electro Rock},
        artist => q{Sworn},
        year   => 2008,
        file   => 'dlc4.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Rock N' Roll Band},
        artist => q{Boston},
        year   => 1976,
        file   => 'dlc5.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Hot Blooded},
        artist => q{Foreigner},
        year   => 1978,
        file   => 'dlc6.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Jessie's Girl},
        artist => q{Rick Springfield},
        year   => 1981,
        file   => 'dlc7.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{No Rain},
        artist => q{Blind Melon},
        year   => 1992,
        file   => 'dlc9.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Horse To Water},
        artist => q{R.E.M.},
        year   => 2008,
        file   => 'dlc25.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Man-Sized Wreath},
        artist => q{R.E.M.},
        year   => 2008,
        file   => 'dlc26.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Supernatural Superserious},
        artist => q{R.E.M.},
        year   => 2008,
        file   => 'dlc27.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Bag It Up},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc28.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{The Shock Of The Lightning},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc29.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Waiting For The Rapture},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc30.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Another Way To Die},
        artist => q{Jack White & Alicia Keys},
        year   => 2008,
        file   => 'dlc51.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Fire (Live At Woodstock)},
        artist => q{Jimi Hendrix},
        year   => 1969,
        file   => 'dlc22.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{If 6 Was 9},
        artist => q{Jimi Hendrix},
        year   => 1967,
        file   => 'dlc23.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Little Wing},
        artist => q{Jimi Hendrix},
        year   => 1967,
        file   => 'dlc24.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Hold Up},
        artist => q{The Raconteurs},
        year   => 2008,
        file   => 'dlc31.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Consoler Of The Lonely},
        artist => q{The Raconteurs},
        year   => 2008,
        file   => 'dlc32.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Salute Your Solution},
        artist => q{The Raconteurs},
        year   => 2008,
        file   => 'dlc33.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Losing Touch},
        artist => q{The Killers},
        year   => 2008,
        file   => 'dlc34.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Human},
        artist => q{The Killers},
        year   => 2008,
        file   => 'dlc35.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Mr. Brightside},
        artist => q{The Killers},
        year   => 2003,
        file   => 'dlc36.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{G.L.O.W.},
        artist => q{The Smashing Pumpkins},
        year   => 2008,
        file   => 'dlc37.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{1979},
        artist => q{The Smashing Pumpkins},
        year   => 1995,
        file   => 'dlc38.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{The Everlasting Gaze},
        artist => q{The Smashing Pumpkins},
        year   => 1999,
        file   => 'dlc39.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{You Know You're Right},
        artist => q{Nirvana},
        year   => 2002,
        file   => 'dlc40.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Negative Creep},
        artist => q{Nirvana},
        year   => 1989,
        file   => 'dlc41.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Sliver},
        artist => q{Nirvana},
        year   => 1990,
        file   => 'dlc42.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Mama Maè},
        artist => q{Negrita},
        year   => 1999,
        file   => 'dlc52.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{'54, '74, '90, 2010},
        artist => q{Sportfreunde Stiller},
        year   => 2006,
        file   => 'dlc53.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Dis-Moi},
        artist => q{BB Brunes},
        year   => 2007,
        file   => 'dlc57.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Life In The Fast Lane},
        artist => q{The Eagles},
        year   => 1976,
        file   => 'dlc43.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{One Of These Nights},
        artist => q{The Eagles},
        year   => 1975,
        file   => 'dlc44.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Frail Grasp On The Big Picture},
        artist => q{The Eagles},
        year   => 2007,
        file   => 'dlc45.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Your Face},
        artist => q{Pepper},
        year   => 2006,
        file   => 'dlc8.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Jimi},
        artist => q{Slightly Stoopid},
        year   => 2007,
        file   => 'dlc10.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Sacrifice},
        artist => q{The Expendables},
        year   => 2004,
        file   => 'dlc46.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Johnny},
        artist => q{Di-Rect},
        year   => 2007,
        file   => 'dlc55.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Por La Boca Vive El Pez},
        artist => q{Fito & Fitipaldis},
        year   => 2006,
        file   => 'dlc54.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Degenerated},
        artist => q{Backyard Babies},
        year   => 2008,
        file   => 'dlc56.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Light It Up},
        artist => q{Rev Theory},
        year   => 2008,
        file   => 'dlc47.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Because Of You},
        artist => q{Nickelback},
        year   => 2003,
        file   => 'dlc48.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Use Me},
        artist => q{Hinder},
        year   => 2008,
        file   => 'dlc49.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Me And My Gang},
        artist => q{Rascal Flatts},
        year   => 2006,
        file   => 'dlc58.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Ticks},
        artist => q{Brad Paisley},
        year   => 2007,
        file   => 'dlc59.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Hillbilly Deluxe},
        artist => q{Brooks & Dunn},
        year   => 2005,
        file   => 'dlc60.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{What's My Age Again?},
        artist => q{Blink-182},
        year   => 1999,
        file   => 'dlc61.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Lycanthrope},
        artist => q{+44},
        year   => 2006,
        file   => 'dlc62.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Low (Travis Barker Remix) (Feat. T-Pain)},
        artist => q{Flo Rida},
        year   => 2008,
        file   => 'dlc63.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Dimension},
        artist => q{Wolfmother},
        year   => 2006,
        file   => 'dlc64.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Tomorrow},
        artist => q{Silverchair},
        year   => 1995,
        file   => 'dlc65.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Outtathaway!},
        artist => q{The Vines},
        year   => 2002,
        file   => 'dlc66.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{The Turning},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc67.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{I'm Outta Time},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc68.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{(Get Off Your) High Horse Lady},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc69.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Falling Down},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc70.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{To Be Where There's Life},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc71.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Ain't Got Nothin'},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc72.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{The Nature Of Reality},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc73.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Soldier On},
        artist => q{Oasis},
        year   => 2008,
        file   => 'dlc74.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{My Lucky Day},
        artist => q{Bruce Springsteen},
        year   => 2008,
        file   => 'dlc78.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Born To Run},
        artist => q{Bruce Springsteen},
        year   => 1975,
        file   => 'dlc79.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Black Betty},
        artist => q{Ram Jam},
        year   => 1977,
        file   => 'dlc75.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Commotion},
        artist => q{Creedence Clearwater Revival},
        year   => 1969,
        file   => 'dlc76.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Gimme All Your Lovin'},
        artist => q{ZZ Top},
        year   => 1983,
        file   => 'dlc77.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Drive},
        artist => q{Incubus},
        year   => 1999,
        file   => 'dlc85.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{New Slang},
        artist => q{The Shins},
        year   => 2001,
        file   => 'dlc84.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Wonderwall},
        artist => q{Ryan Adams},
        year   => 2004,
        file   => 'dlc83.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Junior's Farm},
        artist => q{Wings},
        year   => 1974,
        file   => 'dlc80.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Hi, Hi, Hi},
        artist => q{Wings},
        year   => 1972,
        file   => 'dlc81.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Jet},
        artist => q{Wings},
        year   => 1973,
        file   => 'dlc82.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Break It Out},
        artist => q{Vanilla Sky},
        year   => 2007,
        file   => 'dlc88.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{In The Shadows},
        artist => q{The Rasmus},
        year   => 2003,
        file   => 'dlc89.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{C'est Comme Ça},
        artist => q{Les Rita Mitsouko},
        year   => 1986,
        file   => 'dlc90.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Old Time Rock & Roll},
        artist => q{Bob Seger & The Silver Bullet Band},
        year   => 1978,
        file   => 'dlc86.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Her Strut},
        artist => q{Bob Seger & The Silver Bullet Band},
        year   => 1980,
        file   => 'dlc87.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Get Out Of Denver},
        artist => q{Bob Seger},
        year   => 1974,
        file   => 'dlc91.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Death Blossoms},
        artist => q{Rise Against},
        year   => 2009,
        file   => 'dlc93.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Ready To Fall},
        artist => q{Rise Against},
        year   => 2006,
        file   => 'dlc94.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Audience Of One},
        artist => q{Rise Against},
        year   => 2008,
        file   => 'dlc95.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Foxey Lady (Live At Woodstock)},
        artist => q{Jimi Hendrix},
        year   => 1969,
        file   => 'dlc92.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Freedom},
        artist => q{Jimi Hendrix},
        year   => 1971,
        file   => 'dlc96.mid.qb',
        },

        {
        game   => 'ghwt-dlc',
        tier   => 18,
        name   => q{Angel},
        artist => q{Jimi Hendrix},
        year   => 1971,
        file   => 'dlc97.mid.qb',
        },

    );
}

1;

