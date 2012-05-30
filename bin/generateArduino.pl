#!/usr/bin/env perl
# $Id: generateArduino.pl,v 1.1 2012-05-18 06:46:43 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/generateArduino.pl,v $
#
# Generate Arduino commands based on game files to drive guitar hero controller

use strict;
use warnings;

my $DEBUG = 0;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Spopt;

use Config::General;
use File::Basename;
use POSIX qw(pause);
use Getopt::Long;
use Template;
use Term::ReadKey;
use Time::HiRes qw(setitimer ITIMER_REAL);
use Device::SerialPort;

my $version = do { my @r=(q$Revision: 1.1 $=~/\d+/g); sprintf '%d.'.'%d'x$#r,@r };

my %pins = (
    'green'  => 13,
    'red'    => 12,
    'yellow' => 11,
    'blue'   => 10,
    'orange' => 9,
    'strum'  => 8,
    'purple' => -1,
);

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

USAGE: $self 
            --debug 
            --test
            --game <game id>
            --file <song file>
            --difficulty <difficulty> defaults to expert
            --chart <chart> defaults to guitar
            --port <serial device name> optional

If port is not defined, this will output native code for the Arduino to play the song
directly.

If port is defined, then a small stub of Arduino code will be shown and the program
will prepare to control the Arduino via the provided serial port.

--test is for running in serial port mode without a serial port attached. Not
particularly useful without debug on.

END
    exit;
}

my $game;
my $songFile;
my $difficulty = 'expert';
my $chart = 'guitar';
my $port;
my $test;

GetOptions(
    'debug+'       => \$DEBUG,
    'test'         => \$test,
    'game=s'       => \$game,
    'file=s'       => \$songFile,
    'difficulty=s' => \$difficulty,
    'chart=s'      => \$chart,
    'port:s'       => \$port,
);

&usage unless defined $songFile;
unless ( -f $songFile && -r $songFile ) {
    print "Song file does not exist or is not readable.\n";
    exit 1;
}

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
my $minimum_delay = 4; # smallest possible delay midi ticks
my $loop_tempo = int ( $MS_PER_MINUTE / 100 ); # default 100 beats per minute
my $beats_per_measure = 4; # aka 4/4 time

my $last_event = 0;
my $ms = 0;
my $delay_add = 0;

# note status (== NO_EVENT means note is off)
my %note_hash = (
    'g'     => $NO_EVENT,
    'r'     => $NO_EVENT,
    'y'     => $NO_EVENT,
    'b'     => $NO_EVENT,
    'o'     => $NO_EVENT,
    'p'     => $NO_EVENT,
    'strum' => $NO_EVENT,
);

my @events_delay;
my @events_pin_number;
my @events_pin_state;

print "Processing song file.\n";
while ( 1 ) {
    last unless scalar @$notes;
    my $note = shift @$notes;
    my $note_start_tick = $note->{'startTick'};
    $DEBUG > 1 && print STDERR "note   : $note_start_tick\n";

    my $timesig = shift ( @$timesigs ) if scalar @$timesigs;
    my $sig_tick = $NO_EVENT;
    if ( $timesig ) {
        $sig_tick = $timesig->{'tick'};
    }
    $DEBUG > 1 && print STDERR "timesig: $sig_tick\n" unless $sig_tick == $NO_EVENT;

    my $tempo = shift ( @$tempos ) if scalar @$tempos;
    my $tempo_tick = $NO_EVENT;
    if ( $tempo ) {
        $tempo_tick = $tempo->{'tick'};
    }
    $DEBUG > 1 && print STDERR "tempo  : $tempo_tick\n" unless $tempo_tick == $NO_EVENT;

    my $this_event_tick = 0;
    my $this_tempo = $loop_tempo;
    my $event_type = '';
    my $event_text = '';

    if (
        $note_hash{'g'}     <= $note_start_tick ||
        $note_hash{'r'}     <= $note_start_tick ||
        $note_hash{'y'}     <= $note_start_tick ||
        $note_hash{'b'}     <= $note_start_tick ||
        $note_hash{'o'}     <= $note_start_tick ||
        $note_hash{'p'}     <= $note_start_tick ||
        $note_hash{'strum'} <= $note_start_tick
    ) {
        # handle note off event

        unshift (@$notes, $note);
        unshift (@$timesigs, $timesig) unless $sig_tick == $NO_EVENT;
        unshift (@$tempos, $tempo) unless $tempo_tick == $NO_EVENT;

        ( $this_event_tick, $event_type, $event_text ) = buildNoteOff( \%note_hash, $this_tempo );
    }
    elsif (
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

        $delay_add += sprintf '%.0f', (( $this_event_tick - $last_event ) / $tpqn * $this_tempo) / 1000;
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

        $delay_add += sprintf '%.0f', (( $this_event_tick - $last_event ) / $tpqn * $this_tempo) / 1000;
    }
    else {
        # handle notes
        $this_event_tick = $note_start_tick;
        my $this_end_note_tick = 
            $note_start_tick == $note->{'endTick'}  ?
            $note_start_tick + $minimum_delay :
            $note->{'endTick'};

        unshift (@$tempos, $tempo) unless $tempo_tick == $NO_EVENT;
        unshift (@$timesigs, $timesig) unless $sig_tick == $NO_EVENT;

        my $strum = 1; # TODO add support for HOPO

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
        $note_hash{'strum'} = $note_start_tick + $minimum_delay if $strum;

        $event_type = 'NOTEON';
        $event_text = $display_note;
        $event_text .= ' STRUM' if $strum;

        my $delay = sprintf '%.0f', (( $this_event_tick - $last_event ) / $tpqn * $this_tempo) / 1000 + $delay_add;
        $delay_add = 0;
        noteOnEvent( $delay, $note, $strum );
    }
    $ms += ( $this_event_tick - $last_event ) / $tpqn * $this_tempo;
    $last_event = $this_event_tick;
    $DEBUG && printf STDERR "%-7s: tick %06d microsecond %010d, %s\n", $event_type, $this_event_tick, $ms, $event_text;
}

