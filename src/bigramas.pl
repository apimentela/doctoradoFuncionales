#!/usr/bin/perl

##	bigramas
#	Este programa tiene el propósito de obtener bigramas, ahora con
#	 expresiones regulares

# Se usan estas dos líneas para que pueda leer sin problemas los parámetros como utf8
use Encode qw(decode_utf8);
@ARGV = map { decode_utf8($_, 1) } @ARGV;

my $archivo_entrada = $ARGV[0];

open(INPUT,"<$archivo_entrada") or die "No se pudo abrir el archivo, $!";
while(<INPUT>){
	while ($_ =~ /(\S+) (?=(\S+))/g){
		if ( $1 eq $2 ) { next; }
		my $salida = "$1 $2";
		print "$salida";	
	}	
}
close INPUT;
