#!/bin/bash

##	bigramas
#
#	Este programa se encarga de encontrar bigramas de un documento.

# DEPENDENCIAS:
#	bigramas.pl

nombre_programa="$BASH_SOURCE"

# Default behavior
flag_split=true

# Parse short options
OPTIND=1
while getopts "sj" opt
do
  case "$opt" in
	"s") flag_split=true;;
	"j") flag_split=false;;
	":") echo "La opción -$OPTARG necesita un argumento";;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

export prefijo_archivo="$1"

cd ..

function main {
	archivo_entrada="$1"
	perl -C -- src/bigramas.pl "$archivo_entrada"
}
export -f main

if [[ $flag_split == true ]]; then parallel main ::: "corpus/split_${prefijo_archivo}_out"/* 
else main "corpus/${prefijo_archivo}_out" 
fi > "temp_bigramas"

sort -u "temp_bigramas" > "out/${prefijo_archivo}_bigramas"

cat "out/${prefijo_archivo}_bigramas" | tr " " "\n" > "temp_bigramas"
sort -u "temp_bigramas" > "out/${prefijo_archivo}_vocab"

rm "temp_bigramas"

