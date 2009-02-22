# $Id: MidiFile.pm,v 1.2 2009-02-22 00:52:26 tarragon Exp $
# $Source: /var/lib/cvs/spopt/lib/Spopt/MidiFile.pm,v $

package Spopt::MidiFile;
use strict;
use Spopt::MidiEvent;

sub new        { my $type = shift; my @args = @_; my $self = {}; bless $self, $type; $self->_init(); return $self;}
sub _prop      { my $self = shift; if (@_ == 2) { $self->{$_[0]} = $_[1]; } return $self->{$_[0]}; }
sub file       { my $self = shift; return $self->_prop("file",@_);    }
sub debug      { my $self = shift; return $self->_prop("debug",@_);    }
sub maxtrack   { my $self = shift; return $self->_prop("maxtrack",@_);    }

sub _init {
    my $self = shift;
    $self->file("");
    $self->debug(0);
    $self->maxtrack(1e6);
    $self->{events} = [];
}

sub read {
    my $self = shift;
    my $debug = $self->debug();
    if ($debug >= 1) { print "DEBUG: Enter MidiFile::read()\n"; }

    ## Get the file into an array of bytes
    open MIDIFILE, $self->{file} or die "Could not open file $self->{file} for reading";
    my $buf = "",
    my @filearr = ();
    while (1) {
        my $len = read MIDIFILE, $buf, 1024;
        last if $len == 0;
        my @a = unpack "C*", $buf;
        push @filearr, @a;
    }
    close MIDIFILE;

    my ($tracks) = $self->_parse_MThd(\@filearr);
    for my $i ( 0 .. $tracks-1) { last if $i > $self->maxtrack(); $self->_parse_MTrk($i,\@filearr); }
}

sub getall {
    my $self = shift;
    return $self->{events};
}

sub gettrack {
    my ($self,$n) = @_;
    my @track = grep { $_->track() == $n } @{$self->{events}};
    return @track;
}

sub _parse_MThd {
    my $self = shift;
    my $debug = $self->debug();
    if ($debug >= 1) { print "DEBUG: MidiFile::_parse_MThd()\n"; }
    my $rf = shift;
    $rf->[0] == 0x4d or die "Invalid MThd Header, aborting...";
    $rf->[1] == 0x54 or die "Invalid MThd Header, aborting...";
    $rf->[2] == 0x68 or die "Invalid MThd Header, aborting...";
    $rf->[3] == 0x64 or die "Invalid MThd Header, aborting...";
    my $numtracks = 256 * $rf->[10] + $rf->[11];
    splice @$rf, 0, (8+6);
    return $numtracks;
}

