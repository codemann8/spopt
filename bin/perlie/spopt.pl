#!/usr/bin/perl5
use Getopt::Long;

################################################################################
## Program: spopt.pl
## Date:    6-2-2007
## Author:  debr (aka M1ster Zer0)
################################################################################

## Data structures
##
## Note:        start                   start beat (fp)
##              len                     length of sustain (fp)
##              notestr                 string of notes that make up the "chord"
##              spflag                  0|1 depending on whether note is part of an SP phrase
##              mult                    multiplier
##              basescore               the score for the note (including multiplier effects) w/o the sustains
##              sustainscore            the score for the sustain part of the note
##              totscore                the total score for the ntoe (sum of the above two)

## Activation:  score                   total score for the activation
##              first_note              first note of the activation
##              last_note               last note of the activation
##              compulsory_sp           manditory SP that must be taken
##              optional_sp_available   whammy sp if we fully whammied every note
##              optional_sp_used        whammy sp that we actually used
##              compressed_flag         flag indicating whether or not activation requires restricted whammying
##              squeeze_flag            flag indicating that some of the notes were "squeeze notes"
##              start_beat              the beat on which the SP should be activated
##              end_beat                the beat on which the SP ends
##              duration_meas           how many measures long is the activation (simply compulsory_sp + optionsal_sp_used)
##              duration_beats          how many beats long is the activation

## Solution:    score                   total score for the solution
##              compulsory_sp           compulsory_sp left over for the next activation
##              optional_sp             optional_sp left over for the next activation
##              path_str                They typical 1-2-2-2-3 SP string that we see delineating the path
##              activations             array of activations above



################################################################################
## Main Program
################################################################################
use strict;
our $TIMING_WINDOW = 1.0/6.0;
our $DIFFICULTY = "expert";
our $SQUEEZE_PERCENT   = 1.00;
our $SQUEEZESP_PERCENT = 1.00;
our $WHAMMY_PERCENT = 1.00;
our $WHAMMY_DELAY = 0.00;
our $DEBUG = 0;
our $DEBUG_PATH_STR = "";

our $FILE = pop @ARGV;

&get_clopt();
my ($rnotes, $rsp, $rb2m, $rm2b, $rbeatspermeas, $rsqueeze) = &parse_midi_file($FILE);
&clear_score_cache();
&set_m2b_b2m_data_structures($rm2b,$rb2m,$rbeatspermeas);
&optimize_sp($rnotes->{$DIFFICULTY},$rsp->{$DIFFICULTY}, $rsqueeze);


################################################################################
# Subroutines
################################################################################
sub get_clopt {
    my $ret = &GetOptions( "diff=s"    =>  \$DIFFICULTY,
	                   "s_per=s"   =>  \$SQUEEZE_PERCENT,
	                   "sp_per"    =>  \$SQUEEZESP_PERCENT,
	                   "wp=f"      =>  \$WHAMMY_PERCENT,
	                   "wd=f"      =>  \$WHAMMY_DELAY,
			   "debug=i"   =>  \$DEBUG,
			   "dpath=s"   =>  \$DEBUG_PATH_STR );
    die "bad clopts" unless $ret;
}


sub optimize_sp {
    my ($rnotes, $rsp, $rsqueeze) = @_;

    ## Initialize the solutions array
    my @solutions = ();
    for my $i ( 0 .. @$rsp ) { $solutions[$i] = []; }
    my $nullsol = { score => 0,
	            compulsory_sp => 0,
	            optional_sp => 0,
	            path_str => "",
		    activations => [] };
    $solutions[0] = [ $nullsol ];

    for my $i ( 0 .. scalar(@$rsp)-1 ) {
	my ($optsp) = &get_optional_sp($rsp,$rnotes,$i,$rsqueeze);
	##my $last_note_sp = &get_note_sp($rnotes->[$rsp->[$i][1]]);
	my $last_note_sp = &get_note_sp($rnotes,$rsp->[$i][1],$rsqueeze);

	if ($DEBUG >= 2) { &print_solution_summary($i,scalar(@$rsp),$solutions[$i]); }

	foreach my $sol (@{$solutions[$i]}) {
	    my $csp = $sol->{compulsory_sp} + 2.0;
	    my $osp = $sol->{optional_sp} + $optsp;
	    $csp = 8.0 if $csp > 8.0;
	    $osp = 8.0-$csp if ($csp + $osp) > 8.0;

	    ## I can't easily filter out solutions that don't have enough SP, since one solution
	    ## might gain enough SP from whammying the front end of the next SP phrase.  Thus,
	    ## we end up wasting some calculations on solutions that don't have enough SP, but such
	    ## is life.
	    for my $j ( 0 .. 4 ) {

		## Check to see if this is the one we want to debug
		my $pathstr = &make_path_str($sol,$csp,$j);
		my $olddebug = $DEBUG;
		if  ( (length($DEBUG_PATH_STR) > 0) and ($DEBUG_PATH_STR eq $pathstr)) {
		    $DEBUG = 3;
		}

		my $compressed_act = ($i < scalar(@$rsp - $j - 1 )) ?
					 &get_compressed_activation($rnotes, $csp, $osp, $rsp->[$i][1], $rsp->[$i+1+$j][0]) : 0;
		my $uncompressed_act = ($i < scalar(@$rsp - $j)) ?
					 &get_uncompressed_activation($rnotes, $rsqueeze, $csp, $osp,
								      $rsp->[$i][1],
								      ($i < scalar(@$rsp-1)) ? $rsp->[$i+1][1] : 1000000,
								      $rsp->[$i+$j][0],
								      ($i < scalar(@$rsp-$j-1)) ? $rsp->[$i+$j+1][0] : 1000000) : 0;

		$DEBUG = $olddebug;

		if ($compressed_act)   { my $s = &make_sol($sol,$compressed_act,$i,$j);   push @{$solutions[$i+$j+1]}, $s; }
		if ($uncompressed_act) { my $s = &make_sol($sol,$uncompressed_act,$i,$j); push @{$solutions[$i+$j+1]}, $s; }
	    }
	    $osp += $last_note_sp;
	    $osp = 8.0-$csp if ($csp + $osp) > 8.0;
	    my $s = &make_save_sp_sol($sol,$csp,$osp);
	    push @{$solutions[$i+1]}, $s;
	}
        for my $j ( $i+1 .. scalar(@$rsp))  {
	    my $pretrim_cnt = scalar(@{$solutions[$j]});
	    &trim_bad_solutions($solutions[$j]);
	    my $posttrim_cnt = scalar(@{$solutions[$j]});
	    if ($DEBUG >= 3) {
	        printf "DEBUG: Triming bad solutions for endpoint $j of \%d. (pretrim:\%d  posttrim:\%d)\n", scalar(@$rsp), $pretrim_cnt, $posttrim_cnt;
	    }
	}
    }
    my $bestsol = &get_best_solution($solutions[-1]);
    &print_song_statistics($rnotes, $rsp) if $DEBUG >= 1;
    &print_solution($bestsol,$rnotes);
}

