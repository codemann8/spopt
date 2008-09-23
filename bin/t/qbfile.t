#!/usr/bin/env perl
# basic tests for qbfile library

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More qw( no_plan );
use Test::Deep;

use_ok( 'QbFile', 'use QbFile');

use QbFile;
my $qb = QbFile->new;

ok( defined $qb, 'created object' );
ok( $qb->isa('QbFile'), 'object is valid');

# check qbcrc32 function
is( $qb->qbcrc32('hitmewithyourbestshot_song_Hard'), 0x00090a3f, 'crc32 without path');
is( $qb->qbcrc32('scripts\guitar\menu\menu_newspaper.qb'), 0x08c40450, 'crc32 with path');
is( $qb->qbcrc32('scripts/guitar/menu/menu_newspaper.qb'), 0x08c40450, 'crc32 with incorrect path delimiters');
isnt( $qb->qbcrc32('c:/gh3/data/scripts/guitar/menu/menu_newspaper.qb.xen'), 0x08c40450, 'invalid crc32');

my $checksum_hashref = $qb->generate_checksum_list('anarchyintheuk');
is( ref($checksum_hashref), 'HASH', 'got checksum hash');

my %test_checksums = (
    'basename' => { 'string' => 'anarchyintheuk', 'checksum' => 0xa86a21ff },
    'wholename' => { 'string' => 'songs\\anarchyintheuk.mid.qb', 'checksum'  => 0x944dc86b }, 
    'bossbattlep1' => { 'string' => 'anarchyintheuk_bossbattlep1', 'checksum' => 0x2982fdfd },
    'bossbattlep2' => { 'string' => 'anarchyintheuk_bossbattlep2', 'checksum' => 0xb08bac47 },
    'easy_star' => { 'string' => 'anarchyintheuk_easy_star', 'checksum' => 0xa0799228 },
    'easy_starbattlemode' => { 'string' => 'anarchyintheuk_easy_starbattlemode', 'checksum' => 0x7a00f51a },
    'expert_star' => { 'string' => 'anarchyintheuk_expert_star', 'checksum' => 0xb3709199 },
    'expert_starbattlemode' => { 'string' => 'anarchyintheuk_expert_starbattlemode', 'checksum' => 0x6bc0b4a0 },
    'faceoffp1' => { 'string' => 'anarchyintheuk_faceoffp1', 'checksum' => 0xef76abcc },
    'faceoffp2' => { 'string' => 'anarchyintheuk_faceoffp2', 'checksum' => 0x767ffa76 },
    'hard_star' => { 'string' => 'anarchyintheuk_hard_star', 'checksum' => 0x48096f8e },
    'hard_starbattlemode' => { 'string' => 'anarchyintheuk_hard_starbattlemode', 'checksum' => 0x25e0d2a1 },
    'medium_star' => { 'string' => 'anarchyintheuk_medium_star', 'checksum' => 0x9c1e116b },
    'medium_starbattlemode' => { 'string' => 'anarchyintheuk_medium_starbattlemode', 'checksum' => 0xe5b813b7 },
    'fretbars' => { 'string' => 'anarchyintheuk_fretbars', 'checksum' => 0x3ed675b9 },
    'guitarcoop_easy_star' => { 'string' => 'anarchyintheuk_guitarcoop_easy_star', 'checksum' => 0x0d86605e },
    'guitarcoop_easy_starbattlemode' => { 'string' => 'anarchyintheuk_guitarcoop_easy_starbattlemode', 'checksum' => 0x39605f91 },
    'guitarcoop_expert_star' => { 'string' => 'anarchyintheuk_guitarcoop_expert_star', 'checksum' => 0x99a67126 },
    'guitarcoop_expert_starbattlemode' => { 'string' => 'anarchyintheuk_guitarcoop_expert_starbattlemode', 'checksum' => 0x85b4fcb6 },
    'guitarcoop_hard_star' => { 'string' => 'anarchyintheuk_guitarcoop_hard_star', 'checksum' => 0xe5f69df8 },
    'guitarcoop_hard_starbattlemode' => { 'string' => 'anarchyintheuk_guitarcoop_hard_starbattlemode', 'checksum' => 0x6680782a },
    'guitarcoop_medium_star' => { 'string' => 'anarchyintheuk_guitarcoop_medium_star', 'checksum' => 0xb6c8f1d4 },
    'guitarcoop_medium_starbattlemode' => { 'string' => 'anarchyintheuk_guitarcoop_medium_starbattlemode', 'checksum' => 0x0bcc5ba1 },
    'markers' => { 'string' => 'anarchyintheuk_markers', 'checksum' => 0xf65a2d81 },
    'rhythm_easy_star' => { 'string' => 'anarchyintheuk_rhythm_easy_star', 'checksum' => 0xcac7d461 },
    'rhythm_easy_starbattlemode' => { 'string' => 'anarchyintheuk_rhythm_easy_starbattlemode', 'checksum' => 0x599d74c3 },
    'rhythm_expert_star' => { 'string' => 'anarchyintheuk_rhythm_expert_star', 'checksum' => 0x0d74ebce },
    'rhythm_expert_starbattlemode' => { 'string' => 'anarchyintheuk_rhythm_expert_starbattlemode', 'checksum' => 0xa1855add },
    'rhythm_hard_star' => { 'string' => 'anarchyintheuk_rhythm_hard_star', 'checksum' => 0x22b729c7 },
    'rhythm_hard_starbattlemode' => { 'string' => 'anarchyintheuk_rhythm_hard_starbattlemode', 'checksum' => 0x067d5378 },
    'rhythm_medium_star' => { 'string' => 'anarchyintheuk_rhythm_medium_star', 'checksum' => 0x221a6b3c },
    'rhythm_medium_starbattlemode' => { 'string' => 'anarchyintheuk_rhythm_medium_starbattlemode', 'checksum' => 0x2ffdfdca },
    'rhythmcoop_easy_star' => { 'string' => 'anarchyintheuk_rhythmcoop_easy_star', 'checksum' => 0x0191be45 },
    'rhythmcoop_easy_starbattlemode' => { 'string' => 'anarchyintheuk_rhythmcoop_easy_starbattlemode', 'checksum' => 0x8b35ed63 },
    'rhythmcoop_expert_star' => { 'string' => 'anarchyintheuk_rhythmcoop_expert_star', 'checksum' => 0x51fb4978 },
    'rhythmcoop_expert_starbattlemode' => { 'string' => 'anarchyintheuk_rhythmcoop_expert_starbattlemode', 'checksum' => 0x86511f7c },
    'rhythmcoop_hard_star' => { 'string' => 'anarchyintheuk_rhythmcoop_hard_star', 'checksum' => 0xe9e143e3 },
    'rhythmcoop_hard_starbattlemode' => { 'string' => 'anarchyintheuk_rhythmcoop_hard_starbattlemode', 'checksum' => 0xd4d5cad8 },
    'rhythmcoop_medium_star' => { 'string' => 'anarchyintheuk_rhythmcoop_medium_star', 'checksum' => 0x7e95c98a },
    'rhythmcoop_medium_starbattlemode' => { 'string' => 'anarchyintheuk_rhythmcoop_medium_starbattlemode', 'checksum' => 0x0829b86b },
    'song_easy' => { 'string' => 'anarchyintheuk_song_easy', 'checksum' => 0xd545e587 },
    'song_expert' => { 'string' => 'anarchyintheuk_song_expert', 'checksum' => 0x84ba6366 },
    'song_hard' => { 'string' => 'anarchyintheuk_song_hard', 'checksum' => 0x5d3260c2 },
    'song_medium' => { 'string' => 'anarchyintheuk_song_medium', 'checksum' => 0x0dd2b593 },
    'song_guitarcoop_easy' => { 'string' => 'anarchyintheuk_song_guitarcoop_easy', 'checksum' => 0x39fc249a },
    'song_guitarcoop_expert' => { 'string' => 'anarchyintheuk_song_guitarcoop_expert', 'checksum' => 0x97b511e5 },
    'song_guitarcoop_hard' => { 'string' => 'anarchyintheuk_song_guitarcoop_hard', 'checksum' => 0xb18ba1df },
    'song_guitarcoop_medium' => { 'string' => 'anarchyintheuk_song_guitarcoop_medium', 'checksum' => 0x1eddc710 },
    'song_rhythm_easy' => { 'string' => 'anarchyintheuk_song_rhythm_easy', 'checksum' => 0x2104a685 },
    'song_rhythm_expert' => { 'string' => 'anarchyintheuk_song_rhythm_expert', 'checksum' => 0x5959e58f },
    'song_rhythm_hard' => { 'string' => 'anarchyintheuk_song_rhythm_hard', 'checksum' => 0xa97323c0 },
    'song_rhythm_medium' => { 'string' => 'anarchyintheuk_song_rhythm_medium', 'checksum' => 0xd031337a },
    'song_rhythmcoop_easy' => { 'string' => 'anarchyintheuk_song_rhythmcoop_easy', 'checksum' => 0x86be0b53 },
    'song_rhythmcoop_expert' => { 'string' => 'anarchyintheuk_song_rhythmcoop_expert', 'checksum' => 0x265cfff9 },
    'song_rhythmcoop_hard' => { 'string' => 'anarchyintheuk_song_rhythmcoop_hard', 'checksum' => 0x0ec98e16 },
    'song_rhythmcoop_medium' => { 'string' => 'anarchyintheuk_song_rhythmcoop_medium', 'checksum' => 0xaf34290c },
    'timesig' => { 'string' => 'anarchyintheuk_timesig', 'checksum' => 0x4167c1b4 },
);


cmp_deeply( $checksum_hashref, \%test_checksums, 'checksum hash generation' );

