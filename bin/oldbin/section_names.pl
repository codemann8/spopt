#!/usr/bin/perl -w
use Encode;
use strict;

my $QBDIR = shift;

unless ( defined $QBDIR ) {
    $QBDIR = '.';
}

opendir AAA, "$QBDIR";
my @files = readdir AAA;
closedir AAA;

@files = grep { m/.mid_text.qb/ } @files;
@files = sort @files;

foreach my $ff (@files) {
    $ff =~ /(\S+).mid_text.qb.*/;
    my $basefile = $1;
    my $filename = "$QBDIR/$ff";
    open FILE, $filename or die "Could not open filename for reading";
    
    for my $i ( 0 .. 6) { read(FILE, my $buf, 4); } 
    while (read(FILE, my $buf, 4)) {
        my $dword = unpack "N", $buf;
        die "Invalid section name" unless $dword == 0x00200400;
    
        read(FILE, $buf, 4); my $strchecksum  = unpack "N", $buf;
        read(FILE, $buf, 4); my $songchecksum = unpack "N", $buf;
        seek(FILE, 8, 1 );
        my $i = 0;
        my $code = "";
    
        while (1) {
            last unless read(FILE, $buf, 2); 
    	$i++;
            my $dword = unpack "n", $buf;
    	last if $dword == 0;
    	my $char = decode("UCS-2BE", $buf );
    	$code .= $char;
        }
    
        if ($i%2==1) { seek(FILE, 2, 1 ); }
        printf "%08x %08x $basefile $code\n", $strchecksum, $songchecksum;
    }
    close FILE;
}
    
