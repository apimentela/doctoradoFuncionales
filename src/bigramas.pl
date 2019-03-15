#!/usr/bin/perl

##	bigramas
#	Este programa tiene el propósito de obtener bigramas, ahora con
#	 expresiones regulares

use utf8;

my $archivo_entrada = $ARGV[0];

open(INPUT,"<$archivo_entrada") or die "No se pudo abrir el archivo, $!";
my @coincidencias;
while(<INPUT>){
	while ($_ =~ /(\S+) (?=(\S+))/g){
		if ( $1 eq $2 ) { next; }
		my $salida = "$1 $2";
		print "$salida\n";	
	}	
}
close INPUT;
