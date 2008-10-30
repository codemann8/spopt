# $Id: QbFile.pm,v 1.9 2008-10-30 11:13:59 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/QbFile.pm,v $

package QbFile;
use strict;

use String::CRC32;
use File::Basename;
use Carp;

sub new               { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop             { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub file              { my $self = shift; return $self->_prop('file',@_);    }
sub debug             { my $self = shift; return $self->_prop('debug',@_);    }
sub sustainthresh     { my $self = shift; return $self->_prop('sustainthresh',@_);    }
sub notepart          { my $self = shift; return $self->_prop('notepart',@_);    }
sub get_notearr       { my ($self,$diff) = @_; return $self->{'_notes'}{$diff}; }
sub get_sparr         { my ($self,$diff) = @_; return $self->{'_sp'}{$diff}; }
sub get_beats         { my ($self) = @_;       return $self->{'_beat'}; }
sub get_timesig       { my ($self) = @_;       return $self->{'_timesig'}; }
sub get_str2crc       { my ($self) = @_;       return $self->{'_str2crc'}; }
sub get_crc2str       { my ($self) = @_;       return $self->{'_crc2str'}; }
sub get_markers       { my $self = shift; return $self->{_markers}; }


sub _init {
    my $self = shift;

    $self->file('');
    $self->debug(0);
    $self->sustainthresh(0);
    $self->notepart('main');

    $self->{'_raw'}             = [];
    $self->{'_str2crc'}         = {};
    $self->{'_crc2str'}         = {};
    $self->{'_sections'}        = [];
    $self->{'_beat'}            = [];
    $self->{'_timesig'}         = [];
    $self->{'_markers'}         = [];
    $self->{'_notes'}{'easy'}   = [];
    $self->{'_notes'}{'medium'} = [];
    $self->{'_notes'}{'hard'}   = [];
    $self->{'_notes'}{'expert'} = [];
    $self->{'_sp'}{'easy'}      = [];
    $self->{'_sp'}{'medium'}    = [];
    $self->{'_sp'}{'hard'}      = [];
    $self->{'_sp'}{'expert'}    = [];
}

sub read {
    my $self = shift;
    my $debug = $self->debug();

    my $part   = $self->{'notepart'};
    my $partsp = $part . 'sp';

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
    my $buf;
    for ( my $len ; $len = read SONGFILE, $buf, 65536 ; ! $len ) {
        push @{$self->{'_raw'}}, $mode eq 'be' ? unpack 'N*', $buf : unpack 'V*', $buf;
    }
    close SONGFILE;

    # scan for file checksum and set pointers
    foreach my $i ( 0 .. ( scalar @{$self->{'_raw'}} ) - 1 ) {
        if ( $self->{'_raw'}->[$i] == $file_checksum ) {
            my $section_string = $self->{'_crc2str'}->{ $self->{'_raw'}->[$i - 1] };
            if ( defined $section_string ) {
                $self->{'_str2crc'}->{$section_string}->{'pos'} = scalar @{$self->{'_sections'}};
            }
            push @{$self->{'_sections'}}, $i - 2;
        }
    }
    $debug && printf "DEBUG: Found %u sections\n", scalar @{$self->{'_sections'}};

    my %temptracks = ();

    foreach my $diff ( qw( easy medium hard expert ) ) {
        # get notes
        $temptracks{'main'}{ $diff }  = $self->_get_section("song_$diff");
        $temptracks{'coop'}{ $diff }  = $self->_get_section("song_rhythm_$diff");
        $temptracks{'altp1'}{ $diff } = $self->_get_section("song_guitarcoop_$diff");
        $temptracks{'altp2'}{ $diff } = $self->_get_section("song_rhythmcoop_$diff");
        # get star power
        $temptracks{'mainsp'}{ $diff }  = $self->_get_section("${diff}_star");
        $temptracks{'coopsp'}{ $diff }  = $self->_get_section("rhythm_${diff}_star");
        $temptracks{'altp1sp'}{ $diff } = $self->_get_section("guitarcoop_${diff}_star");
        $temptracks{'altp2sp'}{ $diff } = $self->_get_section("rhythmcoop_${diff}_star");
    }
    $temptracks{'timesig'} = $self->_get_section('timesig');
    $temptracks{'beats'}   = $self->_get_section('fretbars');
    $temptracks{'markers'} = $self->_get_section('markers');

    foreach my $diff ( qw(easy medium hard expert) ) {

        unless ( defined ($temptracks{$part}{$diff}) ) {
            print "no section matching $part.\n";
            return;
        }

	## Get the notes down first
	for (my $i = 0; $i < @{$temptracks{$part}{$diff}} ; $i+=3) { 
	    push @{$self->{_notes}{$diff}}, [ @{$temptracks{$part}{$diff}}[$i .. $i+2] ];
	}

	## Run through the notes to get the SP start points
	my $spp = 0;
	my $numspphrases = scalar(@{$temptracks{$partsp}{$diff}});
	for (my $i = 0; $i < @{$self->{_notes}{$diff}}; $i++) {
	    next if $spp >= $numspphrases;
	    if ( $self->{_notes}{$diff}[$i][0] >= $temptracks{$partsp}{$diff}[$spp][0] ) { 
		$self->{_sp}{$diff}[$spp][0] = $i;
		$self->{_sp}{$diff}[$spp][1] = $i + $temptracks{$partsp}{$diff}[$spp][2] - 1;
		$spp++;
	    }
	}
    }

    ## beat track just moves over
    @{$self->{'_beat'}} = @{$temptracks{'beats'}};

    if ($self->sustainthresh() == 0) {
	my $st = int ( ($self->{'_beat'}[1] - $self->{'_beat'}[0]) / 2 + 0.0001);
        $self->sustainthresh($st);
    }

    ## massage the time sig track a little
    for (my $i = 0 ; $i < @{$temptracks{timesig}} ; $i++) {
        $self->{_timesig}[$i] = [ $temptracks{timesig}[$i][0], $temptracks{timesig} [$i][1] ];
    }

    ## for section names, we have to read in the master file
    my $master_file = "";
    if ($filename =~ /(\S+)\/(\S+)/) { $master_file = "$1/master_section_names.txt"; }
        else                         { $master_file = "master_section_names.txt";    }
    open MSECTION, "$master_file" or die "Could not find section file for opening";
    my %db = ();
    while (<MSECTION>) {
	next unless /(\S+)\s+(\S+)\s+(\S+)\s+(\S.*\S)/;
	my ($strcrc,$songcrc,$songbase,$string) = ($1,$2,$3,$4);
	$db{$songbase}{$strcrc} = $string;
    }
    close MSECTION;

    ## Now loop through all of the section names, and if we find one, then we stick it in the hash
    my $basename = $self->{'str2crc'}->{'basename'}->{'string'};
    foreach my $marker ( @{$temptracks{'markers'}} ) {
        my $crc  = $marker->{'marker'};
        my $time = $marker->{'time'};
	if ( exists $db{$basename}{$crc} ) {
	    push @{$self->{_markers}}, [ $time, $db{$basename}{$crc} ];
	}
    }
    return $self;
}

sub _get_section {
    my $self = shift;
    my $section_string = shift;
    croak "Section '$section_string' not found!" unless defined $self->{'_str2crc'}->{$section_string};

    my $debug = $self->debug();
    if ( $debug > 1 ) {
        printf "DEBUG: _get_section : '%s' (0x%08x)\n", 
            $section_string, 
            $self->{'_str2crc'}->{$section_string}->{'checksum'},
    }

    my $pos_start = $self->{'_sections'}->[ $self->{'_str2crc'}->{$section_string}->{'pos'} ];
    my $pos_end   = $self->{'_sections'}->[ $self->{'_str2crc'}->{$section_string}->{'pos'} + 1 ] - 1 ;
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

    foreach my $part ( qw( timesig fretbars markers faceoffp1 faceoffp2 bossbattlep1 bossbattlep2 ) ) {
        $self->_push_string_checksum( $filename, $part );
    }

    foreach my $diff ( qw( easy medium hard expert ) ) {

        my $part;
        # <filename>_song_<diff>
        $part = 'song_' . $diff;
        $self->_push_string_checksum( $filename, $part );

        # <filename>_<diff>_star
        $part = $diff . '_star';
        $self->_push_string_checksum( $filename, $part );

        # <filename>_<diff>_star
        $part = $diff . '_starbattlemode';
        $self->_push_string_checksum( $filename, $part );

        # <filename>_song_{guitarcoop,rhythm,rhythmcoop}_<diff>
        foreach my $chart_type ( qw( guitarcoop rhythm rhythmcoop ) ) {

            # song_<type>_<diff>
            $part = 'song_' . $chart_type . '_' . $diff;
            $self->_push_string_checksum( $filename, $part );

            # <type>_<diff>_star
            $part = $chart_type . '_' . $diff . '_star';
            $self->_push_string_checksum( $filename, $part );

            # <type>_<diff>_starbattlemode
            $part =  $chart_type . '_' . $diff . '_starbattlemode';
            $self->_push_string_checksum( $filename, $part );
        }
    }
}

sub _push_string_checksum {
    my $self = shift;
    my $filename = shift;
    my $part = shift;
    my $hashref_str2crc = shift;
    my $hashref_crc2str = shift;

    my $transform = $filename . '_' . $part;
    my $checksum = $self->qbcrc32( $transform );
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

sub _print_hex {
    my $self = shift;
    my $array = shift;

    foreach ( @$array ) {
        printf "0x%08x\n", $_;
    }
}

1;

