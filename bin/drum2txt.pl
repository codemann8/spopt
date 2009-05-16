#!/usr/bin/env perl
# $Id: drum2txt.pl,v 1.1 2009-05-16 02:37:55 tarragon Exp $
# $Source: /var/lib/cvs/spopt/bin/drum2txt.pl,v $

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Spopt;

my $GHROOT = "$FindBin::Bin/..";

my $GAMEFILEROOT = join '/',
    $GHROOT,
    Spopt::Config::configFetch('ASSETS'),
    Spopt::Config::configFetch('GAMEFILES');

my $songInfo = new Spopt::SongInfo;

for my $game ( keys %{ Spopt::Config::configFetch('GAME') } ) {
    next unless $game =~ m/ghwt|ghm/;
    my @songs = $songInfo->get_songarr_for_game( $game );

    my $gamePath = join '/',
        $GAMEFILEROOT,
        Spopt::Config::configFetch('GAME')->{ $game }->{'path'}, 
        Spopt::Config::configFetch('GAME')->{ $game }->{'platform'};

    for my $song ( @songs ) {
        print "$song->{'name'} Drum Expert ($game)\n";
        my $qbObj = new Spopt::QbFile;
        $qbObj->file( join '/', $gamePath, $song->{'file'} );
        $qbObj->readfile;
        
        print "R Y B O G P\n";
        for my $note ( @{ $qbObj->get_notearr( 'drum', 'expert' ) } ) {
            my ($msstart,$mslen,$notebv) = @$note;

            my $output = '';
            $notebv = $notebv & 0b00111111;
            $output .= addX( $notebv &  0x2 ); # red
            $output .= addX( $notebv &  0x4 ); # yellow
            $output .= addX( $notebv &  0x8 ); # blue
            $output .= addX( $notebv & 0x10 ); # orange
            $output .= addX( $notebv &  0x1 ); # green
            $output .= addX( $notebv & 0x20 ); # purple
            printf "%s %+6ums\n", $output, $msstart;
        }
        print "===\n";
    }
}

sub addX {
    my $val = shift;
    if ( $val ) {
        return 'X ';
    }
    else {
        return '  ';
    }
}