##sub get_note_sp {
##    my ($n) = (@_);
##    return 0 unless $n->{spflag};
##    my $sp = 2.0 / 7.5 * $WHAMMY_PERCENT * ($n->{len} - $WHAMMY_DELAY);
##    return ($sp < 0) ? 0 : $sp;
##}

sub get_note_sp {
    my ($rnotes,$idx,$rsqueeze) = (@_);
    my $n = $rnotes->[$idx];
    return 0 unless $n->{spflag};
    return 0 unless $n->{len} > 0;

    ## Do squeeze sp
    my $extra = 0;
    if ($SQUEEZESP_PERCENT > 0) {
	$extra = $idx > 0 ? $SQUEEZESP_PERCENT * 2.0/7.5 * $rsqueeze->[int($rnotes->[$idx]{start}+1e-7)] : 0;
	if ( $extra > 0 and 
	     ($rnotes->[$idx-1]{spflag}) and 
	     ($rnotes->[$idx-1]{start} + $rnotes->[$idx-1]{len} > $rnotes->[$idx]{start} - $extra) ) {
            $extra = $rnotes->[$idx]{start} - $rnotes->[$idx-1]{start} - $rnotes->[$idx-1]{len};
	}
    }

    my $sp = 2.0 / 7.5 * $WHAMMY_PERCENT * ($n->{len} - $WHAMMY_DELAY + $extra);
    return ($sp < 0) ? 0 : $sp;
}

sub get_left_partial_sp {
    my ($rnotes,$idx,$start,$rsqueeze) = (@_);
    my $n = $rnotes->[$idx];
    return 0 unless $n->{spflag};
    if ($start >= $n->{start} + $n->{len}) { return &get_note_sp($rnotes,$idx,$rsqueeze); }

    my $extra = 0;
    if ($SQUEEZESP_PERCENT > 0) {
	$extra = $idx > 0 ? $SQUEEZESP_PERCENT * $rsqueeze->[int($rnotes->[$idx]{start}+1e-7)] : 0;
	if ( $extra > 0 and 
	     ($rnotes->[$idx-1]{spflag}) and 
	     ($rnotes->[$idx-1]{start} + $rnotes->[$idx-1]{len} > $rnotes->[$idx]{start} - $extra) ) {
            $extra = $rnotes->[$idx]{start} - $rnotes->[$idx-1]{start} - $rnotes->[$idx-1]{len};
	}
    }

    my $sp = 2.0 / 7.5 * $WHAMMY_PERCENT * ($start - $n->{start} + $extra - $WHAMMY_DELAY);
    return ($sp < 0) ? 0 : $sp;
}

sub print_solution_summary {
    my ($spidx,$numsp,$solarr) = @_;
    printf "Initial Solutions at start of SP phrase \%d of \%d\n", $spidx+1, $numsp;
    foreach my $s (@$solarr) {
	printf "    score: %5d   compsp: %4.2f   optsp: %4.2f\n", $s->{score}, $s->{compulsory_sp}, $s->{optional_sp};
    }
}

sub print_song_statistics {
    my ($rnotes,$rsp) = @_;
    my $fullscore = 0;
    foreach my $n (@$rnotes) { $fullscore += $n->{totscore}; }

    printf "Number of notes: \%d\n", scalar(@$rnotes);
    printf "Number of sp phrases: \%d\n", scalar(@$rsp);
    printf "Perfect score w/o SP: \%d\n\n", $fullscore;

    foreach my $i (0 .. scalar(@$rnotes)-1) {
       printf "%4d %7.2f %5.2f %7.3f %-3s %2s %1dx %4d %4d %4d\n",
	   $i,
	   $rnotes->[$i]{start},
	   $rnotes->[$i]{len},
	   &b2m($rnotes->[$i]{start}),
	   $rnotes->[$i]{notestr},
	   $rnotes->[$i]{spflag} ? "SP" : "--",
	   $rnotes->[$i]{mult},
	   $rnotes->[$i]{basescore},
	   $rnotes->[$i]{sustainscore},
	   $rnotes->[$i]{totscore};
   }
   print "\n";
}