# handle final note off events
for my $final_note_tick ( sort { $note_hash{$a} <=> $note_hash{$b} } keys %note_hash ) { 
    last if $note_hash{ $final_note_tick } == $NO_EVENT;

    my ( $this_event_tick, $event_type, $event_text ) = buildNoteOff( \%note_hash, $loop_tempo );
    $ms += ( $this_event_tick - $last_event ) / $tpqn * $loop_tempo; # potential bug - tempo changes during held note at end of song
    $last_event = $this_event_tick;
    $DEBUG && printf STDERR "%-7s: tick %06d microsecond %010d, %s\n", $event_type, $this_event_tick, $ms, $event_text;
}

my $tt = Template->new
    ({
        INCLUDE_PATH => '.',
        PRE_CHOMP    => 1,
        POST_CHOMP   => 0,
    });
                    
print "Generating Arduino code:\n\n";
unless ( $port ) {
    # generate native Arduino code

    my $vars = {
        'number_of_events' => scalar @events_delay,
        'pins'             => \%pins,
        'events_delay'     => \@events_delay,
        'events_pin'       => \@events_pin_number,
    };

    print "-------------------8<--------------------\n";
    $tt->process('arduino_native.tt', $vars) or die $tt->error(), "\n";
    print "-------------------8<--------------------\n";
}
else {
    # generate serial driver Arduino code
    my $vars = {
        'pins' => \%pins,
    };

    print "-------------------8<--------------------\n";
    $tt->process('arduino_serial.tt', $vars) or die $tt->error(), "\n";
    print "-------------------8<--------------------\n";

    print "\nPress any key to start playing song via serial port $port\n";
    ReadMode 'raw';
    ReadKey 0;
    ReadMode 'normal';

    my $serial;
    unless ( $test ) {
        $serial = Device::SerialPort->new($port) or die "Failed to open serial port $port\n";
        $serial->baudrate(9600);
        $serial->databits(8);
        $serial->parity('none');
        $serial->stopbits(1);
    }

    $SIG{ALRM} = sub { };

    print "Playing song...\n";
    for ( my $i = 0 ; $i < scalar @events_delay ; $i++ ) {
        unless ( $events_delay[$i] == 0 ) {
            setitimer( ITIMER_REAL, $events_delay[$i] / 1000 );
            $DEBUG && printf "delay %-2.f milliseconds\n", $events_delay[$i];
            pause;
        }
        $DEBUG && printf "toggle pin %2d\n", $events_pin_number[$i];
        $serial->write( $events_pin_number[$i] ) unless $test;
    }
    print "Done!\n";
}

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

