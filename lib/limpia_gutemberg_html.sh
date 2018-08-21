#!/bin/bash

##	limpia_html
#	Este programa limpia los html que se obtienen del proyecto Gutemberg, y obtiene texto.
#	Los html que dicen estar "generados" por Gutemberg, necesitan una pequeña limpieza manual del inicio, pues
#	 no he encontrado ningún patrón que me pueda ayudar a limpiarlo automáticamente aún.
##	DEPENDENCIAS
#	- html-xml-utils
#	- html2text
#	- parallel

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa
	echo "Uso: $nombre_programa [OPCIÓN]... [-o SUFIJO_SALIDA] ARCHIVO_ENTRADA..."
    echo "	-o SUFIJO_SALIDA, --output=SUFIJO_SALIDA
		Establece el sufijo para los diferentes archivos de salida,
		si se omite se usará como salida: salida_limpia_corpus"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--output") set -- "$@" "-o" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior


# Parse short options
OPTIND=1
while getopts "o:" opt
do
  case "$opt" in
	"o") salida="$OPTARG" ;;
	":") echo "La opción -$OPTARG necesita un argumento"  >&2 ; usage ; exit 1;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

# Opción final de la salida
: ${salida:="salida_limpia_gutemberg_html"} # Esto es una asignación por defecto de un valor, si no se ha establecido el valor de salida, se usa el segundo valor (el de la primera entrada)
export salida

# AQUI COMIENZA EL PROGRAMA

function main() {
##	Esta es la función principal del programa
#	utiliza las banderas de las opciones para hacer el procedimiento de cada una de las limpiezas.
	entrada="$1"
	hxprune -c toc -x "$entrada" | hxselect p | xml2asc | tr -d "\r" | tr "\n" " " | tr -s "[:space:]" | sed 's|</p><p>|</p>\n<p>|g' | grep -v "</a>" | while read linea; do
	echo "$linea" | html2text | tr "\n" " "; echo
	done > "$salida"
}
export -f main

parallel --env _ --linebuffer main ::: $@ 
