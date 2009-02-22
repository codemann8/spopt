#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../../lib";
use QbFile;
my $qb = new QbFile;
# $qb->file("$FindBin::Bin/../qb/gh3-aerosmith/alltheyoungdudes.mid.qb.xen");
# $qb->file("$FindBin::Bin/../qb/ghwt/byob.mid.qb.xen");
$qb->file("$FindBin::Bin/../../assets/gamefiles/GuitarHero3LegendsOfRock/x360/reptilia.mid.qb.xen");
my $verbose = shift;
if ( defined $verbose ) { $qb->verbose($verbose) };
$qb->read();
$qb->dump();