sub print_solution {
    my ($sol,$rnotes) = @_;

    my $fullscore = 0;
    foreach my $n (@$rnotes) { $fullscore += $n->{totscore}; }

    my $basescore = 0;
    foreach my $n (@$rnotes) {
	my $noteinit = length ($n->{notestr}) * 50;
	my $sust     = length ($n->{notestr}) * int ( 25 * $n->{len} + 0.5 + 1e-7 );
	$basescore += ($noteinit + $sust);
    }

    my $lf = $FILE;
    if ($lf =~ m/.*\/(\S+).mid/) { $lf = $1 . ".mid"; }
    printf "File:                    \%s\n", $lf;
    printf "Solution Path:           \%s\n", $sol->{pathstr};
    printf "Estimated Base score     \%6d\n", $basescore;
    printf "Estimated Perfect w/o SP \%6d\n", $fullscore;
    printf "Estimated SP Score       \%6d\n", int($sol->{score});
    printf "Estimated Total Score    \%6d\n", int($sol->{score}) + $fullscore;
    printf "Activations:\n";

    foreach my $i ( 0 .. scalar(@{$sol->{activations}})-1) {
        my $ra = $sol->{activations}[$i];
	my ($start_meas,$end_meas,$sns,$ens,$start_desc,$end_desc) = (0,0,"","","","");

        if ($ra->{start_beat} > $rnotes->[$ra->{left_base}]{start}) {
            $start_meas = &b2m($rnotes->[$ra->{left_base}]{start});
            $sns = $rnotes->[$ra->{left_base}]{notestr};
            $start_desc = sprintf "%-10s", "($sns note)";
        }

        elsif ($ra->{start_beat} > $rnotes->[$ra->{left_base}-1]{start} + $rnotes->[$ra->{left_base}-1]{len}) {
            $start_meas = &b2m($rnotes->[$ra->{left_base}]{start});
            $sns = $rnotes->[$ra->{left_base}]{notestr};
            $start_desc = sprintf "%-10s", "($sns note)";
        }

        elsif ($rnotes->[$ra->{left_base}-1]{len} < 1e-7) {
            $start_meas = &b2m($rnotes->[$ra->{left_base}]{start});
            $sns = $rnotes->[$ra->{left_base}]{notestr};
            $start_desc = sprintf "%-10s", "($sns note)";
        }

        else {
            $start_meas = &b2m($ra->{start_beat});
            $sns = $rnotes->[$ra->{left_base}-1]{notestr};
            $start_desc = sprintf "%-10s", "($sns sust)";
        }

        $ens = $rnotes->[$ra->{right_base}]{notestr};

        if ($ra->{end_beat} <= $rnotes->[$ra->{right_base}]{start} + 1e-7) {
            $end_meas = &b2m($rnotes->[$ra->{right_base}]{start});
            $end_desc = sprintf "%-10s", "($ens note)";
        }

        elsif ($rnotes->[$ra->{right_base}]{len} < 1e-7 ) {
            $end_meas = &b2m($rnotes->[$ra->{right_base}]{start});
            $end_desc = sprintf "%-10s", "($ens note)";
        }

        else {
            $end_meas = &b2m($ra->{end_beat});
            $end_desc = sprintf "%-10s", "($ens sust)";
        }

        printf "  From meas %8.4f $start_desc to meas %8.4f $end_desc  Score: %5d ((%4.1f + %4.1f) * 200 ) \%s\n",
	   $start_meas, $end_meas, $ra->{score}, $ra->{basescore}/200, $ra->{sustainscore}/200, $ra->{compressed_flag} ? "(do not fully whammy)" : "";

	if ($DEBUG > 0) {
	    printf "    debug: %5d (%5d + %5d) %7.3f %7.3f %7.2f %7.2f (%4d,%7.2f,%-3s) (%4d,%7.2f,%-3s)  %1d %1d   %4.2fsp %4.2fsp %4.2fsp\n",
	       $ra->{score},
	       $ra->{basescore},
	       $ra->{sustainscore},
	       &b2m($ra->{start_beat}),
	       &b2m($ra->{end_beat}),
	       $ra->{start_beat},
	       $ra->{end_beat},
	       $ra->{left_base},
	       &b2m($rnotes->[$ra->{left_base}]{start}),
	       $rnotes->[$ra->{left_base}]{notestr},
	       $ra->{right_base},
	       &b2m($rnotes->[$ra->{right_base}]{start}),
	       $rnotes->[$ra->{right_base}]{notestr},
	       $ra->{compressed_flag},
	       $ra->{squeeze_flag},
	       $ra->{compulsory_sp},
	       $ra->{optional_sp_available},
	       $ra->{optional_sp_used};
	}
    }
    printf "\n";
}


sub get_best_solution {
    my ($rsolarr) = @_;
    my @sortedsol = sort { ($b->{score} <=> $a->{score}) ||
	                   ($b->{compulsory_sp} + $b->{optional_sp} <=>
		            $a->{compulsory_sp} + $a->{optional_sp}) } @$rsolarr;
    die "No solutions found" if @sortedsol == 0;
    return $sortedsol[0];
}

sub trim_bad_solutions {
    my ($rsolarr) = @_;
    my @keepers = ();

    my @sortedsol = sort { ($b->{score} <=> $a->{score}) ||
	                   ($b->{compulsory_sp} + $b->{optional_sp} <=>
		            $a->{compulsory_sp} + $a->{optional_sp}) } @$rsolarr;

    my $sp_level = -100;
    foreach my $s (@sortedsol) {
	my $locsp = $s->{compulsory_sp} + $s->{optional_sp};
	if ($locsp > $sp_level) {
	    $sp_level = $locsp;
	    push @keepers, $s;
	}
    }

    @$rsolarr = @keepers;
}

sub make_save_sp_sol {
    my ($ref,$csp,$osp) = @_;
    my $rout = {};
    $rout->{score} = $ref->{score};
    $rout->{compulsory_sp} = $csp;
    $rout->{optional_sp} = $osp;
    $rout->{activations} = [];
    $rout->{pathstr} = $ref->{pathstr};
    foreach my $ra (@{$ref->{activations}}) {
	my $ract = &duplicate_act($ra);
	push @{$rout->{activations}}, $ract;
    }
    return $rout;
    $rout->{pathstr} = $ref->{pathstr};
}

sub make_path_str {
    my ($ref,$csp,$skipidx) = @_;
    my $out = $ref->{pathstr};

    if (length($out) > 0) { $out .= "-"; }

    if    ($csp == 0) { $out .= "0"; }
    elsif ($csp == 2) { $out .= "1"; }
    elsif ($csp == 4) { $out .= "2"; }
    elsif ($csp == 6) { $out .= "3"; }
    elsif ($csp == 8) { $out .= "4"; }
    else              { $out .= "?"; }

    if ($skipidx > 0) { $out .= "-S$skipidx"; }
    return $out;
}

sub make_sol {
    my ($ref,$act,$spidx,$skipidx) = @_;
    my $rout = {};
    $rout->{score} = $ref->{score} + $act->{score};
    $rout->{compulsory_sp} = 0;
    $rout->{optional_sp} = 0;
    $rout->{activations} = [];
    $rout->{pathstr} = &make_path_str($ref,$act->{compulsory_sp},$skipidx);

    foreach my $ra (@{$ref->{activations}}) {
	my $ract = &duplicate_act($ra);
	push @{$rout->{activations}}, $ract;
    }
    my $ract = &duplicate_act($act);
    push @{$rout->{activations}}, $ract;

    return $rout;
}

