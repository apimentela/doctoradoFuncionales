#!/usr/bin/perl

use Encode qw(decode_utf8);
@ARGV = map { decode_utf8($_, 1) } @ARGV;

my $palabra_estimulo = $ARGV[0];

my $expresion_1 = '\b(.+)(?:(?:) )? (' . $palabra_estimulo . ') (\S+) \1 (?:(?:) )?(\S+)\b';

print "$palabra_estimulo\n";

print "$expresion_1\n";
