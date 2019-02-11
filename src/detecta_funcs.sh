#!/bin/bash

#	Este programa ...
## DEPENDENCIAS
#	parallel

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

prefijo_archivo="$1"

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)


function main {
	archivo_entrada="$1"
}
export -f main

if [[ $flag_splitted == true ]]; then parallel main ::: "$ruta/corpus/split_${prefijo_archivo}_out"/* 
else main "$ruta/corpus/${prefijo_archivo}_out" 
fi 
