#!/usr/bin/perl5

our @SONGS = ( "iloverockandroll.mid",
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

foreach my $s (@SONGS) {
    my $dir1 = "/cygdrive/c/web/GuitarHeroRev0.7/gh-ps2";
    my $dir2 = "/cygdrive/c/web/GuitarHero/gh-ps2";
    my $base = $s; $base =~ s/\.mid.*$//;
    foreach my $diff (qw(easy medium hard expert)) {
	foreach my $alg (qw(lazy-whammy no-squeeze big-squeeze bigger-squeeze nearly-ideal upper-bound)) {
	    my $f1 = "$dir1/$diff/$base.$alg.summary.html";
	    my $f2 = "$dir2/$diff/$base.$alg.summary.html";
	    my ($p1,$s1) = &get_path_and_score($f1);
	    my ($p2,$s2) = &get_path_and_score($f2);
	    printf "%-25s %-6s %-15s %4d ($p1/$p2 $s1/$s2)\n", $base, $diff, $alg, $s2-$s1; 
	}
    }
}

sub get_path_and_score {
    my $file = shift;
    open AAA, $file;
    my @aa = <AAA>; chomp @aa;
    close AAA;

    my @paths  = grep { m/Solution Path:/ } @aa;
    my @scores = grep { m/Estimated Total Score/ } @aa;

    $paths[0]  =~ /Solution Path:\s+(\S+).br./; my $path = $1;
    $scores[0] =~ /Estimated Total Score\s+(\d+)/; my $score = $1;
    return ($path,$score);
}
