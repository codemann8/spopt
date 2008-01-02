#!/usr/bin/perl5

## Foreach diff in (easy, medium, hard, expert)
##     Foreach file in /cygdrive/c/Web/GuitarHero/gh3-ps2/$diff/
##         If file matches /.*blank.png/ then copy to gh3-ps2-hidden-dragon
##         Else                               move file to gh3-ps2-hidden-dragon
##
##     Read in file /cygdrive/c/Web/GuitarHero/gh3-ps2.${diff}1337.html
##     In each line, change !/gh3-ps2/!/gh3-ps2-hidden-dragon/!
##     Write the file

my $TOPDIR = "/cygdrive/c/Web/GuitarHero";
foreach my $diff (qw(easy medium hard expert)) {
    my $pngdir = "$TOPDIR/gh3-ps2/$diff";
    opendir AAA, $pngdir;
    my @aa = readdir AAA;
    close AAA;

    foreach my $f (@aa) {
	next unless $f =~ /png|txt|html/;
	if ($f =~ /blank.png|index.html/) { system("cp $pngdir/$f $TOPDIR/gh3-ps2-hidden-dragon/$diff/$f"); }
	else                              { system("mv $pngdir/$f $TOPDIR/gh3-ps2-hidden-dragon/$diff/$f"); }
    }

    open BBB, "$TOPDIR/gh3-ps2.${diff}1337.html";
    my @bb = <BBB>;
    close BBB;

    foreach my $b (@bb) { $b =~ s!gh3-ps2/!gh3-ps2-hidden-dragon/!g; }

    open CCC, ">$TOPDIR/gh3-ps2.${diff}1337.html";
    foreach my $l (@bb) { print CCC $l; }
    close CCC;
}
