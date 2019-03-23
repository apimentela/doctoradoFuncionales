#!/usr/bin/perl

##	extrae_pares
#	Este programa tiene el propósito de obtener pares de palabras
#	relacionadas

use utf8;

my $palabra_estimulo = $ARGV[0];
my $archivo_entrada = $ARGV[1];

my $lista_funcs_1 = 'la|el|los|las|del|su|al|un|se|the|san|una|lo|n|sus|dos';
my $lista_funcs_2 = 'de|y|en|a|con|es|por|para|hasta|of|fue|o|que|durante|sobre|contra|como';

my $ignorar = '(DIGITO|[^\w\s])';

my $expresion_1 = '\b(.+)(?:(?:' . $lista_funcs_1 . ') )? (' . $palabra_estimulo . ') (\S+) \1 (?:(?:' . $lista_funcs_1 . ') )?(\S+)\b';
my $expresion_2 = '\b(.+)(?:(?:' . $lista_funcs_1 . ') )? (\S+) (\S+) \1 (?:(?:' . $lista_funcs_1 . ') )?(' . $palabra_estimulo . ')\b';

my $verificacion = '\b(?:' . $lista_funcs_1 . '|' . $lista_funcs_2 . ')\b';

open(INPUT,"<$archivo_entrada") or die "No se pudo abrir el archivo, $!";
while(<INPUT>){
	while ($_ =~ /$expresion_1/g){
		if ( $4 =~ /$verificacion/ || $& =~ /$ignorar/ ) { next; }
		print "$2 $4\n";
	}
	while ($_ =~ /$expresion_2/g){
		if ( $2 =~ /$verificacion/ || $& =~ /$ignorar/ ) { next; }
		print "$4 $2\n";
	}
}
close INPUT;
