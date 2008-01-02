#!/usr/bin/perl5

use FindBin;
use lib "$FindBin::Bin/lib";
use strict;

use MidiEvent;
use MidiFile;
use Note;
use Pwl;
use Song;
use TempoEvent;
use TimesigEvent;
use SongPainter;
use Image::Magick;
use Optimizer;
use Activation;
use Solution;

use Getopt::Long;

our %DB = ();;
our $MIDIDIR = "/home/Dave/gh/midi";
&setup_db;
foreach my $game (qw(gh-ps2 gh2-ps2 gh2-x360 ghrt80s-ps2)) {
    my @songlist = @{$DB{$game}};
    for my $i (0 .. $#songlist) {
	my $song = $songlist[$i];

	## Read the midi in
	my $mf = new MidiFile;
	my $filename = "$MIDIDIR/$game/$song";
	$mf->file($filename);
	$mf->maxtrack(2);
	$mf->read();

	foreach my $diff (qw(easy medium hard expert)) {
	    &procsong($game,$diff,$i+1,$song,$mf);
	}
    }
}

sub procsong {
    my ($game,$diff,$songnum,$file,$mf) = @_;

    
    ## Create one song with no squeezes 
    my $song1 = new Song;
    if ($game eq "gh-ps2") { $song1->game("gh"); }
    $song1->diff($diff);
    $song1->midifile($mf);
    $song1->squeeze_percent(0);
    $song1->sp_squeeze_percent(0);
    $song1->whammy_delay(0);
    $song1->whammy_percent(1.00);
    $song1->construct_song();
    $song1->calc_unsqueezed_data();
    $song1->calc_squeezed_data();
    $song1->init_phrase_sp_pwls();
    
    ## Create a second song with full squeezes
    my $song2 = new Song;
    if ($game eq "gh-ps2") { $song2->game("gh"); }
    $song2->diff($diff);
    $song2->midifile($mf);
    $song2->squeeze_percent(1.00);
    $song2->sp_squeeze_percent(1.00);
    $song2->whammy_delay(0);
    $song2->whammy_percent(1.00);
    $song2->construct_song();
    $song2->calc_unsqueezed_data();
    $song2->calc_squeezed_data();
    $song2->init_phrase_sp_pwls();
    
    my $sparr1 = $song1->sparr();
    my $sparr2 = $song2->sparr();
    
    my $notearr1 = $song1->notearr();
    my $notearr2 = $song2->notearr();
    
    
    my $max_sp_phrase = scalar(@$sparr1)-1;
    
    for my $i (0 .. $max_sp_phrase) {
        my ($left,$right) = @{$sparr1->[$i]};
        my $tot1 = 0;
        my $tot2 = 0;
        for my $j ($left .. $right) {
    	    $tot1 += $notearr1->[$j]->totSpBeat();
    	    $tot2 += $notearr2->[$j]->totSpBeat();
        }
	$tot1 = sprintf "%.3f", $tot1;
	$tot2 = sprintf "%.3f", $tot2;
        my $str = join ',', ($game,$diff,$songnum,$file,$i,$tot1,$tot2);
        print "$str\n";
    }
}

