#!/usr/bin/env perl
# basic tests for qbfile library

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More qw( no_plan );

use_ok( 'QbFile', 'use QbFile');

use QbFile;
my $qb = QbFile->new;

ok( defined $qb, 'created object' );
ok( $qb->isa('QbFile'), 'object is valid');

is( $qb->qbcrc32('hitmewithyourbestshot_song_Hard'), 0x00090a3f, 'crc32 without path');
is( $qb->qbcrc32('scripts\guitar\menu\menu_newspaper.qb'), 0x08c40450, 'crc32 with path');
is( $qb->qbcrc32('scripts/guitar/menu/menu_newspaper.qb'), 0x08c40450, 'crc32 with incorrect path delimiters');
isnt( $qb->qbcrc32('c:/gh3/data/scripts/guitar/menu/menu_newspaper.qb.xen'), 0x08c40450, 'invalid crc32');

