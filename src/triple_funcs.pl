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
#~ $unaOmas_funcionales = '(?: ?\b(?:' . $palabras_funcionales . ')\b ?)+';	# Esta expresion es para una o más funcionales, pero si la funcional es multipalabra ya, entonces solo queresmos una ya

#~ $funcionales = '(?: ?\b(?:' . $palabras_funcionales . ')\b ?)';	# Esto seguramente tendrá el mismo problema de no detectar comas por la \b
$funcionales = '(?:' . $palabras_funcionales . ')';
$funcionales = '(?:^|$|' . $palabras_funcionales . ')';

#~ print "$funcionales";

$ventanas_funcionales = '(?:^|\s)(' . $funcionales .') (\w+) (?=(' . $funcionales .') (\w+) (' . $funcionales .')(?:^|\s))' ;	# Esta expresión devuelve contextos de dos palabras envueltas en tres palabras funcionales.

#~ $expresion_palabras = '(' . $unaOmas_funcionales . ')( .+? )(?=(' . $unaOmas_funcionales . '))'; # Esta expresión regresa todos los contextos de palabras no funcionales rodeados de todoas las palabras funcionales juntas que encuentra al rededor
#$expresion_palabras = '((?: ?\b(?:' . $palabras_funcionales . ')\b ?))( .+? )(?=((?: ?\b(?:' . $palabras_funcionales . ')\b ?)))'; # ERROR. Esta expresión toma solo UNA palabra funciona, quiza sea suficiente para las primeras pruebas # ERROR; esto no funcionó, regresa dentro de los contextos palabras funcionales.

open(INPUT,"<$archivo_contenido") or die "No se pudo abrir el archivo, $!";
my @coincidencias;
while(<INPUT>){
	while ($_ =~ /$ventanas_funcionales/g){
		if($2 !~ /^$funcionales$/ && $4 !~ /^$funcionales$/){
			($uno = $1) =~ s/ /_/g; # esto es para sustituir y asignar el resultado en una sola línea
			($dos = $2) =~ s/ /_/g; # esto es para sustituir y asignar el resultado en una sola línea
			($tres = $3) =~ s/ /_/g; # esto es para sustituir y asignar el resultado en una sola línea
			($cuatro = $4) =~ s/ /_/g; # esto es para sustituir y asignar el resultado en una sola línea
			($cinco = $5) =~ s/ /_/g; # esto es para sustituir y asignar el resultado en una sola línea
			my $salida = "$dos $cuatro $uno $tres $cinco";
			my $cuenta;
			$cuenta++ while $salida =~ /\S+/g;
			print "$salida\n" if $cuenta == 5;
		}
	}	
}
close INPUT;
