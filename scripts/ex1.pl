#!/usr/bin/perl

use utf8;
use File::Slurp::Unicode;

my $archivo_palabras = $ARGV[0];
my $archivo_contenido = $ARGV[1];

my $palabras_funcionales = read_file($archivo_palabras);
chomp($palabras_funcionales);	# Es mas facil usar chomp que: substr($palabras_funcionales,0,-1);
$palabras_funcionales =~ s/\n/|/g;
$unaOmas_funcionales = '(?: ?\b(?:' . $palabras_funcionales . ')\b ?)+';
#~ $expresion_palabras = '([^ ]*' . $unaOmas_funcionales . ')(?=([^ ]*))';
$expresion_palabras = '(' . $unaOmas_funcionales . ' .+? )(?=(' . $unaOmas_funcionales . '))';

open(INPUT,"<$archivo_contenido") or die "No se pudo abrir el archivo, $!";
my @coincidencias;
while(<INPUT>){
	while ($_ =~ /$expresion_palabras/g){
		chomp(my $salida = "$1$2");
		print "$salida\n";	
	}	
}
close INPUT;
