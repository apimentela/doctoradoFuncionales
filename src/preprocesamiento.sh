#!/bin/bash

##	preprocesamiento
#	Este programa tiene el propósito de manipular un corpus de texto (inicialmente diseñado para ser de wikipedia)
#	para limpiarlo en primer lugar (con ayuda de limpia_corpus) y para obtener vocabulario, frecuencias y scores
#	de palabras funcionales (con vocabulario_frecuencias y functionScores respectivamente).
#	Más adelante también usa los patrones para hacer la detección de contextos funcionales y no funcionales
#	con ayuda de un programa de perl
##	DEPENDENCIAS
#	- parallel

nombre_programa=$0

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa ARCHIVO_ENTRADA SUFIJO_SALIDA"
}

entrada="$1"
salida="$2"

../lib/limpia_corpus -o "$salida" "$1"

function main() {
	cat "$1" \
	| if [[ $flag_wiki == true ]]; then sed -e 's|^</*doc.*$||g'; else cat; fi \
	| if [[ $flag_parentesis == false ]]; then sed -e 's|([^)]*)||g'; else cat; fi \
	| if [[ $flag_punct == false ]]; then sed -e 's|[[:punct:]]||g'; else cat; fi \
	| if [[ $flag_minus == true ]]; then perl -C -ne 'print lc'; else cat; fi \
	| if [[ $flag_num == false ]]; then perl -C -pe 's/[^ ]*\d[^ ]*/'"$etiqueta_DIGITO"'/g'; else cat; fi
}
export -f main

#FIXME: En algunos puntos del corpus hay espacios que son identicos a los espacios per no son espacios, hay que limpiar eso, tampoco son capturados por [:space:]
parallel --env _ --linebuffer main ::: $@ \
| if [[ $flag_empty == false ]]; then tr -s [:space:]; else cat; fi > "$salida"
