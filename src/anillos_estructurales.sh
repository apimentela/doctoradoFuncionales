#!/bin/bash

##	anillos_estructurales

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

function anillos {
	archivo_entrada="$1"
	perl -C -wln -e "/\b(\S+) \S+ \S+ \S+ \1\b/ and print $&" "$archivo_entrada" | perl -C -wln -e "/(DIGITO|[^\w\s])/ or print"
}
export -f anillos

if [[ $flag_split == true ]]; then parallel anillos ::: "corpus/split_${prefijo_archivo}_out"/* 
else anillos "corpus/${prefijo_archivo}_out" 
fi > "temp_anillos"

sort "temp_anillos" | uniq -c | sort -rn | head -n 10000 | awk '{$1=""; print $0}' | sed 's/^ //g' > "out/${prefijo_archivo}_anillos"

rm "temp_anillos"
