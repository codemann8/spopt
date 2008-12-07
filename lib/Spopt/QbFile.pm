# $Id: QbFile.pm,v 1.13 2008-12-07 12:55:56 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/QbFile.pm,v $

package QbFile;
use strict;
use warnings;

use Carp qw( carp croak );

require String::CRC32;
require File::Basename;

## TODO properly document this sucker!

sub new             { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop           { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub file            { my $self = shift; return $self->_prop('file',@_);    }
sub debug           { my $self = shift; return $self->_prop('debug',@_);    }
sub sustainthresh   { my $self = shift; return $self->_prop('sustainthresh',@_);    }
sub verbose         { my $self = shift; return $self->_prop('verbose',@_);    }

sub get_beats       { my ($self) = @_;       return $self->{'_beat'}; }
sub get_timesig     { my ($self) = @_;       return $self->{'_timesig'}; }
sub get_str2crc     { my ($self) = @_;       return $self->{'_str2crc'}; }
sub get_crc2str     { my ($self) = @_;       return $self->{'_crc2str'}; }
sub get_markers     { my $self = shift; return $self->{'_markers'}; }
sub get_notearr {
    my ($self,$chart,$diff) = @_;
    if ( defined $diff ) {
        return $self->{'_notes'}->{$chart}->{$diff};
    }
    else {
        # backwards compatibility; option is difficulty, chart defaults to guitar
        return $self->{'_notes'}->{$chart};
    }
}
sub get_sparr {
    my ($self,$chart,$diff) = @_;
    if ( defined $diff ) {
        return $self->{'_sp'}->{$chart}->{$diff};
    }
    else {
        # backwards compatibility; option is difficulty, chart defaults to guitar
        return $self->{'_sp'}->{$chart};
    }
}

sub dump {
    my $self = shift;
    my $verbose = $self->{'verbose'};

    print "== sections (",scalar @{$self->{'_sections'}}," entries)\n";
    if ( $verbose ) {
        for my $section ( @{$self->{'_sections'}} ) {
            my $crc = $self->{'_raw'}->[$section+1];
            my $string = defined $self->{'_crc2str'}->{ $crc } ? $self->{'_crc2str'}->{ $crc } : '';
            printf "%5u : 0x%08x - %s\n", $section, $crc, $string;
        }
    }

    for my $part ( qw( guitar aux drum guitarcoop rhythm rhythmcoop ) ) {
        for my $diff ( qw( easy medium hard expert ) ) {
            printf "== %10s - %6s - note section (%5u entries)\n",$part,$diff,scalar @{ $self->{'_notes'}{ $part }{ $diff } };
            $verbose && $self->_print_notes( $self->{'_notes'}{ $part }{ $diff } );
            printf "== %10s - %6s -   sp section (%5u entries)\n",$part,$diff,scalar @{ $self->{'_sp'}{ $part }{ $diff } };
            $verbose == 1 && $self->_print_sp    ( $self->{'_sp'}{ $part }{ $diff } );
            $verbose > 1  && $self->_print_rawsp ( $part, $diff );
        }
    }

    print "== beat section\n";
    print "   ms\n";
    for my $beat ( @{$self->{'_beat'}} ) {
        printf "%06u\n", $beat;
    }

    print "== time signatures\n";
    print "   ms b/m n/b\n";
    for my $timesig_ref ( @{$self->{'_timesig'}} ) {
       printf "%06u %u %u\n", $timesig_ref->[0], $timesig_ref->[1], $timesig_ref->[2];
    }

    return $self;
}

sub _print_notes {
    my $self = shift;
    my $notes = shift;
    return unless scalar @$notes;
    print "      Time Notes    Length\n";
    for ( my $i = 0 ; $i < scalar @$notes ; $i++ ) { 
        my $note = $notes->[$i];
        printf "%4u %6u %016b %5u\n", $i+1, $note->[0], $note->[2], $note->[1];
    }
}

sub _print_rawsp {
    my $self = shift;
    my $part = shift;
    my $diff = shift;
    my $sp   = $self->{'_sp'}{ $part }{ $diff };
    my $raw;
    if ( $part eq 'guitar' ) {
        $raw = $self->_get_section( $diff.'_star' );
    }
    else {
        $raw = $self->_get_section( $part.'_'.$diff.'_star' );
    }
        
    return unless scalar @$sp;
    print "   Start End rstart   rlen   #\n";
    for ( my $i = 0 ; $i < scalar @$sp ; $i++ ) {
        my $thissp = $sp->[$i];
        my $rawsp = $raw->[$i];
        printf "%2u %4u %4u %6u %6u %3u\n", $i+1, $thissp->[0], $thissp->[1], $rawsp->[0], $rawsp->[1], $rawsp->[2];
    }
}

sub _print_sp {
    my $self = shift;
    my $sp = shift;
    return unless scalar @$sp;
    print "Start End\n";
    for my $thissp ( @$sp ) {
        printf "%4u %4u\n", $thissp->[0], $thissp->[1];
    }
}

sub _print_values {
    my $self = shift;
    my $array = shift;
    my $width = shift;
    unless ( defined($width) ) { $width = 1; }

    my $i = 0;
    for ( @$array ) {
        my ( $u1, $u2, $u3, $u4 );
        $u1 = ( $_ & 0xff000000 ) / 0x01000000;
        $u2 = ( $_ & 0x00ff0000 ) / 0x00010000;
        $u3 = ( $_ & 0x0000ff00 ) / 0x00000100;
        $u4 = ( $_ & 0x000000ff );

        printf "0x%08x 0b%08b:%08b:%08b:%08b", $_, $u1, $u2, $u3, $u4;
        $i++;
        if ( $i % $width ) {
            print ' - ';
        }
        else {
            print "\n";
        }
    }
}

sub _init {
    my $self = shift;

    $self->file('');
    $self->debug(0);
    $self->sustainthresh(0);

    $self->{'verbose'}          = 0;

    $self->{'_raw'}             = [];
    $self->{'_str2crc'}         = {};
    $self->{'_crc2str'}         = {};
    $self->{'_sections'}        = [];
    $self->{'_sections_crc'}    = {};
    $self->{'_beat'}            = [];
    $self->{'_timesig'}         = [];
    $self->{'_markers'}         = [];
## TODO reorganise charts to allow easier selection of non-guitar charts
## may require work against other libs, or (hopefully) just the generation script
    foreach my $diff ( qw( easy medium hard expert ) ) {
        $self->{'_notes'}{ $diff }   = [];
        $self->{'_sp'}{ $diff }      = [];
        foreach my $part ( qw( guitar aux drum guitarcoop rhythm rhythmcoop ) ) {
            $self->{'_notes'}{ $part }{ $diff }   = [];
            $self->{'_sp'}{ $part }{ $diff }      = [];
        }
    }
}

=head3 read

    $qb->read()

Reads in the file specified, generates a checksum list, and extracts the sections from the file.

=cut
sub read {
    my $self = shift;
    my $debug = $self->debug();

    my $filename = $self->{'file'};

    my $basename = File::Basename::basename($filename);
    $self->generate_checksum_list( $basename );

    my $mode = 'be'; # big endian by default, only ps2 is little endian
    my $file_checksum = $self->{'_str2crc'}->{'wholename'}->{'checksum'};
    if ( $filename =~ /\.ps2$/ ) {
        $mode = 'le'; 
        $file_checksum = $self->{'_str2crc'}->{'wholename_ps2'}->{'checksum'};
    }

    $debug && print  "DEBUG: File: $filename\n";
    $debug && print  "DEBUG: Mode: $mode\n";
    $debug && printf "DEBUG: File checksum: 0x%08x\n", $file_checksum;

    ## Get the file into an array of 32 bit values
    open SONGFILE, $filename or croak "Could not open file $filename for reading\n";
    binmode SONGFILE;
    while ( read SONGFILE, my $buf, 65536 ) {
        push @{$self->{'_raw'}}, $mode eq 'be' ? unpack 'N*', $buf : unpack 'V*', $buf;
    }
    close SONGFILE;

## TODO check for QB header

    # scan for file checksum and set pointers
    foreach my $i ( 1 .. ( scalar @{$self->{'_raw'}} ) - 1 ) {
        # if current u32 matches the checksum, the previous u32 defines the section
        if ( $self->{'_raw'}->[$i] == $file_checksum ) {
            my $section_crc = $self->{'_raw'}->[$i - 1];
            $self->{'_sections_crc'}->{$section_crc} = scalar @{$self->{'_sections'}};
            push @{$self->{'_sections'}}, $i - 2;
        }
    }
    $debug && printf "DEBUG: Found %u sections\n", scalar @{$self->{'_sections'}};

    # look for a section specific to GH:WT (gh4)
    my $gamever = 3;
    if ( defined $self->_get_section("song_drum_easy") ) {
        $gamever = 4;
    }

    my $temptracks;

    foreach my $diff ( qw( easy medium hard expert ) ) {
        $temptracks->{'guitar'}->{'notes'}->{ $diff }     = $self->_get_section("song_$diff");
        $temptracks->{'guitar'}->{'sp'}->{ $diff }        = $self->_get_section( $diff.'_star' );

        $temptracks->{'rhythm'}->{'notes'}->{ $diff }     = $self->_get_section("song_rhythm_$diff");
        $temptracks->{'rhythm'}->{'sp'}->{ $diff }        = $self->_get_section('rhythm_'.$diff.'_star');

        $temptracks->{'guitarcoop'}->{'notes'}->{ $diff } = $self->_get_section("song_guitarcoop_$diff");
        $temptracks->{'guitarcoop'}->{'sp'}->{ $diff }    = $self->_get_section('guitarcoop_'.$diff.'_star');

        $temptracks->{'rhythmcoop'}->{'notes'}->{ $diff } = $self->_get_section("song_rhythmcoop_$diff");
        $temptracks->{'rhythmcoop'}->{'sp'}->{ $diff }    = $self->_get_section('rhythmcoop_'.$diff.'_star');

        if ( $gamever == 4 ) {
            $temptracks->{'aux'}->{'notes'}->{ $diff }  = $self->_get_section("song_aux_$diff");
            $temptracks->{'aux'}->{'sp'}->{ $diff }     = $self->_get_section('aux_'.$diff.'_star');
            $temptracks->{'drum'}->{'notes'}->{ $diff } = $self->_get_section("song_drum_$diff");
            $temptracks->{'drum'}->{'sp'}->{ $diff }    = $self->_get_section('drum_'.$diff.'_star');
        }
    }
    $temptracks->{'timesig'} = $self->_get_section('timesig');
    $temptracks->{'beats'}   = $self->_get_section('fretbars');
    $temptracks->{'markers'} = $self->_get_section('markers');
    
    for my $part ( qw(guitar rhythm guitarcoop rhythmcoop aux drum) ) {
        if ( $part eq 'aux' || $part eq 'drum' && $gamever != 4 ) {
            next;
        }
        for my $diff ( qw(easy medium hard expert) ) {
            my $thisNotes_aref = $temptracks->{ $part }->{'notes'}->{ $diff };

            ## Get the notes down first

            next unless scalar @$thisNotes_aref;

            my ( $time, $length, $notes );
            my $noteArray_aref = $self->{'_notes'}->{ $part }->{ $diff };

            if ( $gamever == 3 ) {
                warn "Invalid number of values in note array while parsing $part:$diff\n" if scalar @$thisNotes_aref % 3;
                for ( my $i = 0 ; $i < scalar @$thisNotes_aref ; $i+=3 ) { 
                    $time   = $thisNotes_aref->[$i    ];
                    $length = $thisNotes_aref->[$i + 1];
                    $notes  = $thisNotes_aref->[$i + 2];
                    push @$noteArray_aref, [ $time, $length, $notes ];
                }
            }
            elsif ( $gamever == 4 ) {
                warn "Invalid number of values in note array while parsing $part:$diff\n" if scalar @$thisNotes_aref % 2;
                for (my $i = 0; $i < @$thisNotes_aref ; $i+=2) { 
                    $time   =   $thisNotes_aref->[$i  ];
                    $length = ( $thisNotes_aref->[$i+1] & 0x0000ffff );
                    $notes  = ( $thisNotes_aref->[$i+1] & 0xffff0000 ) / 0x00010000 ;
                    push @$noteArray_aref, [ $time, $length, $notes ];
                }
            } 
            else {
                die "Invalid game version: $gamever.\n";
            }

            ## Run through the notes to get the SP start points

            my $thisSP_aref  = $temptracks->{ $part }->{'sp'}->{ $diff };
            unless ( scalar @$thisSP_aref ) {
                $thisSP_aref = $temptracks->{ $part }->{'sp'}->{ 'expert' };
            }
            next unless scalar @$thisSP_aref;

            my $spArray_aref = $self->{'_sp'}->{ $part }->{ $diff };

            my $spp = 0;
            my $numspphrases = scalar @$thisSP_aref;
            for ( my $i = 0 ; $i < scalar @$noteArray_aref ; $i++ ) {
                last if $spp >= $numspphrases;

                my $spStartms = $thisSP_aref->[ $spp ]->[0];
                my $spEndms = $thisSP_aref->[ $spp ]->[0] + $thisSP_aref->[ $spp ]->[1];
                my $spNoteCount = $thisSP_aref->[ $spp ]->[2];

                if ( $noteArray_aref->[ $i ]->[0] >= $spStartms ) { 
                    $spArray_aref->[ $spp ]->[0] = $i;
                    for ( my $endNote = $i ; $endNote < scalar @$noteArray_aref ; $endNote++ ) {
                        if ( $noteArray_aref->[ $endNote ]->[0] > $spEndms ) { 
                            $spArray_aref->[ $spp ]->[1] = $endNote - 1;
                            last;
                        }
                    }
                    $spp++;
                }
#                if ( $noteArray_aref->[ $i ]->[0] >= $thisSP_aref->[ $spp ]->[0] ) { 
#                    $spArray_aref->[ $spp ]->[0] = $i;
#                    $spArray_aref->[ $spp ]->[1] = $i + $thisSP_aref->[ $spp ]->[2] - 1;
#                    $spp++;
#                }
            }
        }
    }

    # copy to legacy variables
    for my $diff ( qw(easy medium hard expert) ) {
        $self->{'_notes'}->{ $diff }   = $self->{'_notes'}->{'guitar'}->{ $diff };
        $self->{'_sp'}->{ $diff }      = $self->{'_sp'}->{'guitar'}->{ $diff };
    }

    ## beat track just moves over
    @{$self->{'_beat'}} = @{$temptracks->{'beats'}};

    if ($self->sustainthresh() == 0) {
	my $st = int ( ($self->{'_beat'}[1] - $self->{'_beat'}[0]) / 2 + 0.0001);
        $self->sustainthresh($st);
    }

    ## massage the time sig track a little
    for (my $i = 0 ; $i < @{$temptracks->{'timesig'}} ; $i++) {
        my $ms          = $temptracks->{'timesig'}->[$i]->[0];
        my $numerator   = $temptracks->{'timesig'}->[$i]->[1];
        my $denominator = $temptracks->{'timesig'}->[$i]->[2];
        $self->{'_timesig'}->[$i] = [ $ms, $numerator, $denominator ];
    }

    # process section names, if available
    ## for section names, we have to read in the master file
    my $master_file = "";
    if ($filename =~ /(\S+)\/(\S+)/) {
        $master_file = "$1/master_section_names.txt";
    }
    else {
        $master_file = "master_section_names.txt";
    }
    if ( -f $master_file ) {
        open MSECTION, "$master_file" or die "Could not find section file for opening";
        my %db = ();
        while (<MSECTION>) {
            next unless /(\S+)\s+(\S+)\s+(\S+)\s+(\S.*\S)/;
            my ($strcrc,$songcrc,$songbase,$string) = ($1,$2,$3,$4);
            $db{$songbase}{$strcrc} = $string;
        }
        close MSECTION;

        ## Now loop through all of the section names, and if we find one, then we stick it in the hash
        my $basename = $self->{'_str2crc'}->{'basename'}->{'string'};
        foreach my $marker ( @{$temptracks->{'markers'}} ) {
            last unless ref $marker eq 'HASH';
            my $crc  = $marker->{'marker'};
            my $time = $marker->{'time'};
            if ( defined $db{$basename} && defined $db{$basename}{$crc} ) {
                push @{$self->{'_markers'}}, [ $time, $db{$basename}{$crc} ];
            }
        }
    }

    # release some memory
    undef $temptracks;

    return $self;
}

sub _get_section {
    my $self = shift;
    my $section_string = shift;
    croak "Section '$section_string' not found!" unless defined $self->{'_str2crc'}->{$section_string};
    my $section_crc = $self->{'_str2crc'}->{$section_string}->{'checksum'};
    unless ( defined $self->{'_sections_crc'}->{$section_crc} ) {
        return undef;
    }

    my $debug = $self->debug();
    if ( $debug > 1 ) {
        printf "DEBUG: _get_section : '%s' (0x%08x)\n", 
            $section_string, 
            $section_crc;
    }

    my $pos_start = $self->{'_sections'}->[ $self->{'_sections_crc'}->{$section_crc} ];
    my $pos_end   = $self->{'_sections'}->[ $self->{'_sections_crc'}->{$section_crc} + 1 ] - 1 ;
    if ( $debug > 1 ) {
        printf "DEBUG: _get_section : \$pos_start = %u, \$pos_end = %u\n", 
            $pos_start, 
            $pos_end;
    }

    my @section_data = @{$self->{'_raw'}}[ $pos_start+5..$pos_end ];

    my $section_type = $section_data[ 0 ];
    if ( $debug > 1 ) {
        printf "DEBUG: _get_section : \$section_type = 0x%08x\n", $section_type;
    }

    if    ( $section_type == 0x00010000 ) {
        # empty
        $debug && print "DEBUG: Section $section_string is empty\n";
        return [];
    }
    elsif ( $section_type == 0x00010100 ) {
        # array
        my @parsed = $self->_parse_array( \@section_data, $section_string );
        $debug 
        && printf "DEBUG: Section %s (0x%08x) is valid (%u element array)\n", 
           $section_string, 
           $self->{'_str2crc'}->{ $section_string }->{'checksum'}, 
           scalar @parsed;
        return \@parsed;
    }
    elsif (    $section_type == 0x000c0100
            || $section_type == 0x00010c00
    ) 
    {
        # array of arrays
        my @parsed = $self->_parse_arrayOfArrays( \@section_data, $section_string );
        $debug
        && printf "DEBUG: Section %s (0x%08x) is valid (%u element array of arrays)\n",
           $section_string,
           $self->{'_str2crc'}->{ $section_string }->{'checksum'}, 
           scalar @parsed;
        return \@parsed;
    }
    elsif (    $section_type == 0x000a0100
            || $section_type == 0x00010a00
    ) 
    {
        # array of hashes
        my @parsed = $self->_parse_array_hash( \@section_data, $section_string );
        $debug
        && printf "DEBUG: Section %s (0x%08x) is valid (%u element array of hashes)\n",
           $section_string,
           $self->{'_str2crc'}->{ $section_string }->{'checksum'}, 
           scalar @parsed;
        
        return \@parsed;
    }
    else {
        carp sprintf "Unrecognised section: '%s' (0x%08x)", $section_string, $section_type;
        return [];
    }
    die "Should never get here!\n";
}


sub qbcrc32 {
    my $self = shift;
    my $string = shift;
    warn 'no string provided!\n' unless defined $string;

    $string = lc $string;
    $string =~ s#/#\\#g;

    return String::CRC32::crc32( $string ) ^ 0xFFFFFFFF ;
}

sub generate_checksum_list {
    my $self = shift;
    my $filename = shift;

    my $transform;
    my $checksum;

    # strip off extraneous suffixes
    $filename =~ s/\.ps2$//;
    $filename =~ s/\.xen$//;
    $filename =~ s/\.qb$//;
    $filename =~ s/\.mid$//;

    # song
    $checksum = $self->qbcrc32( $filename );
    $self->{'_str2crc'}->{ 'basename' } = { 'string' => $filename, 'checksum' => $checksum };
    $self->{'_crc2str'}->{ $checksum } = 'basename';

    # songs\<song>.mid.qb
    $transform = "songs\\$filename.mid.qb";
    $checksum = $self->qbcrc32( $transform );
    $self->{'_str2crc'}->{ 'wholename' } = { 'string' => $transform, 'checksum' => $checksum };
    $self->{'_crc2str'}->{ $checksum } = 'wholename';

    # data\songs\<song>.mid.qb (ps2)
    $transform = "data\\songs\\$filename.mid.qb";
    $checksum = $self->qbcrc32( $transform );
    $self->{'_str2crc'}->{ 'wholename_ps2' } = { 'string' => $transform, 'checksum' => $checksum };
    $self->{'_crc2str'}->{ $checksum } = 'wholename_ps2';

    foreach my $part (
        'anim',
        'anim_notes',
        'aux_faceoffp1',
        'aux_faceoffp2',
        'aux_faceoffstar',
        'backupvocals',
        'backupvocals_01',
        'backupvocals_02',
        'backupvocals_03',
        'backupvocals_04',
        'band',
        'bass',
        'bassist_moment',
        'bossbattlep1',
        'bossbattlep2',
        'cameras',
        'cameras_notes',
        'crowd',
        'crowd_notes',
        'cymbals',
        'drum_faceoffp1',
        'drum_faceoffp2',
        'drum_faceoffstar',
        'drum_markers',
        'drumfill',
        'drums',
        'drums_notes',
        'drumunmute',
        'faceoffp1',
        'faceoffp2',
        'faceoffstar',
        'fretbars',
        'guitar',
        'guitar_markers',
        'guitarcoop_faceoffp1',
        'guitarcoop_faceoffp2',
        'guitarcoop_faceoffstar',
        'kickdrum',
        'leadvocals',
        'lightshow',
        'lightshow_notes',
        'lyrics',
        'markers',
        'perf2',
        'perf2_song_startup',
        'performance',
        'rhythm_faceoffp1',
        'rhythm_faceoffp2',
        'rhythm_faceoffstar',
        'rhythm_markers',
        'rhythmcoop_faceoffp1',
        'rhythmcoop_faceoffp2',
        'rhythmcoop_faceoffstar',
        'scripts',
        'scripts_notes',
        'slow_all',
        'slow_sg',
        'slow_singer',
        'snaredrum',
        'song_startup',
        'song_vocals',
        'star',
        'starbattlemode',
        'tapping',
        'timesig',
        'toms',
        'triggers',
        'triggers_notes',
        'vocals_freeform',
        'vocals_markers',
        'vocals_note_range',
        'vocals_phrases',
        'whammycontroller',
    ) {
        $self->_push_string_checksum( $filename, $part );
    }

    foreach my $diff ( qw( easy medium hard expert ) ) {

        my $part;

        # <filename>_song_<diff>
        $part = 'song_' . $diff;
        $self->_push_string_checksum( $filename, $part );

        # <filename>_<diff>_<section>
        foreach my $section_type (
            'anim',
            'anim_notes',
            'aux_faceoffp1',
            'aux_faceoffp2',
            'aux_faceoffstar',
            'backupvocals',
            'backupvocals_01',
            'backupvocals_02',
            'backupvocals_03',
            'backupvocals_04',
            'band',
            'bass',
            'bassist_moment',
            'bossbattlep1',
            'bossbattlep2',
            'cameras',
            'cameras_notes',
            'crowd',
            'crowd_notes',
            'cymbals',
            'drum_faceoffp1',
            'drum_faceoffp2',
            'drum_faceoffstar',
            'drum_markers',
            'drumfill',
            'drums',
            'drums_notes',
            'drumunmute',
            'faceoffp1',
            'faceoffp2',
            'faceoffstar',
            'fretbars',
            'guitar',
            'guitar_markers',
            'guitarcoop_faceoffp1',
            'guitarcoop_faceoffp2',
            'guitarcoop_faceoffstar',
            'kickdrum',
            'leadvocals',
            'lightshow',
            'lightshow_notes',
            'lyrics',
            'markers',
            'perf2',
            'perf2_song_startup',
            'performance',
            'rhythm_faceoffp1',
            'rhythm_faceoffp2',
            'rhythm_faceoffstar',
            'rhythm_markers',
            'rhythmcoop_faceoffp1',
            'rhythmcoop_faceoffp2',
            'rhythmcoop_faceoffstar',
            'scripts',
            'scripts_notes',
            'slow_all',
            'slow_sg',
            'slow_singer',
            'snaredrum',
            'song_startup',
            'song_vocals',
            'star',
            'starbattlemode',
            'tapping',
            'timesig',
            'toms',
            'triggers',
            'triggers_notes',
            'vocals_freeform',
            'vocals_markers',
            'vocals_note_range',
            'vocals_phrases',
            'whammycontroller',
        ) {
            $part = $diff . '_' . $section_type;
            $self->_push_string_checksum( $filename, $part );
        }

        # song_<type>_<diff>
        # <type>_<diff>_star
        foreach my $chart_type ( '', qw( aux_ drum_ guitarcoop_ rhythm_ rhythmcoop_ ) ) {

            $part = 'song_' . $chart_type . $diff;
            $self->_push_string_checksum( $filename, $part );

            foreach my $section_type ( qw( star starbattlemode tapping whammycontroller ) ) {
                $part = $chart_type . $diff . '_' . $section_type;
                $self->_push_string_checksum( $filename, $part );
            }
        }

    }

}

sub _push_string_checksum {
    my $self = shift;
    my $filename = shift;
    my $part = shift;

    my $debug = $self->{'debug'};

    my $transform = $filename . '_' . $part;
    my $checksum = $self->qbcrc32( $transform );
    if ( $debug > 1 ) {
        print "DEBUG: _push_string_checksum: transform = $transform\n";
        printf "DEBUG: _push_string_checksum: checksum = 0x%08x\n", $checksum;
    }

    $self->{'_str2crc'}->{ $part } = { 'string' => $transform, 'checksum' => $checksum };
    $self->{'_crc2str'}->{ $checksum } = $part;
}

sub _parse_array {
    my $self = shift;
    my $debug = $self->debug();

    my $section_AREF = shift;
    my $section_string = shift;
    my $section_type = shift @$section_AREF;
    my $section_length = shift @$section_AREF;
    my $section_start = shift @$section_AREF;

    if ( $debug > 1 ) {
        print  "DEBUG: * inside _parse_array\n";
        printf "DEBUG: * string : %s\n", $section_string;
        printf "DEBUG: * type   : 0x%08x\n", $section_type;
        printf "DEBUG: * length : 0x%08x\n", $section_length;
        printf "DEBUG: * start  : 0x%08x\n", $section_start;
    }

    if ( scalar @$section_AREF == $section_length ) {
        return @$section_AREF;
    }
    elsif ( scalar @$section_AREF > $section_length ) {
        carp sprintf 'Section %s array is longer than defined length (%u extra bytes)', $section_string, scalar @$section_AREF - $section_length;
        return @$section_AREF[ 0..($section_length - 1) ];
    }
    else {
        croak sprintf 'Section %s array is shorter than defined length (got %u, expected %u)', $section_string, scalar @$section_AREF, $section_length;
    }
    die "Should never get here!\n";
}

sub _parse_arrayOfArrays {
    my $self = shift;
    my $debug = $self->debug();

    my $section_AREF = shift;
    my $section_string = shift;
    my $section_type = shift @$section_AREF;
    my $section_length = shift @$section_AREF;
    my $section_start = shift @$section_AREF;
    
    if ( $debug > 1 ) {
        print  "DEBUG: * inside _parse_multi_array\n";
        printf "DEBUG: * string : %s\n", $section_string;
        printf "DEBUG: * type   : 0x%08x\n", $section_type;
        printf "DEBUG: * length : 0x%08x\n", $section_length;
        printf "DEBUG: * start  : 0x%08x\n", $section_start;
    }

    my @multiarray;
    if ( $section_length > 1 ) {
        # strip off sub-array pointers
        my @array_pointers = splice @$section_AREF, 0, $section_length;

        if ( $debug > 1 ) {
            print  "DEBUG: * \@array_pointers:\n";
            foreach my $i ( @array_pointers ) {
                printf "DEBUG: * = 0x%08x\n", $i;
            }
        }

        foreach ( @array_pointers ) {
            push @multiarray, $self->_splice_array( $section_AREF, $section_string );
        }
    }
    elsif ( $section_length == 1 ) {
        push @multiarray, $self->_splice_array( $section_AREF, $section_string );
    }
    else {
        croak sprintf 'Zero length multi-array at 0x%08x.', $section_start;
    }
    return @multiarray;
}

sub _splice_array {
    my $self = shift;
    my $section_AREF = shift;
    my $section_string = shift;
    my $this_array_length = @$section_AREF[1];
    my @this_array = splice @$section_AREF, 0, $this_array_length + 3;
    my @array = $self->_parse_array( \@this_array, $section_string );
    return \@array;
}

sub _parse_array_hash {
    my $self = shift;
    my $section_AREF = shift;
    my $section_string = shift;

    my $debug = $self->debug();

    if ( $debug > 1 ) {
        print  "DEBUG: * inside _parse_array_hash\n";
        printf "DEBUG: * string : %s\n", $section_string;
    }

    my $element_count = @$section_AREF[1];
    my @hash_table = splice @$section_AREF, 0, $element_count + 3;

    my @array_hash;
    while ( my $hash_entry_magic = shift @$section_AREF ) {
        unless ( $hash_entry_magic == 0x00000100 ) {
            croak sprintf 'Unexpected magic (0x%08x) while parsing section \'%s\'.', $hash_entry_magic, $section_string;
        }

        my $pointer = shift @$section_AREF; # discarded

        my $time = undef;
        my $marker = undef;

        while ( 1 ) {
            my $var_type = shift @$section_AREF;

            if    ( $var_type == 0x00000300 || $var_type == 0x00810000 ) {
                # integer
                $debug > 1 && printf "DEBUG: variable type - integer (0x%08x)\n", $var_type;
                my $var_name  = shift @$section_AREF;
                $debug > 1 && printf "DEBUG: variable name crc - 0x%08x\n", $var_name;
                unless ( $var_name == 0x906b67ba ) {
                    croak sprintf 'Unknown variable name (0x%08x) while parsing section \'%s\'.', $var_name, $section_string;
                }
                my $var_value = shift @$section_AREF;
                $debug > 1 && printf "DEBUG: variable value - 0x%08x\n", $var_value;
                my $pointer   = shift @$section_AREF;
                $debug > 1 && printf "DEBUG: next value pointer - 0x%08x\n", $pointer;

                $time = $var_value;

                last unless $pointer;
            }
            elsif ( $var_type == 0x00003500 || $var_type == 0x009a0000 ) {
                # string
                $debug > 1 && printf "DEBUG: variable type - string (0x%08x)\n", $var_type;
                my $var_name  = shift @$section_AREF;
                $debug > 1 && printf "DEBUG: variable name crc - 0x%08x\n", $var_name;
                unless ( $var_name == 0x7d30df01 ) {
                    croak sprintf 'Unknown variable name (0x%08x) while parsing section \'%s\'.', $var_name, $section_string;
                }
                my $var_value = shift @$section_AREF;
                $debug > 1 && printf "DEBUG: variable value - 0x%08x\n", $var_value;
                my $pointer   = shift @$section_AREF;
                $debug > 1 && printf "DEBUG: next value pointer - 0x%08x\n", $pointer;

                $marker = $var_value;

                last unless $pointer;
            }
            else {
                croak sprintf 'Unknown variable type (0x%08x) while parsing section \'%s\'.', $var_type, $section_string;
            }
        }
        $debug > 1 && printf "DEBUG: time: 0x%08x\n", $time;
        $debug > 1 && printf "DEBUG: marker: 0x%08x\n", $marker;
        if ( defined $time && defined $marker ) {
            push @array_hash, { 'time' => $time, 'marker' => $marker };
        }
        else {
            croak sprintf 'Missing value while parsing section \'%s\'.', $section_string;
        }
    }
    return @array_hash;
}

1;
