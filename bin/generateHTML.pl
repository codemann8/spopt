#!/usr/bin/env perl
# $Id: generateHTML.pl,v 1.1 2008-09-14 14:42:32 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/generateHTML.pl,v $

use strict;
use warnings;

use Config::General;
use File::Basename;

use FindBin;
use lib "$FindBin::Bin/../lib";
use SongLib;

my $version = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf '%d.'.'%d'x$#r,@r };

my %TOPSCORES = ();

my @games = 
(   
    { 'name' => 'gh-ps2',        'title' => 'Guitar Hero I -- PS2'              },
    { 'name' => 'gh2-ps2',       'title' => 'Guitar Hero II -- PS2'             },
    { 'name' => 'gh2-x360',      'title' => 'Guitar Hero II -- X360'            },
    { 'name' => 'ghrt80s-ps2',   'title' => 'Guitar Hero Encore : Rock the 80s' },
    { 'name' => 'gh3-ps2',       'title' => 'Guitar Hero III'                   },
    { 'name' => 'gh3-dlc',       'title' => 'Guitar Hero III -- DLC'            },
    { 'name' => 'gh3-aerosmith', 'title' => 'Guitar Hero: Aerosmith'            },
);

my @diffs = qw(easy medium hard expert);

sub usage {
    my $filename = basename( $0 );
    print <<END;
$filename v$version

USAGE: $filename <config_file>
END
    exit;
}

my $configFile = shift;
&usage unless defined $configFile;
unless ( -f $configFile && -r $configFile ) {
    print "Configuration file does not exist or is not readable.\n";
    exit 1;
}

my %config = new Config::General( $configFile )->getall;

my $GAME_REGEX = defined $config{'GAME_REGEX'} ? $config{'GAME_REGEX'} : qw{.*};
my $DIFF_REGEX = defined $config{'DIFF_REGEX'} ? $config{'DIFF_REGEX'} : qw{.*};
my $TIER_REGEX = defined $config{'TIER_REGEX'} ? $config{'TIER_REGEX'} : qw{.*};
my $OUTPUT_DIR = defined $config{'OUTPUT_DIR'} ? $config{'OUTPUT_DIR'} : qw{.};

my $SL = new SongLib;

&parse_top_scores();

# print "Making index pages...\n";
# &gen_idx_page;

foreach my $game_hash ( @games ) {
    my $game  = $game_hash->{'name'};
    my $title = $game_hash->{'title'};

    next unless $game =~ /$GAME_REGEX/;

    foreach my $diff ( @diffs) {
        next unless $diff =~ /$DIFF_REGEX/;

	print "Generating pages for $title ($game) $diff ...\n";
	&gen_page($game,$diff);
    }
}

exit;

