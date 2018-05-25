#!/usr/bin/perl

##	multi_funs
#	Este programa tiene el propósito de obtener "palabras funcionales"
#	se tomarán aquellas que estén formadas por VARIAS palabras funcionales

use utf8;
use File::Slurp::Unicode;

my $archivo_palabras = $ARGV[0];
my $archivo_contenido = $ARGV[1];

my $palabras_funcionales = read_file($archivo_palabras);
chomp($palabras_funcionales);	# Es mas facil usar chomp que: substr($palabras_funcionales,0,-1); Para quitar el último salto de linea
$palabras_funcionales =~ s/\n/|/g;
#~ $unaOmas_funcionales = '(?: ?\b(?:' . $palabras_funcionales . ')\b ?)+';
#~ $expresion_palabras = '(\S*)(' . $unaOmas_funcionales . ')(?=(\S*))';	# Esta expresión devuelve contextos de palabras funcionales rodeados de una palabra no funcional. No se si sea mejor que busque todas las palabras no funcionales juntas, quizá no haga falta, y no se si la siguiente expresión sea más productiva de cualquier forma.
#~ $expresion_palabras = '(' . $unaOmas_funcionales . ')( .+? )(?=(' . $unaOmas_funcionales . '))'; # Esta expresión regresa todos los contextos de palabras no funcionales rodeados de todoas las palabras funcionales juntas que encuentra al rededor
#$expresion_palabras = '((?: ?\b(?:' . $palabras_funcionales . ')\b ?))( .+? )(?=((?: ?\b(?:' . $palabras_funcionales . ')\b ?)))'; # ERROR. Esta expresión toma solo UNA palabra funciona, quiza sea suficiente para las primeras pruebas # ERROR; esto no funcionó, regresa dentro de los contextos palabras funcionales.

#~ $unaOmas_funcionales = '((?: ?\b(?:' . $palabras_funcionales . ')\b ?)+)';	# Esta expresión parece ya no funcionar si se toman en cuenta las comas como palabras funcionales, yo creo que es debido a la \b

$unaOmas_funcionales = '((?: (?:' . $palabras_funcionales . ')(?= ))+)';

open(INPUT,"<$archivo_contenido") or die "No se pudo abrir el archivo, $!";
while(<INPUT>){
	while ($_ =~ /$unaOmas_funcionales/g){
		chomp(my $salida = "$1");
		$salida =~ s/^\s+|\s+$//g;	# trim both ends
		my $num;
		$num++ while $salida =~ /\S+/g;
		print "$num $salida\n";	
	}	
}
close INPUT;
