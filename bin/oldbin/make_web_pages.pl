#!/usr/bin/perl5
use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;
use strict;

our $OUTDIR = "/cygdrive/c/web/GuitarHero";
our $SL = new SongLib;
our %TOPSCORES = ();

&parse_top_scores();
print "Making index pages...\n";
&gen_idx_page("");
&gen_idx_page("1337");
for my $game (qw(gh-ps2 gh2-ps2 gh2-x360 ghrt80s-ps2 gh3-ps2)) {
    foreach my $diff (qw(easy medium hard expert)) {
	print "Making pages for game:$game diff:$diff...\n";
	&gen_page($game,$diff,"");
	&gen_page($game,$diff,"1337");
    }
}

sub parse_top_scores {
    my $file = "$OUTDIR/top_scores.txt";
    open AAA, $file;
    while (<AAA>) {
	chomp;
	my @a = split /\s+/, $_;
	next unless @a >= 4;
	my ($game,$diff,$file,$score) = ($a[0],$a[1],$a[2],$a[3]);
	my $base = $file; $base =~ s/\.mid//;
	$TOPSCORES{$game}{$diff}{$base} = $score;
    }
    close AAA;
}

sub gen_page {
    my ($game,$diff,$leet) = @_;
    my $out = "";
    $out .= &gen_header;
    $out .= &gen_top_text($game,$diff,$leet);
    $out .= &gen_score_table($game,$diff,$leet);
    $out .= &gen_footer;
    open BBB, ">$OUTDIR/$game.$diff$leet.html";
    print BBB $out;
    close BBB;
}

sub gen_idx_page {
    my $leet = shift;
    my $out = "";
    $out .= &gen_header;
    $out .= &gen_top_text("junk","junk",$leet);
    $out .= &gen_footer;
    open BBB, ">$OUTDIR/index$leet.html";
    print BBB $out;
    close BBB;
}

sub gen_header {
    my $out = "";
    $out .= "<html><head><title>Guitar Hero SPs</title><link href=\"Include/styles.css\" rel=\"stylesheet\" type=\"text/css\" /></head><body>\n";
    $out .= qq(<table width="100%" cellpadding="0" cellspacing="0" border="1">\n);
    $out .= qq(<tr><td align="left" class="body">\n);
    $out .= qq(<table cellpadding="20"><tr><td class="normal">\n);
    return $out;
}

sub gen_footer {
    my $out = "</td></tr></table></td></tr></table></body></html>";
    return $out;
}

sub gen_top_text {
    my ($game,$diff,$leet) = @_;
    my $rownum = 0;
    my $out = "";
    my @aa = ();
    foreach my $g (qw(gh-ps2 gh2-ps2 gh2-x360 ghrt80s-ps2 gh3-ps2)) {
	foreach my $d (qw(easy medium hard expert)) {
	    if ($g eq $game and $d eq $diff) { push @{$aa[$rownum]}, "<span class=\"red\">$diff</span>"; }
	    else                             { push @{$aa[$rownum]}, "<a href=$g.$d$leet.html>$d</a>"; }

	}
	$rownum++;
    }
    my @titles = ( "Guitar Hero I -- PS2",
	           "Guitar Hero II -- PS2",
		   "Guitar Hero II -- X360",
		   "Guitar Hero Encore : Rock the 80's",
		   "Guitar Hero III" );

    for my $i ( 0 .. 4 ) {
	my $str = join " | ", @{$aa[$i]};
	$out .= qq(<p><b>$titles[$i]:</b>&nbsp;&nbsp;$str</p>\n);
    }

    return $out;
}

