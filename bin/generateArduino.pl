#!/usr/bin/env perl
# $Id: generateArduino.pl,v 1.1 2012-05-18 06:46:43 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/generateArduino.pl,v $
#
# Generate Arduino commands based on game files to drive guitar hero controller

use strict;
use warnings;

my $DEBUG = 1;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Spopt;

use Config::General;
use File::Basename;

my $version = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf '%d.'.'%d'x$#r,@r };

my $GHROOT = "$FindBin::Bin/..";

my $GLOBAL_CONFIG_FILE = "$GHROOT/cfg/spoptGlobalSettings.cfg";
my %GLOBAL_CONFIG = new Config::General( $GLOBAL_CONFIG_FILE )->getall
    or die "Could not open global config file: $!\n";

my $GAMEFILEROOT = join '/', $GHROOT,$GLOBAL_CONFIG{'ASSETS'},$GLOBAL_CONFIG{'GAMEFILES'};

my %ALGORITHM = %{ $GLOBAL_CONFIG{'ALGORITHM'} };
my %GAME = %{ $GLOBAL_CONFIG{'GAME'} };
my %CHART = %{ $GLOBAL_CONFIG{'CHART'} };

sub usage {
    my $self = basename( $0 );
    print <<END;
$self v$version by tma 2012

USAGE: $self <game code> <song_file> <difficulty> <chart>
END
    exit;
}

my $game = shift;

my $songFile = shift;
&usage unless defined $songFile;
unless ( -f $songFile && -r $songFile ) {
    print "Song file does not exist or is not readable.\n";
    exit 1;
}

my $difficulty = shift;

my $chart = shift;

my $songH = readGamefile( $songFile, $game );

my $song = new Spopt::Song;
$song->game( $GAME{$game}->{'optimizer'} );
$song->filetype( $GAME{$game}->{'type'} );
$song->diff( $difficulty );
$song->chart( $chart );
$song->midifile( $songH );
# $song->squeeze_percent();
# $song->sp_squeeze_percent();
# $song->whammy_delay();
# $song->whammy_percent();

$song->construct_song();
# $song->calc_unsqueezed_data();
# $song->calc_squeezed_data();
# $song->init_phrase_sp_pwls();

my $notes = $song->notearr();
my $timesigs = $song->timesigarr();
my $tempos = $song->tempoarr();

my $NO_EVENT = 99999999; # tick value higher than any song will ever be to simplify comparisons for non-existent events
my $MS_PER_MINUTE = 60000000; # microseconds in a minute
my $tpqn = 480; # ticks per quarter note, constant

my $loop_tempo = int ( $MS_PER_MINUTE / 100 ); # default 100 beats per minute
my $beats_per_measure = 4; # aka 4/4 time

my $last_event = 0;
my $ms = 0;

# note status (== NO_EVENT means note is off)
my %note_hash = (
    'g' => $NO_EVENT,
    'r' => $NO_EVENT,
    'y' => $NO_EVENT,
    'b' => $NO_EVENT,
    'o' => $NO_EVENT,
    'p' => $NO_EVENT, 
);

