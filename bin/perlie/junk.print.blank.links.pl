#!/usr/bin/perl5	

foreach my $file (qw(  bangyourhead.mid
                       wegotthebeat.mid
                       iran.mid              
                       ballstothewall.mid    
                       18andlife.mid         
                       noonelikeyou.mid      
                       shakin.mid            
                       heatofthemoment.mid   
                       radarlove.mid         
                       becauseitsmidnite.mid 
                       holydiver.mid         
                       turningjapanese.mid   
                       holdonloosely.mid     
                       thewarrior.mid        
                       iwannarock.mid        
                       whatilikeaboutyou.mid 
                       synchronicity2.mid    
                       ballroomblitz.mid     
                       onlyalad.mid          
                       roundandround.mid     
                       aintnothinbut.mid     
                       lonelyisthenight.mid  
                       bathroomwall.mid      
                       losangeles.mid        
                       wrathchild.mid        
                       electriceye.mid       
                       policetruck.mid       
                       seventeen.mid         
                       caughtinamosh.mid     
                       playwithme.mid ) ) {
    my $basefile = $file; $basefile =~ s/.mid//;
    my $easyurl    = "http://www.bradleyzoo.com/GuitarHero/Blank/ghrt80s-ps2/easy/$basefile.blank.png";
    my $mediumurl  = "http://www.bradleyzoo.com/GuitarHero/Blank/ghrt80s-ps2/medium/$basefile.blank.png";
    my $hardurl    = "http://www.bradleyzoo.com/GuitarHero/Blank/ghrt80s-ps2/hard/$basefile.blank.png";
    my $experturl  = "http://www.bradleyzoo.com/GuitarHero/Blank/ghrt80s-ps2/expert/$basefile.blank.png";
    print "$file: [url=$easyurl]EASY[/url]  [url=$mediumurl]MEDIUM[/url]  [url=$hardurl]HARD[/url]  [url=$experturl]EXPERT[/url]\n";
}