sub gen_score_table {
    my ($game,$diff,$leet) = @_;
    my @tt = $SL->get_tier_titles_for_game($game);
    my @sa = $SL->get_songarr_for_game($game);
    my $maxtier = scalar(@tt)-1;

    my $out = "";
    $out .= qq(<table border="1" cellspacing="0">\n);
    $out .= qq(    <tr height="30" class="headrow">\n);
    $out .= qq(        <th width="200">Song</th>\n);
    $out .= qq(        <th width="75">No SP</th>\n);
    $out .= qq(        <th width="100">Lazy Whammy</th>\n);
    $out .= qq(        <th width="100">No Squeeze<br>[0%/0%]</th>\n);

    if ($game eq "gh3-ps2") {
        $out .= qq(        <th width="100">20% squeeze</th>\n);
        $out .= qq(        <th width="100">40% squeeze</th>\n);
        $out .= qq(        <th width="100">60% squeeze</th>\n);
        $out .= qq(        <th width="100">80% squeeze</th>\n);
        $out .= qq(        <th width="100">100% squeeze</th>\n);
    }

    else {
        $out .= qq(        <th width="100">Big Squeeze<br>[60%/0%]</th>\n);
        $out .= qq(        <th width="100">Bigger Squeeze<br>[60%/60%]</th>\n);
        $out .= qq(        <th width="100">Nearly Ideal<br>[80%/80%]</th>\n);
        $out .= qq(        <th width="100">Upper Bound<br>[100%/100%]</th>\n);
    }
    $out .= qq(        <th width="75">Top Score<br>Snapshot</th>\n);
    $out .= qq(    </tr>\n);
    for my $i (0 .. $maxtier) {
	my $tier_title = $tt[$i];
	$out .= qq(    <tr height="30">\n);
	$out .= qq(        <td colspan=") . ($game eq "gh3-ps2" ? 6 : 5) . qq(" class="tier1" align="left" style="border-right: none 1px #000;">$tier_title</td>\n);
	$out .= qq(        <td colspan="4" class="tier2" align="center" style="border-left: none 1px #000;">&nbsp;</td>\n);
	$out .= qq(    </tr>\n);

	my @songs = grep { $_->{tier} == $i } @sa;

	my %sss = ();
	foreach my $rs (@songs) {
	    my $basefile = $rs->{file}; $basefile =~ s/.mid$//;

	    my @scorelist = (qw(lazy-whammy no-squeeze big-squeeze bigger-squeeze nearly-ideal upper-bound));
	    if ($game eq "gh3-ps2") { @scorelist = (qw(lazy-whammy no-squeeze twenty-zero forty-zero sixty-zero eighty-zero hundred-zero)); }

	    my ($nospscore,@scores) = &get_scores($game,$diff,$basefile,\@scorelist);
	    for (my $i = 0; $i < @scorelist; $i++) { $sss{$scorelist[$i]} = $scores[$i]; }

	    for (my $i = 0; $i < @scorelist-1; $i++) {
	        my ($l,$r) = ($scorelist[$i],$scorelist[$i+1]);
		my $sl = $scores[$i];
		my $sr = $scores[$i+1];
		next if $sl <= $sr;
		my $difference = $sl - $sr;
		##printf "ERROR $game $basefile $diff $l:$sl $r:$sr\n", $game, $diff, $l ;
		printf "ERROR %-8s %-6s %4d %-12s > %-12s -- $basefile $l:$sl $r:$sr\n", $game, $diff, $difference, $l, $r;
	    }

	    my $title = $rs->{name};
	    my $topscore = $TOPSCORES{$game}{$diff}{$basefile};
	    my $nospclass = $topscore >  $nospscore + 20 ? "greencell" :
	                    $topscore >  $nospscore + 0 ?  "yellowcell" :
	                    $topscore == $nospscore ?      "brightyellowcell" :
	                    $topscore >  $nospscore - 20 ? "yellowcell" : "redcell";
			    
	    $out .= qq(    <tr height="30">\n);
	    $out .= qq(        <td align="center">$title</td>\n);
	    $out .= qq(        <td align="center" class=$nospclass><a href="$game/$diff/$basefile.blank.png">$nospscore</a></td>\n);
	    foreach my $alg (@scorelist) {
		my $score = $sss{$alg};
		my $txt   = "$game/$diff/$basefile.$alg.summary.html";
		my $pic   = "$game/$diff/$basefile.$alg.best.png";
	        my $classtag =  $topscore >  $score + 20 ? "greencell" :
	                        $topscore >  $score + 0 ?  "yellowcell" :
	                        $topscore == $score ?      "brightyellowcell" :
	                        $topscore >  $score - 20 ? "yellowcell" : "redcell";
		if ($game eq "gh3-ps2" and not $leet) {
		     $out .= qq(        <td align="center" class=$classtag>$score</td>\n);
	        }

		else {
		     $out .= qq(        <td align="center" class=$classtag><a href="$pic">$score</a> <a href="$txt">TXT</a></td>\n);
		}
	    }
	    $out .= qq(        <td align="center">$topscore</td>\n);
	    $out .= qq(    </tr>\n);
	}
    }
    $out .= qq(</table>\n);
    return $out;
}

sub get_scores {
    my ($game,$diff,$basefile,$ralglist) = @_;
    my $nospscore = 0;
    my @algscores = ();
    foreach my $alg (@$ralglist) {
	my $file = "$OUTDIR/$game/$diff/$basefile.$alg.summary.html";
	if (not -e $file) { $file = "$OUTDIR/$game-hidden-dragon/$diff/$basefile.$alg.summary.html"; }
	open QQQ, "$file";
	my @lines = <QQQ>; chomp @lines;
	close QQQ;
	my @spscores  = grep { m/Estimated Perfect w.o SP/ } @lines;
	my @totscores = grep { m/Estimated Total Score/    } @lines;
	$spscores[0] =~ m/SP\s+(\d+)/; $nospscore = $1;
	$totscores[0] =~ m/Total Score\s+(\d+)/; push @algscores, $1;
    }
    return ($nospscore,@algscores);
}
