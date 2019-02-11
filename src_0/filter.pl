#!/usr/bin/perl

##	triple_funs
#	Este programa tiene el propósito de obtener ventanas a partir de tres palabras funcionales
#	usa una lista de palabras funcionales y un archivo con el corpus

use utf8;
use File::Slurp::Unicode;

my $archivo_palabras = $ARGV[0];
my $archivo_contenido = $ARGV[1];

my $palabras_funcionales = read_file($archivo_palabras);
chomp($palabras_funcionales);	# Es mas facil usar chomp que: substr($palabras_funcionales,0,-1); Para quitar el último salto de linea
$palabras_funcionales =~ s/\n/\\b|\\b/g;
#~ $unaOmas_funcionales = '(?: ?\b(?:' . $palabras_funcionales . ')\b ?)+';	# Esta expresion es para una o más funcionales, pero si la funcional es multipalabra ya, entonces solo queresmos una ya

#~ $funcionales = '(?: ?\b(?:' . $palabras_funcionales . ')\b ?)';	# Esto seguramente tendrá el mismo problema de no detectar comas por la \b
$funcionales = '(?:\b' . $palabras_funcionales . '\b)';
$funcionales = '(?:' . $palabras_funcionales . '|^|$)+';

$ventanas_importantes = '((?:' . $funcionales .') ?\w+ ?(?:' . $funcionales .')(?: ?\w+ ?(?:' . $funcionales .'))+)' ;	# Esta expresión devuelve contextos de al menos dos palabras envueltas en tres palabras funcionales.
$ventanas_internas = '((?:' . $funcionales .') ?\w+ ?)(?=((?:' . $funcionales .')(?: ?\w+ ?(?:' . $funcionales .'))))' ;

#~ $expresion_palabras = '(' . $unaOmas_funcionales . ')( .+? )(?=(' . $unaOmas_funcionales . '))'; # Esta expresión regresa todos los contextos de palabras no funcionales rodeados de todoas las palabras funcionales juntas que encuentra al rededor
#$expresion_palabras = '((?: ?\b(?:' . $palabras_funcionales . ')\b ?))( .+? )(?=((?: ?\b(?:' . $palabras_funcionales . ')\b ?)))'; # ERROR. Esta expresión toma solo UNA palabra funciona, quiza sea suficiente para las primeras pruebas # ERROR; esto no funcionó, regresa dentro de los contextos palabras funcionales.

open(INPUT,"<$archivo_contenido") or die "No se pudo abrir el archivo, $!";
my @coincidencias;
my $nuevo_interes;
while(<INPUT>){
	$_ =~ s/^\s+|\s+$//g;	# trim both ends
	while ($_ =~ /$ventanas_importantes/g){
		print "$1\n";
		$nuevo_interes = "$1";
		while ( $nuevo_interes =~ /$ventanas_internas/g){
			print "$1$2\n";
			}
		}
	}	
close INPUT;
