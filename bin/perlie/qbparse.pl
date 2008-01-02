my $filename = shift @ARGV;
our $NUM_SIMPLE_LIST = 1;

our $OFFSET = 0;

open MIDIFILE, $filename;
my $buf = "";
my @filearr = ();
while (1) {
  my $len = read MIDIFILE, $buf, 1024;
  last if $len == 0;
  my @a = unpack "V*", $buf;
  push @filearr, @a;
}
close MIDIFILE;

printf "\%08X: ", $OFFSET * 4;
&parse_file_header(\@filearr);
while(@filearr > 0) {
  printf "\%08X: ", $OFFSET * 4;
  if    ($filearr[0] == 0x00000100) { &parse_null_section(\@filearr); }
  elsif ($filearr[0] == 0x00010000) { &parse_rec00010000(\@filearr);  }
  elsif ($filearr[0] == 0x00010100) { &parse_simple_list(\@filearr);  }
  elsif ($filearr[0] == 0x000A0100) { &parse_multlist2(\@filearr);  }
  elsif ($filearr[0] == 0x000C0100) { &parse_multlist(\@filearr);  }
  elsif ($filearr[0] == 0x000C0400) { &parse_track_header(\@filearr); }
  else                              { &parse_remaining_junk(\@filearr);  }
}

sub get_records {
  my $ra = shift;
  my $count = shift;
  $OFFSET = $OFFSET + $count;
  return splice @$ra, 0, $count;
}

sub parse_rec00010000 {
  my $ra = shift;
  print "Record 0x00010000:\n";
  
  my $id = get_records($ra,1);

  while ( 1 ) {
    printf "\%08X: ", $OFFSET * 4;
    my $next_record = get_records($ra,1);
	if ($next_record == 0) {
      printf "EOR    : \%08X\n", $next_record;
	  last;
	}
	elsif ($next_record == $OFFSET * 4) {
      printf "pointer: \%08X\n", $next_record;
      printf "\%08X: ", $OFFSET * 4;
      my @entry = get_records($ra,3);
	  printf "entries: \%08X \%08X \%08X\n", @entry;
	  if ($entry[0] == 0x00000700) {
        printf "\%08X: ", $OFFSET * 4;
        printf "Text Record Found (\%08X)\n", $entry[0];
	  	$next_record = get_records($ra,1);
		if ($next_record == 0) {
          printf "\%08X: ", $OFFSET * 4;
		  print "Null found.\n";
		} else {
          printf "\%08X: ", $OFFSET * 4;
		  printf "Warning: Null terminator not found. (\%08X)\n", $next_record;
		}

		printf "\%08X: ", $OFFSET * 4;

        PARSE_TEXT: while ( 1 ) {
		  $next_record = get_records($ra,1);
		  $hex_string = sprintf "\%08X", $next_record;
		  my @chars = (
		    hex( substr $hex_string,6,2),
			hex( substr $hex_string,4,2),
			hex( substr $hex_string,2,2),
			hex( substr $hex_string,0,2)
          );
		  for ($count = 0; $count < 4; $count++) {
            last PARSE_TEXT unless $chars[$count] != 0;
            print chr $chars[$count];
		  }
		}
		print "\n";
		last;
	  }
	}
	else {
      printf "junk   : \%08X\n", $next_record;
      next;
	}
  }
}

# deprecated
sub parse_rec65536 {
  my $ra = shift;
  printf "Record 65536:";

  splice @$ra, 0, 1;
  $OFFSET++;
  while ($ra->[0] != 0) {
	printf " \%08X", $ra->[0]; 
	splice @$ra, 0, 1;
	$OFFSET++;
  }
  printf " \%08X", $ra->[0]; 
  splice @$ra, 0, 1;
  $OFFSET++;
  print "\n";
}

sub parse_multlist {
  my $ra = shift;
  my @header = (@$ra)[0..2];
  my $num_entries = $header[1];
  print "Mult List ($num_entries lists)\n";
  splice @$ra, 0, 3;
  splice @$ra, 0, $num_entries if $num_entries > 1;
  $OFFSET = $OFFSET + 3;
  $OFFSET = $OFFSET + $num_entries if $num_entries > 1;
}

sub parse_multlist2 {
  my $ra = shift;
  my @header = (@$ra)[0..2];
  my $num_entries = $header[1];
  print "Mult List2 ($num_entries lists)\n";
  splice @$ra, 0, 3;
  splice @$ra, 0, $num_entries if $num_entries > 1;
  $OFFSET = $OFFSET + 3;
  $OFFSET = $OFFSET + $num_entries if $num_entries > 1;
}

sub parse_file_header {
## File header is 7 dwords long -- 2nd dword is file size
  my $ra = shift;
  my @junk = (@$ra)[0..6];
  printf "File Header (\%d,\%d,\%d,\%d,\%d,\%d,\%d)\n", @junk;
  splice @$ra, 0, 7;
  $OFFSET = $OFFSET + 7;
}

sub parse_track_header {
## Track header is 5 dwords long
  my $ra = shift;
  my @junk = (@$ra)[0..4];
  printf "Track Header (\%d,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,0x%02x,\%d,\%d)\n",
          $junk[0],
	  unpack("CCCCCCCC",pack("VV",$junk[1],$junk[2])),
	  $junk[3],
	  $junk[4];
  splice @$ra, 0, 5;
  $OFFSET = $OFFSET + 5;
}

sub parse_null_section {
## Null section is 3 dwords long
  my $ra = shift;
  my @junk = (@$ra)[0..2];
  print "Null Section\n";
  splice @$ra, 0, 3;
  $OFFSET = $OFFSET + 3;
}

sub parse_simple_list {
## Simple list has a 3 dword header. 2nd dword is the number of dwords in the list.
  my $ra = shift;
  my @header = (@$ra)[0..2];
  my $num_entries = $header[1];
  print "Simple List #$NUM_SIMPLE_LIST ($num_entries entries)\n";
  $NUM_SIMPLE_LIST++;
  splice @$ra, 0, 3;
  $OFFSET = $OFFSET + 3;

  for (my $i = 0; $i < $num_entries; $i += 3) {
	print "    ";
		for (my $j = $i; $j < $i+3 and $j < $num_entries; $j++) { printf "%12d ", $ra->[$j] }
	print "\n";
  }

  splice @$ra, 0, $num_entries;
  $OFFSET = $OFFSET + $num_entries;
}

sub parse_remaining_junk {
  my $ra = shift;
  foreach my $a (@$ra) { printf "\%08X\n", $a; }
  @$ra = ();
}