sub duplicate_act {
    my ($ract) = @_;
    my $rout = {};
    foreach my $k (keys %$ract) { $rout->{$k} = $ract->{$k}; }
    return $rout;
}

sub get_optional_sp {
    my ($rsp,$rnotes,$idx,$rsqueeze) = @_;
    my $out = 0;

    if ($rsp->[$idx][1] > $rsp->[$idx][0]) { 
	for my $i ( $rsp->[$idx][0] .. $rsp->[$idx][1]-1) {
	    ##$out += &get_note_sp($rnotes->[$i]);
	    $out += &get_note_sp($rnotes,$i,$rsqueeze);
	}
    }
    return $out;
}

sub get_compressed_activation {

    my ($rnotes, $csp, $osp, $startidx, $endidx) = @_;
    print("DEBUG: entering get_compressed_activation ($csp,$osp,$startidx,$endidx)\n") if $DEBUG >= 3;
    my $measdiff = &b2m($rnotes->[$endidx]{start}) - &b2m($rnotes->[$startidx]{start}); 
    return 0 if $measdiff < $csp;
    return 0 if $measdiff > $csp + $osp;
    return 0 if ($csp+$osp) < 4 - 1e-7;

    my $basescore = 0;
    my $sustainscore = 0;

    $sustainscore += $rnotes->[$startidx]{sustainscore};

    if (($endidx-$startidx) > 1) {
	for my $i ( $startidx+1 .. $endidx-1 ) {
	    $basescore += $rnotes->[$i]{basescore};
	    $sustainscore += $rnotes->[$i]{sustainscore};
	}
    }

    my $score = $basescore + $sustainscore;
    my $sol = {};

    print("DEBUG:     Compressed activation found (score=$score, start_beat=$rnotes->[$startidx]{start}, duration=$measdiff)\n") if $DEBUG >= 3;
    $sol->{basescore}             = $basescore;
    $sol->{basescore_nosqueeze}   = $basescore;
    $sol->{sustainscore}          = $sustainscore;
    $sol->{score}                 = $score;
    $sol->{left_base}             = $startidx+1;
    $sol->{right_base}            = $endidx-1;
    $sol->{compulsory_sp}         = $csp;
    $sol->{optional_sp_available} = $osp;
    $sol->{optional_sp_used}      = $measdiff - $csp;
    $sol->{compressed_flag}       = 1;
    $sol->{squeeze_flag}          = 0;
    $sol->{start_beat}            = $rnotes->[$startidx]{start};
    $sol->{end_beat}              = $rnotes->[$endidx]{start};
    $sol->{duration_meas}         = $measdiff;
    $sol->{duration_beats}        = $rnotes->[$endidx]{start} - $rnotes->[$startidx]{start};
    return $sol;
}

sub get_uncompressed_activation {
    my ($rnotes, $rsqueeze, $csp, $osp, $start_after, $start_before, $end_after, $end_before) = @_;
    print "DEBUG: entering get_uncompressed_activation ($csp,$osp,$start_after, $start_before, $end_after, $end_before)\n" if $DEBUG >= 3;

    my $start_beat_left  = $rnotes->[$start_after]{start};
    my $start_beat_right = $start_before >= @$rnotes ? $rnotes->[-1]{start} + $rnotes->[-1]{len} : $rnotes->[$start_before]{start};
    my $end_beat_left    = $rnotes->[$end_after]{start};
    my $end_beat_right   = $end_before >= @$rnotes ? $rnotes->[-1]{start} + $rnotes->[-1]{len} + 200 : $rnotes->[$end_before]{start};

    printf "DEBUG:     start:(%.3f,%.3f)  end:(%.3f,%.3f)\n", $start_beat_left, $start_beat_right, $end_beat_left, $end_beat_right if $DEBUG >= 3;


    ## Create the inital array of solutions
    my @beats = map { $start_beat_left + $_/32.0 } ( 0 .. int(($start_beat_right-$start_beat_left)*32.0));
    my @solutions = map { {start_beat=>$_, compressed_flag=>0, compulsory_sp=>$csp} } @beats;

    ## Do a quick check to see if we have a chance of finding something
    my $min_start_beat = &add_measures_to_beat($end_beat_left,-8);
    if ($start_beat_right < $min_start_beat) { return 0; }
    return 0 unless scalar(@solutions);


    ## Calculate the endpoints for each activation
    &add_sp_to_solutions(\@solutions,$rnotes, $start_after,$csp,$osp,$rsqueeze);
    &calc_solution_endpoints(\@solutions, $rnotes);

    ## Eliminate the endpoints that don't fall within the window specified.
    @solutions = grep { $_->{end_beat} >= $end_beat_left and $_->{end_beat} <= $end_beat_right } @solutions;

    ## Eliminate the solutions that don't have enough star power
    @solutions = grep { $_->{compulsory_sp} + $_->{optional_sp_used} >= 4 - 1e-7 } @solutions;

    return 0 unless scalar(@solutions);

    ## Calculate the score for each activation
    ##&calculate_uncompressed_squeezes(\@solutions,$rnotes,$end_before);
    &calculate_uncompressed_scores(\@solutions,$rnotes,$start_after,$end_before,$rsqueeze);
    &calculate_uncompressed_misc_fields(\@solutions);

    foreach my $s (@solutions) {
	if ($DEBUG >= 3) {
	    printf "DEBUG:   %8.3f  %7.3f  %8.4f  %8.4f  %4.2f  %4.2f     %4d  %4d     %5d %5d %5d   %5d  (\%d)\n",
	        $s->{start_beat},
	        $s->{end_beat},
	        &b2m($s->{start_beat}),
	        &b2m($s->{end_beat}),
	        $csp,
                $s->{optional_sp_used},
	        $s->{left_base},
	        $s->{right_base},
	        $s->{basescore_nosqueeze},
	        $s->{basescore},
	        $s->{sustainscore},
	        $s->{score},
	        $s->{calc_iter}; 
	}
    }

    ## Find the best activation
    my $bestscore = -1;
    my $bestsqueeze = 0;
    my $bestidx = -1;
    for my $i ( 0 .. $#solutions) {
	my $squeezepts = $solutions[$i]{basescore} - $solutions[$i]{basescore_nosqueeze};

	if ($solutions[$i]{score} > $bestscore) {
	    $bestscore = $solutions[$i]{score};
	    $bestidx = $i;
	    $bestsqueeze = $squeezepts;
	}

	elsif (($bestscore == $solutions[$i]{score}) and 
	       $squeezepts < $bestsqueeze ) {
	    $bestscore = $solutions[$i]{score};
	    $bestidx = $i;
	    $bestsqueeze = $squeezepts;
        }
    }
    return $solutions[$bestidx];
}

