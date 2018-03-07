#!/usr/bin/perl

##	contextos_funs
#	Este programa tiene el propósito de obtener contextos funcionales a partir
#	de una lista de palabras funcionales y un archivo con el corpus

use utf8;
use File::Slurp::Unicode;

my $archivo_palabras = $ARGV[0];
my $archivo_contenido = $ARGV[1];

my $palabras_funcionales = read_file($archivo_palabras);
chomp($palabras_funcionales);	# Es mas facil usar chomp que: substr($palabras_funcionales,0,-1);
$palabras_funcionales =~ s/\n/|/g;
$unaOmas_funcionales = '(?: ?\b(?:' . $palabras_funcionales . ')\b ?)+';
$expresion_palabras = '([^ ]*)(' . $unaOmas_funcionales . ')(?=([^ ]*))';	# Esta expresión devuelve contextos de palabras funcionales rodeados de una palabra no funcional. No se si sea mejor que busque todas las palabras no funcionales juntas, quizá no haga falta, y no se si la siguiente expresión sea más productiva de cualquier forma.
#~ $expresion_palabras = '(' . $unaOmas_funcionales . ')( .+? )(?=(' . $unaOmas_funcionales . '))'; # Esta expresión regresa todos los contextos de palabras no funcionales rodeados de todoas las palabras funcionales juntas que encuentra al rededor
#$expresion_palabras = '((?: ?\b(?:' . $palabras_funcionales . ')\b ?))( .+? )(?=((?: ?\b(?:' . $palabras_funcionales . ')\b ?)))'; # ERROR. Esta expresión toma solo UNA palabra funciona, quiza sea suficiente para las primeras pruebas # ERROR; esto no funcionó, regresa dentro de los contextos palabras funcionales.

open(INPUT,"<$archivo_contenido") or die "No se pudo abrir el archivo, $!";
my @coincidencias;
while(<INPUT>){
	while ($_ =~ /$expresion_palabras/g){
		chomp(my $salida = "$1,$2,$3");
		print "$salida\n";	
	}	
}
close INPUT;