sub parse_top_scores {
    my $file = "$OUTPUT_DIR/top_scores.txt";
    return unless -f $file;
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

sub gen_idx_page {
    my $out = "";
    $out .= &gen_header;
    $out .= &gen_top_text("junk","junk");
    $out .= &gen_footer;
    open BBB, ">$OUTPUT_DIR/index.html";
    print BBB $out;
    close BBB;
}

sub gen_page {
    my ($game,$diff) = @_;

    my $filename = "$OUTPUT_DIR/$game.$diff.html";

    open FILE, ">$filename" or die "Couldn't open $filename for writing: $!\n";

    print FILE &gen_header,
               &gen_top_text( $game, $diff ), 
               &gen_score_table( $game, $diff ),
               &gen_footer;

    close FILE;
}

sub gen_header {
    my $out = 
<<END;
<html>
    <head>
        <title>Guitar Hero SPs</title>
        <link href="/css/oldstyles.css" rel="stylesheet" type="text/css" />
    </head>
    <body>
        <table width="100%" cellpadding="0" cellspacing="0" border="1">
            <tr>
                <td align="left" class="body">
                    <table cellpadding="20">
                        <tr>
                            <td class="normal">
END
    return $out;
}

sub gen_footer {
    my $out =
<<END;
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
</html>
END
    return $out;
}

sub gen_top_text {
    my ($game,$diff) = @_;
    my $rownum = 0;
    my $out = qw(); 

    foreach my $games_hash ( @games ) {
        my $g = $games_hash->{'name'};
        my $t = $games_hash->{'title'};
        
        $out .= '<p><b>' . $t . ':</b>&nbsp;&nbsp;';

        my $first = 0;
	foreach my $d ( @diffs ) {
            if ( $first ) {
                $out .= ' | ';
            }
            else {
                $first = 1;
            }
	    unless ( $g eq $game and $d eq $diff ) {
                $out .= "<a href=$g.$d.html>$d</a>";
            }
	    else {
                $out .= '<span class="red">' . $d . '</span>';
            }
	}
        $out .= "</p>\n";
    }

    return $out;
}

sub gen_score_table {
    my ($game,$diff) = @_;
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

    if ( $game =~ m/^gh3.*/ ) {
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
    for my $tier (0 .. $maxtier) {
	my $tier_title = $tt[$tier];
	$out .= qq(    <tr height="30">\n);
	$out .= qq(        <td colspan=") . ( $game =~ m/^gh3.*/ ? 6 : 5) . qq(" class="tier1" align="left" style="border-right: none 1px #000;">$tier_title</td>\n);
	$out .= qq(        <td colspan="4" class="tier2" align="center" style="border-left: none 1px #000;">&nbsp;</td>\n);
	$out .= qq(    </tr>\n);

	my @songs = grep { $_->{'tier'} == $tier } @sa;

	my %sss = ();
	foreach my $rs (@songs) {
	    my $basefile = $rs->{file}; $basefile =~ s/.mid$//;

	    my @scorelist = (qw(lazy-whammy no-squeeze big-squeeze bigger-squeeze nearly-ideal upper-bound));
	    if ( $game =~ m/^gh3.*/ ) { @scorelist = (qw(lazy-whammy no-squeeze twenty-zero forty-zero sixty-zero eighty-zero hundred-zero)); }

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
            my $nospclass = "redcell";
	    if ( defined $topscore ) {
                $nospclass = $topscore >  $nospscore + 20 ? "greencell" :
	            $topscore >  $nospscore + 0 ?  "yellowcell" :
	            $topscore == $nospscore ?      "brightyellowcell" :
	            $topscore >  $nospscore - 20 ? "yellowcell" : "redcell";
            }
			    
	    $out .= qq(    <tr height="30">\n);
	    $out .= qq(        <td align="center">$title</td>\n);
	    $out .= qq(        <td align="center" class="$nospclass"><a href="$game/$diff/$basefile.blank.png">$nospscore</a></td>\n);
	    foreach my $alg (@scorelist) {
		my $score = $sss{$alg};
		my $txt   = "$game/$diff/$basefile.$alg.summary.html";
		my $pic   = "$game/$diff/$basefile.$alg.best.png";
	        my $classtag = "redcell";
                if ( defined $topscore ) {
                    my $classtag =  $topscore >  $score + 20 ? "greencell" :
                                    $topscore >  $score + 0 ?  "yellowcell" :
                                    $topscore == $score ?      "brightyellowcell" :
                                    $topscore >  $score - 20 ? "yellowcell" : "redcell";
                }
		#if ( $game =~ m/^gh3.*/ ) {
		     $out .= qq(        <td align="center" class=$classtag><a href="$pic">$score</a> <a href="$txt">TXT</a></td>\n);
		#}
	    }
	    if ( defined $topscore ) {
                $out .= qq(        <td align="center">$topscore</td>\n);
            }
            else {
                $out .= qq(        <td align="center">N/A</td>\n);
            }
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
	my $file = "$OUTPUT_DIR/$game/$diff/$basefile.$alg.summary.html";
	# if (not -e $file) { $file = "$OUTPUT_DIR/$game-hidden-dragon/$diff/$basefile.$alg.summary.html"; }
	open QQQ, "$file" or die "Couldn't open $file: $!\n";
	my @lines = <QQQ>; chomp @lines;
	close QQQ;
	my @spscores  = grep { m/Estimated Perfect w.o SP/ } @lines;
	my @totscores = grep { m/Estimated Total Score/    } @lines;
	$spscores[0] =~ m/SP\s+(\d+)/; $nospscore = $1;
	$totscores[0] =~ m/Total Score\s+(\d+)/; push @algscores, $1;
    }
    return ($nospscore,@algscores);
}