sub _parse_MTrk {
    my ($self,$n,$rf) = @_;
    my $debug = $self->debug();
    if ($debug >= 1) { print "DEBUG: MidiFile::_parse_MTrk()\n"; }
    $rf->[0] == 0x4d or die "Invalid MTrk Header, aborting...";
    $rf->[1] == 0x54 or die "Invalid MTrk Header, aborting...";
    $rf->[2] == 0x72 or die "Invalid MTrk Header, aborting...";
    $rf->[3] == 0x6b or die "Invalid MTrk Header, aborting...";
    my $numbytes = (1 << 24) * $rf->[4] + (1 << 16) * $rf->[5] + (1 << 8) * $rf->[6] + $rf->[7];
    my $timestamp = 0;
    my $lasttype = "";
    my $status = "";
    my $lastmidi = "";
    splice @$rf, 0, (8);
    while ($numbytes > 0) {

        ## Parse the timestamp
	my ($deltalen,$delta) = $self->_parse_var_len($rf);
	splice @$rf, 0, $deltalen; $numbytes -= $deltalen; $timestamp += $delta;

	## No figure out what the status is
	if    ($rf->[0] == 0xff)                      { $status = "meta";                              splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] == 0xf0)                      { $status = "sysex";                             splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0x80 and $rf->[0] <= 0x8f) { $status = "noteoff";      $lastmidi = $status; splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0x90 and $rf->[0] <= 0x9f) { $status = "noteon";       $lastmidi = $status; splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xa0 and $rf->[0] <= 0xaf) { $status = "aftertouch";   $lastmidi = $status; splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xb0 and $rf->[0] <= 0xbf) { $status = "control";      $lastmidi = $status; splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xc0 and $rf->[0] <= 0xcf) { $status = "program";      $lastmidi = $status; splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xd0 and $rf->[0] <= 0xdf) { $status = "chanpressure"; $lastmidi = $status; splice @$rf, 0, 1; $numbytes--;}
	elsif ($rf->[0] >= 0xe0 and $rf->[0] <= 0xef) { $status = "pitchwheel";   $lastmidi = $status; splice @$rf, 0, 1; $numbytes--;}
	else                                          { $status = $lastmidi; } ## Running status implied

	my $event = MidiEvent->new();
	$event->track($n);
	$event->tick($timestamp);

	if ($status eq "noteoff") {
	    $event->eventstr($status);
	    $event->argint1($rf->[0]);
	    $event->argint2($rf->[1]);
	    splice @$rf, 0, 2; $numbytes -= 2;
	}

	elsif ($status eq "noteon") {
	    my $locstatus = ($rf->[1] == 0) ? "noteoff": "noteon";
	    $event->eventstr($locstatus);
	    $event->argint1($rf->[0]);
	    $event->argint2($rf->[1]);
	    splice @$rf, 0, 2; $numbytes -= 2;
	}

	elsif ($status eq "meta") {
	    if ( ($rf->[0] >= 0x01) and ($rf->[0] <= 0x09) ) {

		my    $locstatus = "";
		if    ($rf->[0] == 0x01) { $locstatus = "text"; }
		elsif ($rf->[0] == 0x02) { $locstatus = "copyright"; }
		elsif ($rf->[0] == 0x03) { $locstatus = "trackname"; }
		elsif ($rf->[0] == 0x04) { $locstatus = "instrument"; }
		elsif ($rf->[0] == 0x05) { $locstatus = "lyric"; }
		elsif ($rf->[0] == 0x06) { $locstatus = "marker"; }
		elsif ($rf->[0] == 0x07) { $locstatus = "cuepoint"; }
		elsif ($rf->[0] == 0x08) { $locstatus = "programname"; }
		elsif ($rf->[0] == 0x09) { $locstatus = "devicename"; }

		splice @$rf, 0, 1; $numbytes -= 1;
		my ($sublen,$len) = $self->_parse_var_len($rf);
		splice @$rf, 0, $sublen; $numbytes -= $sublen;
		##my $str = ""; for my $i ( 0 .. $len-1 ) { $str .= $rf->[$i]; }
		my $str = pack "C$len", @{$rf}[0 .. $len-1];
		splice @$rf, 0, $len; $numbytes -= $len;

	        $event->eventstr($locstatus);
	        $event->argstr($str);
	    }

	    elsif ($rf->[0] == 0x2f) {
	        $event->eventstr("endtrack");
		splice @$rf, 0, 2; $numbytes -= 2;
	    }

	    elsif ($rf->[0] == 0x51) {
	        $event->eventstr("tempo");
	        $event->argint1( (1 << 16) * $rf->[2] + (1 << 8) * $rf->[3] + $rf->[4] );
		splice @$rf, 0, 5; $numbytes -= 5;
	    }

	    elsif ($rf->[0] == 0x58) {
	        $event->eventstr("timesig");
		$event->argint1($rf->[2]);
		$event->argint2($rf->[3]);
		$event->argint3($rf->[4]);
		$event->argint4($rf->[5]);
		splice @$rf, 0, 6; $numbytes -= 6;
	    }

	    else { die "could not parse meta midi event -- dying"; }
	}

	else { die "unrecognized midi event"; }

	if ($debug) { printf "DEBUG:   Parsed midi even type \%s\n", $event->eventstr(); }
        push @{$self->{events}}, $event;
    }
}

sub _parse_var_len {
    my ($self,$ra) = @_;
    if    ($ra->[0] < 128) { return (1,  $ra->[0]); }
    elsif ($ra->[1] < 128) { return (2, (($ra->[0]-128) << 7) + $ra->[1]); }
    elsif ($ra->[2] < 128) { return (3, (($ra->[0]-128) << 14) + (($ra->[1]-128) << 7) + $ra->[2]); }
    else                   { return (4, (($ra->[0]-128) << 21) + (($ra->[1]-128) << 14) + (($ra->[2]-128) << 7) + $ra->[3]); }
}
1;