sub setup_db {
    
    @{$DB{"gh2-ps2"}} = ( "shoutatthedevil.mid",
                          "mother.mid" ,
                          "surrender.mid" ,
                          "woman.mid" ,
                          "tonightimgonna.mid" ,
                          "strutter.mid" ,
                          "heartshapedbox.mid" ,
                          "messageinabottle.mid" ,
                          "youreallygotme.mid" ,
                          "carryonwayward.mid" ,
                          "monkeywrench.mid" ,
                          "thembones.mid" ,
                          "searchanddestroy.mid" ,
                          "tattooedloveboys.mid" ,
                          "warpigs.mid" ,
                          "cherrypie.mid" ,
                          "whowasinmyroom.mid" ,
                          "girlfriend.mid" ,
                          "cantyouhearme.mid" ,
                          "sweetchild.mid" ,
                          "killinginthenameof.mid" ,
                          "johnthefisherman.mid" ,
                          "freya.mid" ,
                          "badreputation.mid" ,
                          "lastchild.mid" ,
                          "crazyonyou.mid" ,
                          "trippinonahole.mid" ,
                          "rockthistown.mid" ,
                          "jessica.mid" ,
                          "stop.mid" ,
                          "madhouse.mid" ,
                          "carrymehome.mid" ,
                          "laidtorest.mid" ,
                          "psychobilly.mid" ,
                          "yyz.mid" ,
                          "beastandtheharlot.mid" ,
                          "institutionalized.mid" ,
                          "misirlou.mid" ,
                          "hangar18.mid" ,
                          "freebird.mid" ,
                          "rawdog.mid" ,
                          "arterialblack.mid" ,
                          "collide.mid" ,
                          "elephantbones.mid" ,
                          "fallofpangea.mid" ,
                          "ftk.mid" ,
                          "gemini.mid" ,
                          "ladylightning.mid" ,
                          "laughtrack.mid" ,
                          "lesstalkmorerokk.mid" ,
                          "jordan.mid" ,
                          "mrfixit.mid" ,
                          "newblack.mid" ,
                          "onefortheroad.mid" ,
                          "parasite.mid" ,
                          "radiumeyes.mid" ,
                          "redlottery.mid" ,
                          "six.mid" ,
                          "soybomb.mid" ,
                          "thelightthatblinds.mid" ,
                          "thunderhorse.mid" ,
                          "trogdor.mid" ,
                          "xstream.mid" ,
                          "yeswecan.mid" ); 

    @{$DB{"gh2-x360"}} = ( "surrender.mid" ,
                           "possum.mid" ,
                           "heartshapedbox.mid",
                           "salvation.mid" ,
                           "strutter.mid" ,
                           "shoutatthedevil.mid" ,
                           "mother.mid" ,
                           "lifewasted.mid" ,
                           "cherrypie.mid" ,
                           "woman.mid" ,
                           "youreallygotme.mid" ,
                           "tonightimgonna.mid" ,
                           "carryonwayward.mid" ,
                           "searchanddestroy.mid" ,
                           "messageinabottle.mid" ,
                           "billiondollar.mid" ,
                           "thembones.mid" ,
                           "warpigs.mid" ,
                           "monkeywrench.mid" ,
                           "hush.mid" ,
                           "girlfriend.mid" ,
                           "whowasinmyroom.mid" ,
                           "cantyouhearme.mid" ,
                           "sweetchild.mid" ,
                           "rockandroll.mid" ,
                           "tattooedloveboys.mid" ,
                           "johnthefisherman.mid" ,
                           "jessica.mid" ,
                           "badreputation.mid" ,
                           "lastchild.mid" ,
                           "crazyonyou.mid" ,
                           "trippinonahole.mid" ,
                           "dead.mid" ,
                           "killinginthenameof.mid" ,
                           "freya.mid" ,
                           "stop.mid" ,
                           "madhouse.mid" ,
                           "trooper.mid" ,
                           "rockthistown.mid" ,
                           "laidtorest.mid" ,
                           "psychobilly.mid" ,
                           "yyz.mid" ,
                           "beastandtheharlot.mid" ,
                           "carrymehome.mid" ,
                           "institutionalized.mid" ,
                           "misirlou.mid" ,
                           "hangar18.mid" ,
                           "freebird.mid" ,
                           "rawdog.mid" ,
                           "arterialblack.mid" ,
                           "collide.mid" ,
                           "drinkup.mid" ,
                           "elephantbones.mid" ,
                           "fallofpangea.mid" ,
                           "ftk.mid" ,
                           "gemini.mid" ,
                           "kicked.mid" ,
                           "ladylightning.mid" ,
                           "laughtrack.mid" ,
                           "lesstalkmorerokk.mid" ,
                           "jordan.mid" ,
                           "mrfixit.mid" ,
                           "newblack.mid" ,
                           "onefortheroad.mid" ,
                           "parasite.mid" ,
                           "radiumeyes.mid" ,
                           "redlottery.mid" ,
                           "six.mid" ,
                           "soybomb.mid" ,
                           "thelightthatblinds.mid" ,
                           "thunderhorse.mid" ,
                           "trogdor.mid" ,
                           "xstream.mid" ,
                           "yeswecan.mid" ,
                           "aceofspades.mid" ,
                           "barkatthemoon.mid" ,
                           "heyyou.mid" ,
                           "frankenstein.mid" ,
                           "killerqueen.mid" ,
                           "takeitoff.mid" ,
                           "higherground.mid" ,
                           "infected.mid" ,
                           "stellar.mid" ,
                           "iwannabesedated.mid" ,
                           "smokeonthewater.mid" ,
                           "yougotanotherthingcomin.mid" ,
                           "famouslastwords.mid" ,
                           "teenagers.mid" ,
                           "thisishowidisappear.mid" ,
                           "burythehatchet.mid" ,
                           "detonation.mid" ,
                           "exsandohs.mid" );

    @{$DB{"gh-ps2"}} = (   "iloverockandroll.mid",
                           "iwannabesedated.mid",
                           "thunderkiss65.mid",
                           "smokeonthewater.mid",
                           "infected.mid",
                           "ironman.mid",
                           "morethanafeeling.mid",
                           "yougotanotherthingcomin.mid",
                           "takemeout.mid",
                           "sharpdressedman.mid",
                           "killerqueen.mid",
                           "heyyou.mid",
                           "stellar.mid",
                           "heartfullofblack.mid",
                           "symphofdestruction.mid",
                           "ziggystardust.mid",
                           "fatlip.mid",
                           "cochise.mid",
                           "takeitoff.mid",
                           "unsung.mid",
                           "spanishcastlemagic.mid",
                           "higherground.mid",
                           "nooneknows.mid",
                           "aceofspades.mid",
                           "crossroads.mid",
                           "godzilla.mid",
                           "texasflood.mid",
                           "frankenstein.mid",
                           "cowboysfromhell.mid",
                           "barkatthemoon.mid",
                           "fireitup.mid",
                           "cheatonthechurch.mid",
                           "cavemanrejoice.mid",
                           "eureka.mid",
                           "allofthis.mid",
                           "behindthemask.mid",
                           "breakingwheel.mid",
                           "callout.mid",
                           "decontrol.mid",
                           "evenrats.mid",
                           "farewellmyth.mid",
                           "flyonthewall.mid",
                           "getready2rokk.mid",
                           "guitarhero.mid",
                           "hey.mid",
                           "sailyourshipby.mid",
                           "storyofmylove.mid" );

@{$DB{"ghrt80s-ps2"}} = (  "bangyourhead.mid",
                           "wegotthebeat.mid",
                           "iran.mid",
                           "ballstothewall.mid",
                           "18andlife.mid",
                           "noonelikeyou.mid",
                           "shakin.mid",
                           "heatofthemoment.mid",
                           "radarlove.mid",
                           "becauseitsmidnite.mid",
                           "holydiver.mid",
                           "turningjapanese.mid",
                           "holdonloosely.mid",
                           "thewarrior.mid",
                           "iwannarock.mid",
                           "whatilikeaboutyou.mid",
                           "synchronicity2.mid",
                           "ballroomblitz.mid",
                           "onlyalad.mid",
                           "roundandround.mid",
                           "aintnothinbut.mid",
                           "lonelyisthenight.mid",
                           "bathroomwall.mid",
                           "losangeles.mid",
                           "wrathchild.mid",
                           "electriceye.mid",
                           "policetruck.mid",
                           "seventeen.mid",
                           "caughtinamosh.mid",
                           "playwithme.mid" );
}
