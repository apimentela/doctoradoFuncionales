#!/usr/bin/perl

##	bigramas
#	Este programa tiene el propósito de obtener bigramas, ahora con
#	 expresiones regulares

use utf8;

my $archivo_vocab = $ARGV[0];
my $archivo_bigramas = $ARGV[1];


my %dictionary;
open(VOCAB,"<$archivo_vocab") or die "No se pudo abrir el archivo de vocabulario, $!";
while(<VOCAB>){
	my $linea = $_;
	chomp $linea;
	my ( $id , $palabra ) = split(/ /,$linea);
	$dictionary{$palabra} = $id;
}
close VOCAB;

open(BIGRAMAS,"<$archivo_bigramas") or die "No se pudo abrir el archivo de bigramas, $!";
while(<BIGRAMAS>){
	my $linea = $_;
	chomp $linea;
	my ( $palabra1 , $palabra2 ) = split(/ /,$linea);
	$linea =~ s/\b$palabra1\b/$dictionary{$palabra1}/;
	$linea =~ s/\b$palabra2\b/$dictionary{$palabra2}/;
	print $linea;
}
close BIGRAMAS;
