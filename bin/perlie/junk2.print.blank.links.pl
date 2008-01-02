#!/usr/bin/perl5	

foreach my $file (qw(  famouslastwords.mid
                       teenagers.mid
                       thisishowidisappear.mid ) ) {
    my $basefile = $file; $basefile =~ s/.mid$//;
    my $easyurl    = "http://www.bradleyzoo.com/GuitarHero/Blank/gh2-x360/easy/$basefile.blank.png";
    my $mediumurl  = "http://www.bradleyzoo.com/GuitarHero/Blank/gh2-x360/medium/$basefile.blank.png";
    my $hardurl    = "http://www.bradleyzoo.com/GuitarHero/Blank/gh2-x360/hard/$basefile.blank.png";
    my $experturl  = "http://www.bradleyzoo.com/GuitarHero/Blank/gh2-x360/expert/$basefile.blank.png";
    print "$file: [url=$easyurl]EASY[/url]  [url=$mediumurl]MEDIUM[/url]  [url=$hardurl]HARD[/url]  [url=$experturl]EXPERT[/url]\n";
}