sub calculate_uncompressed_misc_fields {
    my ($rsol) = @_;
    foreach my $s (@$rsol) {
        $s->{duration_meas}  = $s->{compulsory_sp} + $s->{optional_sp_used};
        $s->{duration_beats} = $s->{end_beat} - $s->{start_beat};
    }
}

BEGIN {
    my $calc_iter = 0;

    sub calculate_uncompressed_scores {
    
        my ($rsol,$rnotes,$startafter,$endbefore,$rsqueeze) = @_;
    
        my $left_base_nosqueeze = $startafter+1;
        my $right_base_nosqueeze = $startafter+1;
    
        $endbefore = scalar(@$rnotes) if $endbefore > scalar(@$rnotes);
    
        foreach my $s (@$rsol) {
    	    my $score = 0;
    	    my ($sb,$eb) = map { $s->{$_} } (qw(start_beat end_beat));
    
    	    ## Get the vanilla endpoints w/o squeezes
    	    while (($left_base_nosqueeze  < $endbefore-1) and ($sb > $rnotes->[$left_base_nosqueeze]{start}))     { $left_base_nosqueeze++; }
    	    while (($right_base_nosqueeze < $endbefore-1) and ($eb > $rnotes->[$right_base_nosqueeze + 1]{start}))  { $right_base_nosqueeze++; }
    	    my $left_base = $left_base_nosqueeze;
    	    my $right_base = $right_base_nosqueeze;

	    if ($SQUEEZE_PERCENT > 0) {
    	        ## Now figure out the squeezes -- we go two notes on either side of the 
    	        my $left_squeeze_amt  = $SQUEEZE_PERCENT * $rsqueeze->[int($sb)];
    	        my $right_squeeze_amt = $SQUEEZE_PERCENT * $rsqueeze->[int($eb)];
    
    	        for my $i (0 .. 1) {
    	            last unless $left_base-1 > $startafter;
    	            last unless $rnotes->[$left_base-1]{start} > $sb - $left_squeeze_amt;
    	            $left_base--;
    	        }
    
    	        for my $i (0 .. 1) {
    	            last unless $right_base+1 < $endbefore;
    	            last unless $rnotes->[$right_base+1]{start} < $eb + $right_squeeze_amt;
    	            $right_base++;
    	        }
	    }
    
    	    $s->{left_base_nosqueeze}  = $left_base_nosqueeze;
    	    $s->{right_base_nosqueeze} = $right_base_nosqueeze;
    	    $s->{left_base}            = $left_base;
    	    $s->{right_base}           = $right_base;
    	    $s->{calc_iter}            = $calc_iter; 
	    $calc_iter++;
    
    	    ## Deal with a heinous cornercase
    	    if ($right_base < $left_base) {
    	        $s->{basescore_nosqueeze}  = 0;
    	        $s->{basescore}            = 0;
    	        $s->{sustainscore}         = 0;
    	        $s->{score}                = 0;
    	    }
    
    	    ## Do the base scores
    	    $s->{basescore_nosqueeze}  = &calc_base_run_score($rnotes,$left_base_nosqueeze, $right_base_nosqueeze);
    	    $s->{basescore}            = &calc_base_run_score($rnotes,$left_base,           $right_base);
    
    	    ## Do the sustain scores
    	    $s->{sustainscore} = &calc_sust_run_score($rnotes,$left_base_nosqueeze,$right_base_nosqueeze-1); 
    
    	    ## Now we might have some extra on the end
    	    my $end = $right_base_nosqueeze;
    	    my $endfraction = ($rnotes->[$end]{sustainscore} == 0) ? 0 : ($eb - $rnotes->[$end]{start}) / $rnotes->[$end]{len};
    	    $endfraction = ($endfraction < 0) ? 0 : ($endfraction > 1) ? 1 : $endfraction;
    	    $s->{sustainscore} += $rnotes->[$end]{sustainscore} * $endfraction;
    
    	    ## Now we might have some extra on the beginning
    	    my $lm = $left_base_nosqueeze-1;
    	    if ( ($lm >= 0) and 
    	         ($rnotes->[$lm]{sustainscore} > 0) and
                     ($sb <= $rnotes->[$lm]{start} + $rnotes->[$lm]{len}) ) {
    	        $s->{sustainscore} += int ($rnotes->[$lm]{sustainscore} *($rnotes->[$lm]{start} + $rnotes->[$lm]{len} - $sb) / $rnotes->[$lm]{len});
    	    }
    
    	    $s->{score} = $s->{basescore} + $s->{sustainscore};
    	    $s->{squeeze_flag} =  ( abs($s->{basescore} - $s->{basescore_nosqueeze}) > 0.5 ) ? 1 : 0; 
        }
    }
}

