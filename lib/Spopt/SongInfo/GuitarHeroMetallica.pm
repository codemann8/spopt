# $Id: GuitarHeroMetallica.pm,v 1.3 2009-04-28 08:34:48 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/SongInfo/GuitarHeroMetallica.pm,v $

package Spopt::SongInfo::GuitarHeroMetallica;
use strict;

sub new                       { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop                     { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub get_songarr               { my $self = shift; my @out = @{$self->{songarr}}; return @out; }
sub get_songarr_for_game      { my ($self,$game) = @_; my @out = grep { $_->{'game'} eq $game } @{$self->{songarr}}; return @out; } 
sub get_tier_titles_for_game  { my ($self,$game) = @_; my @out = @{$self->{'tier_titles'}{$game}}; return @out; }

sub _init {
    my $self = shift;

    @{$self->{'tier_titles'}{'ghm'}} = (
        'The Forum',
        'Tushino Air Field',
        'Metallica at Tushino',
        'Hammersmith Apollo',
        'Damaged Justice Tour',
        'The Meadowlands',
        'Donnington Park',
        'The Ice Cave',
        'The Stone Nightclub',
    );

    @{$self->{'songarr'}} = (
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{Ace of Spades},
        artist => q{Motörhead},
        year   => 2008,
        file   => 'aceofspades.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{Albatross},
        artist => q{Corrosion of Conformity},
        year   => 1994,
        file   => 'albatross.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{All Nightmare Long},
        artist => q{Metallica},
        year   => 2008,
        file   => 'allnightmarelong.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Am I Evil?},
        artist => q{Diamond Head},
        year   => 1982,
        file   => 'amievil.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{Armed and Ready},
        artist => q{Michael Schenker Group},
        year   => 1980,
        file   => 'armedandready.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Battery},
        artist => q{Metallica},
        year   => 1986,
        file   => 'battery.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 6,
        name   => q{Beautiful Mourning},
        artist => q{Machine Head},
        year   => 2007,
        file   => 'beautifulmourning.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{The Black River},
        artist => q{The Sword},
        year   => 2008,
        file   => 'blackriver.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Blood and Thunder},
        artist => q{Mastodon},
        year   => 2004,
        file   => 'bloodandthunder.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{Broken, Beat & Scarred},
        artist => q{Metallica},
        year   => 2008,
        file   => 'brokenbeatandscarred.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Creeping Death},
        artist => q{Metallica},
        year   => 1984,
        file   => 'creepingdeath.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{Cyanide},
        artist => q{Metallica},
        year   => 2008,
        file   => 'cyanide.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 1,
        name   => q{Demon Cleaner},
        artist => q{Kyuss},
        year   => 1994,
        file   => 'demoncleaner.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 6,
        name   => q{Disposable Heroes},
        artist => q{Metallica},
        year   => 1986,
        file   => 'disposeableheroes.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 6,
        name   => q{Dyer's Eve},
        artist => q{Metallica},
        year   => 1988,
        file   => 'dyerseve.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 2,
        name   => q{Enter Sandman},
        artist => q{Metallica},
        year   => 1991,
        file   => 'entersandman.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 6,
        name   => q{Evil},
        artist => q{Mercyful Fate},
        year   => 2008,
        file   => 'evil.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{Fade to Black},
        artist => q{Metallica},
        year   => 1984,
        file   => 'fadetoblack.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 6,
        name   => q{Fight Fire with Fire},
        artist => q{Metallica},
        year   => 1984,
        file   => 'fightfirewithfire.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 0,
        name   => q{For Whom the Bell Tolls},
        artist => q{Metallica},
        year   => 1984,
        file   => 'forwhomthebelltolls.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{Frantic},
        artist => q{Metallica},
        year   => 2003,
        file   => 'frantic.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{Fuel},
        artist => q{Metallica},
        year   => 1997,
        file   => 'fuel.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{Hell Bent for Leather},
        artist => q{Judas Priest},
        year   => 1978,
        file   => 'hellbentforleather.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Hit the Lights},
        artist => q{Metallica},
        year   => 1983,
        file   => 'hitthelights.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 2,
        name   => q{King Nothing},
        artist => q{Metallica},
        year   => 1996,
        file   => 'kingnothing.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Master of Puppets},
        artist => q{Metallica},
        year   => 1986,
        file   => 'masterofpuppets.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Mercyful Fate (Medley)},
        artist => q{Metallica},
        year   => 1998,
        file   => 'mercyfulfate.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{Mommy's Little Monster (Live)},
        artist => q{Social Distortion},
        year   => 1998,
        file   => 'mommyslittlemonster.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 1,
        name   => q{Mother of Mercy},
        artist => q{Samhain},
        year   => 1986,
        file   => 'motherofmercy.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{My Apocalypse},
        artist => q{Metallica},
        year   => 2008,
        file   => 'myapocalypse.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 1,
        name   => q{No Excuses},
        artist => q{Alice in Chains},
        year   => 1994,
        file   => 'noexcuses.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 2,
        name   => q{No Leaf Clover (Live)},
        artist => q{Metallica},
        year   => 1999,
        file   => 'noleafclover.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 2,
        name   => q{Nothing Else Matters},
        artist => q{Metallica},
        year   => 1991,
        file   => 'nothingelsematters.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{One},
        artist => q{Metallica},
        year   => 1988,
        file   => 'one.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{Orion},
        artist => q{Metallica},
        year   => 1986,
        file   => 'orion.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 2,
        name   => q{Sad But True},
        artist => q{Metallica},
        year   => 1991,
        file   => 'sadbuttrue.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{Welcome Home (Sanitarium)},
        artist => q{Metallica},
        year   => 1986,
        file   => 'sanitarium.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Seek & Destroy},
        artist => q{Metallica},
        year   => 1983,
        file   => 'seekanddestroy.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{Stacked Actors},
        artist => q{Foo Fighters},
        year   => 1999,
        file   => 'stackedactors.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 5,
        name   => q{Stone Cold Crazy},
        artist => q{Queen},
        year   => 1974,
        file   => 'stonecoldcrazy.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{Suicide & Redemption J.H.},
        artist => q{Metallica},
        year   => 2008,
        file   => 'suicideandredemptionj.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 0,
        name   => q{Suicide & Redemption K.H.},
        artist => q{Metallica},
        year   => 2008,
        file   => 'suicideandredemptionk.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{That Was Just Your Life},
        artist => q{Metallica},
        year   => 2008,
        file   => 'thatwasjustyourlife.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{The Boys Are Back in Town},
        artist => q{Thin Lizzy},
        year   => 1976,
        file   => 'theboysareback.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{The Day That Never Comes},
        artist => q{Metallica},
        year   => 2008,
        file   => 'thedaythatnevercomes.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{The End of the Line},
        artist => q{Metallica},
        year   => 2008,
        file   => 'theendoftheline.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{The Judas Kiss},
        artist => q{Metallica},
        year   => 2008,
        file   => 'thejudaskiss.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{The Memory Remains},
        artist => q{Metallica},
        year   => 1997,
        file   => 'thememoryremains.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 6,
        name   => q{The Shortest Straw},
        artist => q{Metallica},
        year   => 1988,
        file   => 'theshorteststraw.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 7,
        name   => q{The Thing That Should Not Be},
        artist => q{Metallica},
        year   => 1986,
        file   => 'thethingthat.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 0,
        name   => q{The Unforgiven},
        artist => q{Metallica},
        year   => 1991,
        file   => 'theunforgiven.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 8,
        name   => q{The Unforgiven III},
        artist => q{Metallica},
        year   => 2008,
        file   => 'theunforgiveniii.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{Toxicity},
        artist => q{System of a Down},
        year   => 2001,
        file   => 'toxicity.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 1,
        name   => q{Tuesday's Gone},
        artist => q{Lynyrd Skynyrd},
        year   => 1973,
        file   => 'tuesdaysgone.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 1,
        name   => q{Turn the Page (Live)},
        artist => q{Bob Seger and the Silver Bullet Band},
        year   => 1976,
        file   => 'turnthepage.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 6,
        name   => q{War Ensemble},
        artist => q{Slayer},
        year   => 1990,
        file   => 'warensemble.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 4,
        name   => q{War Inside My Head},
        artist => q{Suicidal Tendancies},
        year   => 1990,
        file   => 'warinsidemyhead.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 3,
        name   => q{Wherever I May Roam},
        artist => q{Metallica},
        year   => 1991,
        file   => 'whereverimayroam.mid.qb',
        },
        {
        game   => 'ghm',
        tier   => 6,
        name   => q{Whiplash},
        artist => q{Metallica},
        year   => 1983,
        file   => 'whiplash.mid.qb',
        },
    );
}

1;

