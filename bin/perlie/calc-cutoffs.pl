#!/usr/bin/perl5

use FindBin;
use lib "$FindBin::Bin/lib";
use strict;

use FileHandle;

use MidiEvent;
use MidiFile;
use Note;
use Pwl;
use Song;
use TempoEvent;
use TimesigEvent;
use SongPainter;
use Image::Magick;
use Optimizer;
use Activation;
use Solution;

use Getopt::Long;

autoflush STDOUT 1;

##our $FILENAME = pop @ARGV;
our $OUTFILENAME;
our $DIFFICULTY;
our $SONG;
our $OPTIMIZER;
our $SQUEEZE_PERCENT = 0;
our $SP_SQUEEZE_PERCENT = 0;
our $DEBUG = 0;

our $GAME = shift @ARGV;
our $FILE = shift @ARGV;
our $FIVESTAR = shift @ARGV;

our $PS2DIR  = "/home/Dave/gh/midi/$GAME";
our $PS2LIST = "/home/Dave/gh/$FILE";

print "Cutoffs\n";
print "--------------------------------------------------------------------------------\n";
&process_cutoffs($PS2DIR,$PS2LIST);
print "\n\n";

sub process_cutoffs {
    my ($dir,$listfile) = @_;
    open AAA, "$listfile";
    while (<AAA>) {
        chomp; s/^\s+//; s/\s+$//;
        my $basefilename = $_;
        my $filename  = "$dir/$basefilename";
        next unless -f $filename;
	my %cutoff4 = (easy => 0, medium => 0, hard => 0, expert => 0);
	my %cutoff5 = (easy => 0, medium => 0, hard => 0, expert => 0);

	my $mf = new MidiFile;
	$mf->file($filename);
	$mf->maxtrack(2);
	$mf->read();

        foreach my $diff (qw(easy medium hard expert)) {
            my $song = new Song;
            $song->diff($diff);
            $song->midifile($mf);
            $song->construct_song();
            $song->calc_unsqueezed_data();
        	my $na = $song->notearr();
        	foreach my $n (@$na) {
                $cutoff4{$diff} += 2.0*$n->baseTotScore(); 
                $cutoff5{$diff} += $FIVESTAR * $n->baseTotScore(); 
            }
            $cutoff5{$diff} = int($cutoff5{$diff} + 0.9);
        }

	printf "%-22s 4E:%6d 4M:%6d 4H:%6d 4X:%6d   5E:%6d 5M:%6d 5H:%6d 5X:%6d\n",
	    $basefilename,
	    $cutoff4{easy},
	    $cutoff4{medium},
	    $cutoff4{hard},
	    $cutoff4{expert},
	    $cutoff5{easy},
	    $cutoff5{medium},
	    $cutoff5{hard},
	    $cutoff5{expert};
    }
}