BEGIN {
    my %score_cache = ();
    my %base_cache = ();
    my %sust_cache = ();
    sub clear_score_cache { %score_cache = (); }

    sub calc_base_run_score { return &calc_run_scorex("basescore",@_); }
    sub calc_sust_run_score { return &calc_run_scorex("sustainscore",@_); }
    sub calc_run_score      { return &calc_run_scorex("totscore",@_); }

    sub calc_run_scorex {
	my ($type,$rnotes,$first,$last) = @_;
	return 0 unless $last >= $first;
	return 0 if $first >= @$rnotes;

	if  (not defined $score_cache{$type}{$first}{$last}) {

	    if ($first == $last) {
	        $score_cache{$type}{$first}{$last} = $rnotes->[$first]{$type};
	    }

	    elsif  (defined $score_cache{$type}{$first-1}{$last}) {
	        $score_cache{$type}{$first}{$last} = $score_cache{$type}{$first-1}{$last};
	        $score_cache{$type}{$first}{$last} -= $rnotes->[$first-1]{$type} if $first > 0;
	    }

	    elsif  (defined $score_cache{$type}{$first}{$last-1}) {
	        $score_cache{$type}{$first}{$last} = $score_cache{$type}{$first}{$last-1};
	        $score_cache{$type}{$first}{$last} += $rnotes->[$last]{$type} if $last < @$rnotes;
	    }

	    elsif  (defined $score_cache{$type}{$first-1}{$last-1}) {
	        $score_cache{$type}{$first}{$last} = $score_cache{$type}{$first-1}{$last-1};
	        $score_cache{$type}{$first}{$last} -= $rnotes->[$first-1]{$type} if $first > 0;
	        $score_cache{$type}{$first}{$last} += $rnotes->[$last]{$type} if $last < @$rnotes;
	    }

	    else {
	        $score_cache{$type}{$first}{$last} = 0;
	        for my $i ($first .. $last) {
	            $score_cache{$type}{$first}{$last} += $rnotes->[$i]{$type} if ($i >= 0 and $i < @$rnotes);
	        }
	    }
	}
	return $score_cache{$type}{$first}{$last};
    }
}

sub calc_solution_endpoints {
    my ($rsol,$rnotes) = @_;
    foreach my $s (@$rsol) {
        $s->{end_beat} = &add_measures_to_beat($s->{start_beat},$s->{compulsory_sp}+$s->{optional_sp_used});
    }
}

	##while (($end_note < @$rnotes) and ($s->{end_beat} >= ($rnotes->[$end_note]{start} + $rnotes->[$end_note]{len}))) { $end_note++; }
	##$s->{last_note} = $end_note >= @$rnotes ? scalar(@$rnotes)-1 : $end_note;

sub add_sp_to_solutions {
    my ($rsol,$rnotes,$start_note,$csp,$osp,$rsqueeze) = @_;
    my $curr_note = $start_note;

    ## Add the star power
    foreach my $s (@$rsol) {

	## Move the curr_note idx.  We are only looping over small increments, so it should only be necessary
	## to hit one sustained note each time, but we don't preclude hitting multiple non-sustained notes, even
	## though it shouldn't happen.
	if (($curr_note < @$rnotes) and ($s->{start_beat} >= ($rnotes->[$curr_note]{start} + $rnotes->[$curr_note]{len}))) {
	    ##$osp += $rnotes->[$curr_note]{spflag} ? $rnotes->[$curr_note]{len} * 2.0 / 7.5 : 0;
	    ##$osp += &get_note_sp($rnotes->[$curr_note]);
	    $osp += &get_note_sp($rnotes, $curr_note, $rsqueeze); 
	    while (($curr_note < @$rnotes) and ($s->{start_beat} >= ($rnotes->[$curr_note]{start} + $rnotes->[$curr_note]{len}))) { $curr_note++; }
	}
	## $s->{first_note} = ($curr_note >= @$rnotes) ? scalar(@$rnotes)-1 : $curr_note;

	if ( ($curr_note < @$rnotes) and
	     ($rnotes->[$curr_note]{spflag}) and
             ($s->{start_beat} >  $rnotes->[$curr_note]{start}) and
             ($s->{start_beat} <= $rnotes->[$curr_note]{start} + $rnotes->[$curr_note]{len}) ) {

	     ##my $cur_note_sp = ($s->{start_beat} - $rnotes->[$curr_note]{start}) * 2.0 / 7.5;
	     ##my $cur_note_sp = &get_left_partial_sp($rnotes->[$curr_note],$s->{start_beat});
	    my $cur_note_sp = &get_left_partial_sp($rnotes, $curr_note, $s->{start_beat}, $rsqueeze);
	    $s->{optional_sp_available} = &min(8-$csp,$osp+$cur_note_sp);
	    $s->{optional_sp_used}      = $s->{optional_sp_available};
	    next;
        }

	else {
	    $s->{optional_sp_available} = &min(8-$csp,$osp);
	    $s->{optional_sp_used}      = $s->{optional_sp_available};
	    next;
	}
    }
}

sub min {
    my @a = @_;
    my $min = $a[0];
    foreach my $a (@a) { $min = $a if $a < $min; }
    return $min;
}

sub max {
    my @a = @_;
    my $max = $a[0];
    foreach my $a (@a) { $max = $a if $a > $max; }
    return $max;
}

sub add_measures_to_beat {
    my ($b, $m) = @_;
    return &m2b(&b2m($b) + $m);
}


BEGIN {
    my $rm2b = "";
    my $rb2m = "";
    my $rbpermeas = "";
    sub set_m2b_b2m_data_structures { ($rm2b,$rb2m,$rbpermeas) = @_; }

    sub m2b {
        my ($m) = @_;
        return 0 if $m <= 0;
        my $im = int ($m + 1e-7);
        return $rm2b->{$im} + ($m-$im) * $rbpermeas->{$im};
    }
    
    sub b2m {
        my ($b) = @_;
        return 0 if $b <= 0;
        my $ib = int ($b + 1e-7);
        my $m = $rb2m->{$ib};
        my $im = int ($m + 1e-7);
        return $m + 1.0 * ($b - $ib) / $rbpermeas->{$im};
    }
}


