#!/usr/bin/env perl
use strict;
use warnings;

use Env qw( HOME );
use FindBin;
use lib "$FindBin::Bin/../lib";

use QbFile;
use Song;
use SongPainter;

my $qb = new QbFile;
$qb->file("$FindBin::Bin/../qb/ghwt/byob.mid.qb.xen");
$qb->read();

for my $diff ( qw( Easy Medium Hard Expert ) ) {
    my $song = new Song;
    $song->game('gh3');
    $song->filetype('qb');
    $song->diff( lc $diff );
    $song->chart('rhythm');
    $song->midifile( $qb );

    $song->construct_song();
    $song->calc_unsqueezed_data();
    $song->calc_squeezed_data();
    $song->init_phrase_sp_pwls();

    my $painter = new SongPainter;
    $painter->debug(0);
    $painter->song( $song );
    $painter->filename( 'byob_bass_' . lc $diff . '.png' );
    $painter->greenbot(0);
    $painter->title( 'B.Y.O.B.' );
    $painter->subtitle( "$diff Bass" );
    $painter->outline_only(0);
    highlight_blank_phrases($song,$painter);
    $painter->paintsong();
}

sub highlight_blank_phrases {
    my ($song,$painter) = @_;
    my $na = $song->notearr();
    my $spa = $song->sparr();
    foreach my $rsp (@$spa) {
        my ($l,$r) = @$rsp;
        my $left  = $na->[$l]->startMeas();
        my $right = $na->[$r]->endMeas();
        my $diff = $right-$left;
        $left  -= 1/64.00;
        $right += 1/64.00;
        $painter->add_unrestricted($left,$right);
    }
}

