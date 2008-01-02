#!/usr/bin/perl5
use FindBin;
use FileHandle;
use lib "$FindBin::Bin/../lib";
use SongLib;
use Song;
use MidiFile;
use QbFile;
use Pwl;
use strict;

autoflush STDOUT 1;
our $MIDIDIR = "/home/Dave/gh/midi";
our $QBDIR = "/home/Dave/gh/qb";

our $SL = new SongLib;
my $game = "gh3-ps2";
my @songarr = $SL->get_songarr_for_game($game);
@songarr = (@songarr);

foreach my $song (@songarr) {
	
    my $file  = $song->{file};
    ##next unless $file =~ /storyofmylife/;
    my $sust = $song->{sust};
    my $filename = "$QBDIR/$game/$file.qb.ps2";

    ##print "Reading $file...\n";

    my $mf = new QbFile;
    $mf->file($filename);
    $mf->sustainthresh($sust);
    $mf->read();

    ## Create the beat pwls
    my $beatlepwl = Pwl->new();
    my $beatgepwl = Pwl->new();
    my $rba = $mf->{_beat};
    my $nb = scalar(@$rba);
    $beatlepwl->add_point(0,0);
    for my $i (0 .. $nb-1) {
	if ($i != 0)     { $beatlepwl->add_point($rba->[$i]-0.001,$rba->[$i-1]); }
	if ($i != $nb-1) { $beatgepwl->add_point($rba->[$i]-0.001,$rba->[$i+1]); }
	$beatlepwl->add_point($rba->[$i],$rba->[$i]);
	$beatgepwl->add_point($rba->[$i],$rba->[$i]);
    }



    my @bases = ();
    my @sustains = ();

    ## foreach my $diff (qw(easy medium hard expert)) {
    foreach my $diff (qw(easy medium hard expert)) {
	my @sss = ();
        my $song = new Song;
        $song->game("gh3");
        $song->diff($diff);
        $song->midifile($mf);
        $song->filetype("qb");
        $song->construct_song();

        my $na = $song->notearr();
        my $basescore = 0;
	my $numsust = 0;
        foreach my $n (@$na) {
	    my $idx = $n->idx();
	    my $msstart = $mf->{_notes}{$diff}[$idx][0];
	    my $mslen   = $mf->{_notes}{$diff}[$idx][1];
	    my $startlebeat = int($beatlepwl->interpolate($msstart)+0.1);
	    my $startgebeat = int($beatgepwl->interpolate($msstart)+0.1);
	    my $endlebeat   = int($beatlepwl->interpolate($msstart+$mslen)+0.1);
	    my $endgebeat   = int($beatgepwl->interpolate($msstart+$mslen)+0.1);

	    my $st = $n->startTick();
	    my $et = $n->endTick();
	    next unless ($et-$st) > 32;
	    my $score = ($et-$st)/480.0*25;
	    my $bv = 0;
	    my $str = "";
	    if ($n->green())  { $bv += 1;  $str .= "G"; }
	    if ($n->red())    { $bv += 2;  $str .= "R"; }
	    if ($n->yellow()) { $bv += 4;  $str .= "Y"; }
	    if ($n->blue())   { $bv += 8;  $str .= "B"; }
	    if ($n->orange()) { $bv += 16; $str .= "O"; }
	    push @sss, [$song->t2m($st), $score, $score-int($score+0.49999), $bv, $str, $msstart, $mslen, $startlebeat, $startgebeat, $endlebeat, $endgebeat ];
	    ##printf "%7.3f   %7.3fpoints\n", $song->t2m($st), ($et-$st)/480.0*25;

	    $numsust++ if $n->sustain(); 
	    $basescore += $n->baseTotScore();
	}
	push @bases, $basescore;
	push @sustains, $numsust;

	##print "file:$file diff:$diff\n";
	@sss = sort { $b->[2] <=> $a->[2] or $a->[0] <=> $b->[0] } @sss;
	##foreach my $rs (@sss) { printf "meas %7.3f   %.10f raw points\n", $rs->[0], $rs->[1]; }
	foreach my $rs (@sss) { printf "$file,$diff,%7.3f,%14.10f,\%d,\%s,\%d,\%d,\%d,\%d,\%d,\%d\n", $rs->[0], $rs->[1], (@$rs)[3..10]; }
	##print "\n\n\n";

	$song->calc_unsqueezed_data();
    }

    ##printf "%-30s %6d  %6d  %6d  %6d      %3d %3d %3d %3d\n", $file, @bases, @sustains;


}