sub parse_midi_file {
    my $file = shift;
    open AAA, $file;
    my $buf = "";
    my @filearr = ();
    while (1) {
        my $len = read AAA, $buf, 1024;
        last if $len == 0;
        my @a = unpack "C*", $buf;
        push @filearr, @a;
    }

    splice @filearr, 0, (8+6+8);
    my $rtempo      = &parse_track(\@filearr);
    splice @filearr, 0, (8);
    my $rnoteevents = &parse_track(\@filearr);

    ## Here we take a crack a creating the note data structure
    my %notes          = ();
    my %sp             = ();
    my %player         = ();
    my %spphrases = ();
    foreach my $ra (@$rnoteevents) {
	my ($ts,$type,$note,$velocity) = @$ra;
	if ($note >= 60 and $note <= 69) {
	    if    ($note == 60) { $notes{easy}{$ts}{G} = $velocity; }
	    elsif ($note == 61) { $notes{easy}{$ts}{R} = $velocity; }
	    elsif ($note == 62) { $notes{easy}{$ts}{Y} = $velocity; }
	    elsif ($note == 63) { $notes{easy}{$ts}{B} = $velocity; }
	    elsif ($note == 64) { $notes{easy}{$ts}{O} = $velocity; }
	    elsif ($note == 67) { $sp{easy}{$ts}       = $velocity; }
	    elsif ($note == 69) { $player{easy}{$ts}   = $velocity; }
	}

	if ($note >= 72 and $note <= 81) {
	    if    ($note == 72) { $notes{medium}{$ts}{G} = $velocity; }
	    elsif ($note == 73) { $notes{medium}{$ts}{R} = $velocity; }
	    elsif ($note == 74) { $notes{medium}{$ts}{Y} = $velocity; }
	    elsif ($note == 75) { $notes{medium}{$ts}{B} = $velocity; }
	    elsif ($note == 76) { $notes{medium}{$ts}{O} = $velocity; }
	    elsif ($note == 79) { $sp{medium}{$ts}       = $velocity; }
	    elsif ($note == 81) { $player{medium}{$ts}   = $velocity; }
	}

	if ($note >= 84 and $note <= 93) {
	    if    ($note == 84) { $notes{hard}{$ts}{G} = $velocity; }
	    elsif ($note == 85) { $notes{hard}{$ts}{R} = $velocity; }
	    elsif ($note == 86) { $notes{hard}{$ts}{Y} = $velocity; }
	    elsif ($note == 87) { $notes{hard}{$ts}{B} = $velocity; }
	    elsif ($note == 88) { $notes{hard}{$ts}{O} = $velocity; }
	    elsif ($note == 91) { $sp{hard}{$ts}       = $velocity; }
	    elsif ($note == 93) { $player{hard}{$ts}   = $velocity; }
	}

	if ($note >= 96 and $note <= 105) {
	    if    ($note == 96)  { $notes{expert}{$ts}{G} = $velocity; }
	    elsif ($note == 97)  { $notes{expert}{$ts}{R} = $velocity; }
	    elsif ($note == 98)  { $notes{expert}{$ts}{Y} = $velocity; }
	    elsif ($note == 99)  { $notes{expert}{$ts}{B} = $velocity; }
	    elsif ($note == 100) { $notes{expert}{$ts}{O} = $velocity; }
	    elsif ($note == 103) { $sp{expert}{$ts}       = $velocity; }
	    elsif ($note == 105) { $player{expert}{$ts}   = $velocity; }
	}
    }

    my %notes2 = ();
    foreach my $difficulty (qw(easy medium hard expert)) {
       my @ts = sort { $a <=> $b } (keys %{$notes{$difficulty}});

       ## Coallesce the notes
       for my $i ( 0 .. scalar(@ts)-1) {
	   ## Is this a note-on event;
	   my $note_on = 0;
	   foreach my $b (qw(G R Y B O)) { $note_on = 1 if $notes{$difficulty}{$ts[$i]}{$b}; }
	   next unless $note_on;
	   my $newnote = {};
	   $newnote->{start}  = $ts[$i]/480.0;

	   if ($i == scalar(@ts)-1) {
	       $newnote->{sustain} = 0;
	       $newnote->{len}  = 0;
	   }

	   elsif (($ts[$i+1] - $ts[$i]) < 240) {
	       $newnote->{sustain} = 0;
	       $newnote->{len}  = 0;
	   }

	   else {
	       $newnote->{sustain} = 1; 
	       $newnote->{len}  = ($ts[$i+1]-$ts[$i])/480.0;
	   }

	   my $notestr = "";
	   foreach my $b (qw(G R Y B O)) { $notestr .= $b if $notes{$difficulty}{$ts[$i]}{$b}; }
	   $newnote->{notestr} = $notestr;
	   $newnote->{spflag} = 0;

	   push @{$notes2{$difficulty}}, $newnote;
       }

       ## Now we deal with the star power phrases
       ## We assume on-off pairs for now -- should probably do some better checking later
       my @spts = sort { $a <=> $b } (keys %{$sp{$difficulty}});
       for (my $i = 0; $i < @spts; $i += 2) {
	   my $spon  = $spts[$i]/480.0;
	   my $spoff = $spts[$i+1]/480.0;
	   my $notefirst = 0;
	   my $notelast = -1;
	   for my $j ( 0 .. scalar(@{$notes2{$difficulty}})-1 ) {
	       if ($notes2{$difficulty}[$j]{start} < $spon)  { $notefirst++; }
	       if ($notes2{$difficulty}[$j]{start} < $spoff) { $notelast++; }
	   }
	   ##print "sp phrase from $spon to $spoff ($notefirst to $notelast)\n";
	   for my $j ($notefirst .. $notelast) { $notes2{$difficulty}[$j]{spflag} = 1; }
	   push @{$spphrases{$difficulty}}, [ $notefirst, $notelast ];
       }

       ## Now we deal with seeding the multipliers and scoring
       for my $i ( 0 .. scalar(@{$notes2{$difficulty}})-1 ) {
	   $notes2{$difficulty}[$i]{mult} = $i < 9 ? 1 : $i < 19 ? 2 : $i < 29 ? 3 : 4;
	   my $chordsize = length $notes2{$difficulty}[$i]{notestr};
           $notes2{$difficulty}[$i]{basescore} = $chordsize * $notes2{$difficulty}[$i]{mult} * 50;
           $notes2{$difficulty}[$i]{sustainscore} = int ( $chordsize * $notes2{$difficulty}[$i]{len} * 25 + 0.5 + 1e-5 ) * $notes2{$difficulty}[$i]{mult};
           $notes2{$difficulty}[$i]{totscore} = $notes2{$difficulty}[$i]{basescore} +  
                                                $notes2{$difficulty}[$i]{sustainscore};
       }

   }


    ## Here we quickly make a data structure for the note events
    my $lastbeat = $notes2{easy}[-1]{start} + 
                   $notes2{easy}[-1]{len} + 100;
    my @tsevents = grep { $_->[1] eq "timesig" } @$rtempo;
    my @quick_bpmeas = ();
    my $marker = 0;
    if (@tsevents > 1) {
	for my $i ( 0 .. @tsevents - 2 ) {
            push @quick_bpmeas, [$tsevents[$i][2], int(($tsevents[$i][0]+1e-5)/480.0), int(($tsevents[$i+1][0]+1e-5)/480.0)];
	}
    }
    my $lastts = @tsevents-1;
    push @quick_bpmeas, [$tsevents[$lastts][2], int(($tsevents[$lastts][0]+1e-5)/480.0), $lastbeat];

    ## Here we tack on 24 4/4/ measures just for kicks
    push @quick_bpmeas, [4, $lastbeat, $lastbeat + 96 ]; 

    my %m2b = ();
    my %b2m = ();
    my %beatspermeas = ();

    my ($measnum,$globalbeatnum) = (1,0,0);


    foreach my $ra (@quick_bpmeas) {
	for my $nummeas (1 .. int(($ra->[2]-$ra->[1]+1e-5)/$ra->[0])) {
	    $beatspermeas{$measnum} = $ra->[0];
	    $m2b{$measnum} = $globalbeatnum;
	    for my $b ( 0 .. $ra->[0]-1 ) {
		$b2m{$globalbeatnum} = $measnum + 1.0 * $b / $ra->[0];
	        $globalbeatnum++;	
	    }
	    $measnum++;
	}
    }

    ## We also need to parse the tempo track for squeezes
    my @tempoevents = grep { $_->[1] eq "tempo" } @$rtempo;
    my $numbeats = scalar(keys(%b2m));
    my $tempoptr = 0;
    my @squeeze = 0;
    for my $i ( 0 .. $numbeats - 1 ) {
	my $miditicks = 480 * $i;
	while ( ($tempoptr < scalar(@tempoevents)-1) and ($tempoevents[$tempoptr][0] + 1e-7 > $miditicks) ) { $tempoptr++; }
        $squeeze[$i] = 0.5 * $TIMING_WINDOW * 1e6 / ($tempoevents[$tempoptr][2] + 1e-7);
    }

   return (\%notes2,\%spphrases,\%b2m,\%m2b,\%beatspermeas,\@squeeze);
}


