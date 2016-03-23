package postOCR;
# Primary use is    $newstr = &cleanstr($oldstr)   which does OCR post-processing and fixes many problems in the OCR output string.
# Cleans up OCR output.  Written by Robert Waldstein  March 2016

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( cleanString $cnt_left_word $cnt_merge_parts $cnt_merge3_parts $cnt_merge4_parts $cnt_left_nonword $cnt_left_nonwordL1 $cnt_left_nonwordL2 $cnt_left_nonwordL3);

my %wordList;
sub isWord {
    my $word = $_[0];

    if (! $wordList{"the"} ) {   # A signal that we have read in the wordlist files. Note must be in the file
	# Load in ones we want static
	foreach my $wordfile ("static_words.txt", "wordlist.txt", "spell.words") {
	    if (! open(WORDFILE, $wordfile) ) {
		print(STDERR "Cannot open file $wordfile for a word list\n");
		next;
		}
	    while (<WORDFILE>) {
		chomp;
		s/^\.[a-z][a-z0-9._-]+\s+//;	# in case just raw slimmer dump
		my @words = split(/[ \t(),;:.!?-]+/);
		for (my $i=0; $i <= $#words; $i++) {
		    if (length($words[$i]) > 2) {
			$words[$i] =~ tr/[A-Z]/[a-z]/;
			$wordList{$words[$i]}++;
			}
		    }
		}
	    close(WORDFILE);
	    }

	undef $wordList{iii}; 
	}
    $word =~ tr/[A-Z]/[a-z]/;
    return($wordList{$word});
    }

sub cleanString {
    my ($str, $debug) = @_;

    ($cnt_left_word, $cnt_merge_parts, $cnt_merge3_parts, $cnt_merge4_parts, $cnt_left_nonword, $cnt_left_nonwordL1, $cnt_left_nonwordL2, $cnt_left_nonwordL3) = (0,0,0,0,0,0,0,0);
    $str =~ s/[<>\014]+/ /g;
    $str =~ s/^[ \n]+//;
    $str =~ s/([a-z])\s+'s\s+/$1's /gi;
    $str =~ s/ \\v/ w/g;
    $str =~ s/ \\V/ W/g;
    $str =~ s/\\/ /g;
    my @word = split(/([^a-z]+)/i, $str);
    push @word, "...123";  # Make sure to end with non-word
    my $newcontent = "";

  WDLOOP:
    for (my $nextwd=0; $nextwd < $#word; $nextwd++) {
	if ($debug > 15) { print(STDERR "at start piece $nextwd <$word[$nextwd]>\n"); }
	if ($word[$nextwd] =~ /[^a-z]/i) { $newcontent .= $word[$nextwd]; next; }
	# Skip if seperator not just punctuation
	if ($word[$nextwd+1] =~ /[0-9]/i) { $newcontent .= $word[$nextwd]; next; }
	# Hack for 's on end of string
	if ((length($word[$nextwd]) > 2) && ($word[$nextwd+1] eq "'") && ($word[$nextwd+2] eq "s")) {
	    $newcontent .= $word[$nextwd] . "'s";
	    $nextwd += 2;
	    if (&isWord($word[$nextwd])) {
		$cnt_left_word++;
		}
	    else {
		$cnt_left_nonword++;
		}
	    next;
	    }
	# Find out how far strings of letters that could become words go
	my $maxstep;
	for ($maxstep=1; $maxstep <=5; $maxstep++) { 
	    if (($nextwd+$maxstep*2) >= $#word) { last; }
	    if (($word[$nextwd+$maxstep*2] =~ /[^a-z]/i) || ($word[$nextwd+$maxstep*2 - 1] =~ /[0-9.]/)) { last; }
	    }
	$maxstep--;

	my $did_merge = 0;  
	for (my $step=$maxstep; $step >= 1; $step--) {
	    my $newword = $word[$nextwd];
	    for (my $i=1; $i <= $step; $i++) { $newword .= $word[$nextwd + 2*$i]; }
	    if (&isWord($newword)) {
		if ($step >= 4) { $cnt_merge4_parts++; }
		elsif ($step >= 3) { $cnt_merge3_parts++; }
		elsif ($step >= 2) { $cnt_merge_parts++; }
		else {$cnt_merge3_parts++; }
		$newcontent .= $newword;
		if ($debug > 10) { print(STDERR "Merged $step strings to create word \"$newword\"\n"); }
		$nextwd += ($step*2);
		next WDLOOP;
		}
	    }

	$newcontent .= $word[$nextwd];
	if (($word[$nextwd] =~ /^(a|i|an|in|on)$/i) || (&isWord($word[$nextwd]))) {
	    $cnt_left_word++;
	    }
	else {
	       if (length($word[$nextwd]) == 1) { $cnt_left_nonwordL1++; }
	    elsif (length($word[$nextwd]) == 2) { $cnt_left_nonwordL2++; }
	    elsif (length($word[$nextwd]) == 3) { $cnt_left_nonwordL3++; }
	    elsif ($debug > 20) { print(STDERR "Left non-word <$word[$nextwd]>\n"); }
	    $cnt_left_nonword++;
	    }
	}
    if ($debug > 8) {
	print(STDERR "For record $id:  left words = $cnt_left_word; left non-words = $cnt_left_nonword (len1=$cnt_left_nonwordL1; len2=$cnt_left_nonwordL2; len3=$cnt_left_nonwordL3); merged words = $cnt_merge_parts; merged 3 words = $cnt_merge3_parts\n");
	}

    return($newcontent);
    }

1;
