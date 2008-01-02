#!/usr/bin/perl5

my $filename = shift @ARGV;
open AAA, "$filename";
my @a = <AAA>; chomp @a;
my @b = map { [ split /,/, $_ ] } @a;
@b = sort { ($a->[6] <=> $b->[6]) ||
            ($a->[0] cmp $b->[0]) ||
            ($a->[2] <=> $b->[2]) ||
            ($a->[4] <=> $b->[4]) ||
            ($a->[1] cmp $b->[1])  } @b;

foreach my $b (@b) {
    printf "%-12s %-35s %-6s %2d %6.3f %6.3f\n", $b->[0], $b->[3], $b->[1], $b->[4], $b->[5], $b->[6];
}


