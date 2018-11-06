#!/bin/bash

##	noFuncs
#	Este programa tiene el propósito de eliminar palabras funcionales.
##	DEPENDENCIAS
#	- noFuncs.pl
#	- parallel

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... SUFIJO_IO"
    echo "	-s
		Establece si se trata de un archivo dividido o no, por defecto
		esta opción está desactivada, esta opción solo tiene efecto cuando
		se va a hacer el preprocesamiento para hacer la lectura de la carpeta
		en lugar del archivo único"
}
# Default behavior
flag_splitted=false

# Parse short options
OPTIND=1
while getopts "s" opt
do
  case "$opt" in
	"s") flag_splitted=true;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

export prefijo="$1"
archivo_palabras_funcionales="out/${prefijo}_multifuncs"

export ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

function filtro {
	ruta_funcs="$1"
	ruta_corpus="$2"
	perl -C noFuncs.pl "$ruta_funcs" "$ruta_corpus"
}
export -f filtro

function agrupador {
	procesadores=$(nproc)
	export LC_ALL=C
	cat | sort -S1G --parallel="$procesadores" | uniq -c
}

if [[ $flag_splitted == true ]]; then parallel --linebuffer filtro ::: "$ruta/out/${prefijo}_multifuncs" ::: "$ruta/corpus/split_${prefijo}_out"/*
else filtro "$ruta/out/${prefijo}_multifuncs" "$ruta/corpus/${prefijo}_out"
fi | tr -s "[:space:]" > "$ruta/out/${prefijo}_noFuncs"