## Midi messages to parse
## Random text: <delta> 255 1 <num bytes> <text>
## Title track: <delta> 255 3 <num bytes> <text>
## End Delim:   <delta> 255 47 0
## Tempo:       <delta> 255 81 3 xx yy zz
## Time sig:    <delta> 255 88 4 num log2(denom) xx yy
## Note on      <delta> 0x8* <note> <velocity>
## Note off     <delta> 0x9* <note> <velocity>
## Continuation <delta> <note less than 0x80> <velocity>


sub parse_track {
    my ($ra) = @_;
    printf "DEBUG: Enter parse track\n" if $DEBUG >= 3;
    my $timestamp = 0;
    my @out = ();
    my $lastcode = 0;
    while (@$ra > 0) {
	my ($deltalen,$delta) = &parse_delta($ra);
	splice @$ra, 0, $deltalen;
	$timestamp += $delta;
	#printf "len:$deltalen delta:$delta timestamp:$timestamp  " . ("\%d " x 25) . "\n", (@$ra)[0 .. 24];

	if    (($ra->[0] == 255) and ($ra->[1] == 1))  { my $len = $ra->[2]; splice @$ra, 0, (3 + $len); }
	elsif (($ra->[0] == 255) and ($ra->[1] == 3))  { my $len = $ra->[2]; splice @$ra, 0, (3 + $len); }
	elsif (($ra->[0] == 255) and ($ra->[1] == 47)) { splice @$ra, 0, 3; last; }

	elsif (($ra->[0] == 255) and ($ra->[1] == 81)) {
	    my $tempo = ($ra->[3] << 16) + ($ra->[4] << 8) + ($ra->[5]);
	    push @out, [ $timestamp, "tempo", $tempo ];
	    splice @$ra, 0, 6;
	}

	elsif (($ra->[0] == 255) and ($ra->[1] == 88)) {
	    my $num = $ra->[3];
	    my $denom = (1 << $ra->[4]); 
	    push @out, [ $timestamp, "timesig", $num, $denom ];
	    splice @$ra, 0, 7;
	}
	elsif ($ra->[0] >= 128) {
	    $lastcode = $ra->[0];
	    my ($note,$velocity) = ($ra->[1], $ra->[2]);

	    if ($lastcode >= 128 and $lastcode < 144) { $velocity = 0; } 
	    push @out, [ $timestamp, "note", $note, $velocity ];
	    printf "DEBUG: ts:$timestamp beat:%.1f code:\%d   note:$note  velocity:$velocity\n", $timestamp/480, $lastcode if $DEBUG >= 3;
	    splice @$ra, 0, 3;
	}
	else {
	    my ($note,$velocity) = ($ra->[0], $ra->[1]);
	    if ($lastcode >= 128 and $lastcode < 144) { $velocity = 0; } 
	    printf "DEBUG: ts:$timestamp beat:%.1f code:\%d   note:$note  velocity:$velocity\n", $timestamp/480, $lastcode if $DEBUG >= 3;
	    push @out, [ $timestamp, "note", $note, $velocity ];
	    splice @$ra, 0, 2;
	}
    }
    return \@out;
}

sub parse_delta {
    my ($ra) = @_;
    if    ($ra->[0] < 128) { return (1,  $ra->[0]); }
    elsif ($ra->[1] < 128) { return (2, (($ra->[0]-128) << 7) + $ra->[1]); }
    elsif ($ra->[2] < 128) { return (3, (($ra->[0]-128) << 14) + (($ra->[1]-128) << 7) + $ra->[2]); }
    else                   { return (4, (($ra->[0]-128) << 21) + (($ra->[1]-128) << 14) + (($ra->[2]-128) << 7) + $ra->[3]); }

}

