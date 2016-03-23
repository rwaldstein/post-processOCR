#!/bin/perl -w
# This is a demo perl script to show use of the postOCR.pm library module to 
# Clean up OCR output.  Written by Robert Waldstein - 

use lib "postOCR";
use strict;
use postOCR qw( cleanString $cnt_left_word $cnt_merge_parts $cnt_merge3_parts $cnt_merge4_parts $cnt_left_nonword $cnt_left_nonwordL1 $cnt_left_nonwordL2 $cnt_left_nonwordL3);
my ($maxPercentImprove, $maxString, $maxPage, $maxReport) = (0, "", "", "");

my $str = "a great barga in in o ur socict y, research and dcvc! Opmcnl that have benefited o lher indu smill ee ru led thut questio n in g ca n go to th e a ll oca ti o n o f e xpe ndit ures but no t to the ir rcason ab leness. Am o ng o the r Bell Sys te m w it nesses who te3tifi ed du r in g the thi rd week ";

my $debug = 0;
my $clean_content = &cleanString($str, $debug);
print <<EOF;
string cleaned to:
$clean_content

left words: $cnt_left_word
left non-words (all length, including 1 char): $cnt_left_nonword
left 1 char non-word: $cnt_left_nonwordL1
left 2 char non-word: $cnt_left_nonwordL2
left 3 char non-word: $cnt_left_nonwordL3
merged 2 alpha-strings: $cnt_merge_parts
merged 3 alpha-strings: $cnt_merge3_parts
merged 4 alpha-strings: $cnt_merge4_parts
EOF
