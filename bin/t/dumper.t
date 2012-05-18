#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Spopt::QbFile;
my $qb = new Spopt::QbFile;
# $qb->file("$FindBin::Bin/../qb/gh3-aerosmith/alltheyoungdudes.mid.qb.xen");
# $qb->file("$FindBin::Bin/../qb/ghwt/byob.mid.qb.xen");
# $qb->file("$FindBin::Bin/../../assets/gamefiles/GuitarHeroWorldTour/x360/purplehaze.mid.qb");
# $qb->file("/home/tarragon/aceofspades.mid.qb");
$qb->file("$FindBin::Bin/../../assets/gamefiles/GuitarHero3LegendsOfRock/x360/thrufireandflames.mid.qb.xen");
my $verbose = shift;
if ( defined $verbose ) { $qb->verbose($verbose) };
$qb->debug(1);
$qb->readfile();
$qb->dump();