while ( 1 ) {
    last unless scalar @$notes;
    my $note = shift @$notes;
    my $note_start_tick = $note->{'startTick'};
    $DEBUG > 1 && print "note   : $note_start_tick\n";

    my $timesig = shift ( @$timesigs ) if scalar @$timesigs;
    my $sig_tick = $NO_EVENT;
    if ( $timesig ) {
        $sig_tick = $timesig->{'tick'};
    }
    $DEBUG > 1 && print "timesig: $sig_tick\n" unless $sig_tick == $NO_EVENT;

    my $tempo = shift ( @$tempos ) if scalar @$tempos;
    my $tempo_tick = $NO_EVENT;
    if ( $tempo ) {
        $tempo_tick = $tempo->{'tick'};
    }
    $DEBUG > 1 && print "tempo  : $tempo_tick\n" unless $tempo_tick == $NO_EVENT;

    my $this_event_tick = 0;
    my $this_tempo = $loop_tempo;
    my $event_type = '';
    my $event_text = '';

    if (
        $sig_tick <= $tempo_tick      && 
        $sig_tick <= $note_start_tick
    ) {
        # handle time signature (actually beats per measure) changes
        $this_event_tick = $sig_tick;

        unshift (@$notes, $note);
        unshift (@$tempos, $tempo) unless $tempo_tick == $NO_EVENT;

        $event_type = 'TIMESIG';
        $event_text = "----- - $timesig->{'bpm'} beats per measure";

        $beats_per_measure = $timesig->{'bpm'};
    }
    elsif ( $tempo_tick <= $note_start_tick ) {
        # handle tempo changes
        $this_event_tick = $tempo_tick;

        unshift (@$notes, $note);
        unshift (@$timesigs, $timesig) unless $sig_tick == $NO_EVENT;

        $event_type = 'TEMPO';
        $event_text = "----- - $tempo->{'tempo'} (~" . 
            int( $MS_PER_MINUTE / $tempo->{'tempo'} + 0.5 ) . " bpm)";

        $loop_tempo = $tempo->{'tempo'};
    }
    elsif (
        $note_hash{'g'} <= $note_start_tick ||
        $note_hash{'r'} <= $note_start_tick ||
        $note_hash{'y'} <= $note_start_tick ||
        $note_hash{'b'} <= $note_start_tick ||
        $note_hash{'o'} <= $note_start_tick ||
        $note_hash{'p'} <= $note_start_tick
    ) {
        # handle note off events
        my @sorted_notes = sort { $note_hash{$a} <=> $note_hash{$b} } keys %note_hash; # sort by tick value
        my $noteoff_tick = $note_hash{ $sorted_notes[0] };
        $note_hash{ $sorted_notes[0] } = $NO_EVENT;
        my %actual_notes = ( shift @sorted_notes => 1 );
        for my $other_notes ( @sorted_notes ) {
            if ( $note_hash{ $other_notes } == $noteoff_tick ) {
                $actual_notes{ $other_notes } = 1;
                $note_hash{ $other_notes } = $NO_EVENT;
            }
            else {
                last;
            }
        }

        $this_event_tick = $noteoff_tick;

        unshift (@$notes, $note);
        unshift (@$timesigs, $timesig) unless $sig_tick == $NO_EVENT;
        unshift (@$tempos, $tempo) unless $tempo_tick == $NO_EVENT;

        my $display_note;
        $display_note .= $actual_notes{'g'} ? 'g' : '-';
        $display_note .= $actual_notes{'r'} ? 'r' : '-';
        $display_note .= $actual_notes{'y'} ? 'y' : '-';
        $display_note .= $actual_notes{'b'} ? 'b' : '-';
        $display_note .= $actual_notes{'o'} ? 'o' : '-';
        $display_note .= $actual_notes{'p'} ? ' p' : ' -';
        $event_type = 'NOTEOFF';
        $event_text = $display_note;
    }
    else {
        # handle notes
        $this_event_tick = $note_start_tick;
        my $this_end_note_tick = 
            $note_start_tick == $note->{'endTick'}  ?
            $note_start_tick + 1 :
            $note->{'endTick'};

        unshift (@$tempos, $tempo) unless $tempo_tick == $NO_EVENT;
        unshift (@$timesigs, $timesig) unless $sig_tick == $NO_EVENT;

        my $display_note;
        if ( $note->{'green'} ) {
            $display_note .= 'G';
            $note_hash{'g'} = $this_end_note_tick;
        }
        else {
            $display_note .=  '-';
        }
        if ( $note->{'red'} ) {
            $display_note .= 'R';
            $note_hash{'r'} = $this_end_note_tick;
        }
        else {
            $display_note .=  '-';
        }
        if ( $note->{'yellow'} ) {
            $display_note .= 'Y';
            $note_hash{'y'} = $this_end_note_tick;
        }
        else {
            $display_note .=  '-';
        }
        if ( $note->{'blue'} ) {
            $display_note .= 'B';
            $note_hash{'b'} = $this_end_note_tick;
        }
        else {
            $display_note .=  '-';
        }
        if ( $note->{'orange'} ) {
            $display_note .= 'O';
            $note_hash{'o'} = $this_end_note_tick;
        }
        else {
            $display_note .=  '-';
        }
        if ( $note->{'purple'} ) {
            $display_note .= ' P';
            $note_hash{'p'} = $this_end_note_tick;
        }
        else {
            $display_note .=  ' -';
        }
        $event_type = 'NOTEON';
        $event_text = $display_note;
    }
    $ms += ( $this_event_tick - $last_event ) / $tpqn * $this_tempo;
    $last_event = $this_event_tick;
    $DEBUG && printf "%-7s: tick %06d microsecond %010d, %s\n", $event_type, $this_event_tick, $ms, $event_text;
}

#use Data::Dumper;
#print Dumper $timesigs;
#print Dumper $tempos;
#print Dumper $notes;

exit;

######

sub readGamefile {
    my $filename = shift;
    my $game = shift;
    if ( ! -f $filename || ! -r $filename ) {
        print "$filename is not readable or does not exist\n";
        return undef;
    }

    my $object;
    if    ( $filename =~ m/\.mid\.qb(\.ps2|\.xen)?$/ ) {
        $object = new Spopt::QbFile;
        if ( $GAME{$game}->{'optimizer'} eq 'ghwt' ) {
            my $sectionfile = $filename;
            $sectionfile =~ s/mid.qb/mid_text.qb/;
            my $sectiontext = $filename;
            $sectiontext =~ s/mid.qb/mid_text.qs/;
            my $vocalfile = $filename;
            $vocalfile =~ s/mid.qb/mid.qs/;

            $object->sectionfile( $sectionfile );
            $object->sectiontext( $sectiontext );
            $object->vocalfile( $vocalfile );
        }
    }
    elsif ( $filename =~ m/\.mid$/ ) {
        $object = new Spopt::MidiFile;
    }
    else {
        print "unknown file type.\n";
        return undef;
    }

    $object->file( $filename );
    $object->readfile;
    return $object;
}
