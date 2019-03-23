#!/bin/bash

##	extrae_pares
#
#	Este programa trabaja en conjunto con el de perl para extraer y filtrar
#	pares de palabras relacionadas con una lista de entrada.

# DEPENDENCIAS:
#	extrae_pares.pl

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
archivo_palabras_estimulo=$(realpath "$2")

cd ..

function llama_perl {
	palabra_estimulo="$1"
	archivo_entrada="$2"
	perl -C -- src/bigramas.pl "$archivo_entrada"
}
export -f llama_perl

function main {
	palabra_estimulo="$1"
	if [[ $flag_split == true ]]; then parallel llama_perl ::: "$palabra_estimulo" ::: "corpus/split_${prefijo_archivo}_out"/* 
	else llama_perl "$palabra_estimulo" "corpus/${prefijo_archivo}_out" 
	fi > "out/pares_asociacion/temp_${palabra_estimulo}_salida"
	sort "out/pares_asociacion/temp_${palabra_estimulo}_salida" | uniq -c | sort -rn \
	 > "out/pares_asociacion/${palabra_estimulo}_respuestas"
	rm "out/pares_asociacion/temp_${palabra_estimulo}_salida"
	primer1=$(grep -wnm 1 "1" "out/pares_asociacion/${palabra_estimulo}_respuestas" | awk -F ":" '{print $1}')
	if [[ "$primer1" -gt 1 ]]; then
		(( primer1-- ))
		head -n "$primer1" "out/pares_asociacion/${palabra_estimulo}_respuestas" > "out/pares_asociacion/temp_${palabra_estimulo}_salida"
		mv "out/pares_asociacion/temp_${palabra_estimulo}_salida" "out/pares_asociacion/${palabra_estimulo}_respuestas"
	fi
}
export -f main

if [[ ! -d "out/pares_asociacion/" ]];then
	mkdir -p "out/pares_asociacion/"
fi

parallel main :::: "$archivo_palabras_estimulo"