# noteOn( $delay, $note_object, $strum_flag );
sub noteOnEvent {
    my ( $delay, $note, $strum ) = @_;

    # purple notes are a special case - on bass charts this is an open note, on drums it's the kick
    # a -1 value for the pin on the purple note designates it as an open note, and we skip all other
    # notes if that's the case (note sure how the games deal with this clash though).
    if ( $note->{'purple'} ) {
        if ( $pins{'purple'} == -1 ) {
            pushEvent( $delay, $pins{'green'}, 0 );
            pushEvent( 0, $pins{'red'}, 0 );
            pushEvent( 0, $pins{'yellow'}, 0 );
            pushEvent( 0, $pins{'blue'}, 0 );
            pushEvent( 0, $pins{'orange'}, 0 );
            if ( $strum ) {
                pushEvent( 0, $pins{'strum'}, 1 );
            }
            return;
        }
        pushEvent( $delay, $pins{'purple'}, 1 );
        $delay = 0;
    }
    if ( $note->{'green'} ) {
        pushEvent( $delay, $pins{'green'}, 1 );
        $delay = 0;
    }
    if ( $note->{'red'} ) {
        pushEvent( $delay, $pins{'red'}, 1 );
        $delay = 0;
    }
    if ( $note->{'yellow'} ) {
        pushEvent( $delay, $pins{'yellow'}, 1 );
        $delay = 0;
    }
    if ( $note->{'blue'} ) {
        pushEvent( $delay, $pins{'blue'}, 1 );
        $delay = 0;
    }
    if ( $note->{'orange'} ) {
        pushEvent( $delay, $pins{'orange'}, 1 );
        $delay = 0;
    }

    if ( $strum ) {
        pushEvent( $delay, $pins{'strum'}, 1 );
        $delay = 0;
    }
}

sub pushEvent {
    my ( $delay, $pin, $state ) = @_;
    push @events_delay, $delay;
    push @events_pin_number, $pin;
    push @events_pin_state, $state;
}

# noteOff( $delay, $note_hash );
sub noteOffEvent {
    my ( $delay, $note ) = @_;

    if ( $note->{'g'} ) {
        pushEvent( $delay, $pins{'green'}, 0 );
        $delay = 0;
    }
    if ( $note->{'r'} ) {
        pushEvent( $delay, $pins{'red'}, 0 );
        $delay = 0;
    }
    if ( $note->{'y'} ) {
        pushEvent( $delay, $pins{'yellow'}, 0 );
        $delay = 0;
    }
    if ( $note->{'b'} ) {
        pushEvent( $delay, $pins{'blue'}, 0 );
        $delay = 0;
    }
    if ( $note->{'o'} ) {
        pushEvent( $delay, $pins{'orange'}, 0 );
        $delay = 0;
    }
    if ( $note->{'p'} && $pins{'purple'} != -1 ) {
        pushEvent( $delay, $pins{'purple'}, 0 );
        $delay = 0;
    }
    if ( $note->{'strum'} ) {
        pushEvent( $delay, $pins{'strum'}, 0 );
        $delay = 0;
    }

}

sub buildNoteOff {
    # add note off event to array
    my ( $note_hash, $this_tempo ) = @_;

    my @sorted_notes = sort { $note_hash->{$a} <=> $note_hash->{$b} } keys %$note_hash; # sort by tick value
    my $noteoff_tick = $note_hash->{ $sorted_notes[0] };
    $note_hash->{ $sorted_notes[0] } = $NO_EVENT;
    my %actual_notes = ( shift @sorted_notes => 1 );
    for my $other_notes ( @sorted_notes ) {
        if ( $note_hash->{ $other_notes } == $noteoff_tick ) {
            $actual_notes{ $other_notes } = 1;
            $note_hash->{ $other_notes } = $NO_EVENT;
        }
        else {
            last;
        }
    }

    my $display_note;
    $display_note .= $actual_notes{'g'} ? 'g' : '-';
    $display_note .= $actual_notes{'r'} ? 'r' : '-';
    $display_note .= $actual_notes{'y'} ? 'y' : '-';
    $display_note .= $actual_notes{'b'} ? 'b' : '-';
    $display_note .= $actual_notes{'o'} ? 'o' : '-';
    $display_note .= $actual_notes{'p'} ? ' p' : ' -';
    $display_note .= $actual_notes{'strum'} ? ' strum' : ' -';
    my $event_type = 'NOTEOFF';
    my $event_text = $display_note;

    my $delay = sprintf '%.0f', (( $noteoff_tick - $last_event ) / $tpqn * $this_tempo) / 1000 + $delay_add;
    $delay_add = 0;
    noteOffEvent( $delay, \%actual_notes );

    return $noteoff_tick, $event_type, $event_text;
}
