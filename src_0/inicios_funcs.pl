#!/usr/bin/perl

##	contextos_funs
#	Este programa tiene el propósito de obtener contextos funcionales a partir
#	de una lista de palabras funcionales y un archivo con el corpus

use utf8;
use File::Slurp::Unicode;

my $archivo_palabras = $ARGV[0];
my $archivo_contenido = $ARGV[1];

my $palabras_funcionales = read_file($archivo_palabras);
chomp($palabras_funcionales);	# Es mas facil usar chomp que: substr($palabras_funcionales,0,-1); Para quitar el último salto de linea
$palabras_funcionales =~ s/\n/|/g;

$funcionales = '(?:(?:' . $palabras_funcionales . ') )';
$expresion_palabras = '^(' . $funcionales . ')(?=(\S+))';	# Esta expresión devuelve contextos de palabras funcionales en el que la oracion inicia con funcional

open(INPUT,"<$archivo_contenido") or die "No se pudo abrir el archivo, $!";
my @coincidencias;
while(<INPUT>){
	while ($_ =~ /$expresion_palabras/g){
		my $salida = "$1\t$2";
		$salida =~ s/\t | \t/\t/g;
		print "$salida\n";	
	}	
}
close INPUT;
