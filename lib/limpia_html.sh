#!/bin/bash

##	limpia_html
#	Programa en desarrollo para limpiar los htmls de un corpus, y obtener texto.

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa


}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior


# Parse short options
OPTIND=1
while getopts "" opt
do
  case "$opt" in
	":") echo "La opción -$OPTARG necesita un argumento"  >&2 ; usage ; exit 1;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

# AQUI COMIENZA EL PROGRAMA

function main() {
##	Esta es la función principal del programa
#	utiliza las banderas de las opciones para hacer el procedimiento de cada una de las limpiezas.
	hxprune -c toc -x prueba.htm | hxselect p | xml2asc | tr -d "\r" | tr "\n" " " | tr -s "[:space:]" | sed 's|</p><p>|</p>\n<p>|g'
}
export -f main

parallel --env _ --linebuffer main ::: $@ 
