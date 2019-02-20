#!/bin/bash

##	grupos_estructurales
#
#	Este programa se encarga de encontrar palabras que pertenecen a una
#	serie de grupos según la estructura de los textos y la posición en
#	que aparecen las palabras.

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

cd ..

temp_funcs_susts_full="out/temp_funcs_susts_full_${prefijo_archivo}"
temp_conector_susts="out/temp_conector_susts_${prefijo_archivo}"

########################################################################
# En primer lugar se obtiene un par de listas de palabras funcionales
#	indicadoras de sustantivos, en el caso del ingles casos típicos
#	serían "a,the" para el que se encuentra justo antes del sustantivo
#	y cosas como "on, with, at" anteriores a éstas. Es decir, se tienen
#	palabras funcionales compuestas.

function indicadoras_sustantivos {
	archivo_entrada="$1"
	grep -Po "\b(\S+) \S+ \S+ \1\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{printf("%s %s\n",$3,$4)}' 
}
export -f indicadoras_sustantivos

if [[ $flag_split == true ]]; then parallel indicadoras_sustantivos ::: "corpus/split_${prefijo_archivo}_out"/* 
else indicadoras_sustantivos "corpus/${prefijo_archivo}_out" 
fi > "$temp_funcs_susts_full"

sort "$temp_funcs_susts_full" | uniq -c | sort -rn |
	python3 "src/ge_funcs_susts.py" "${prefijo_archivo}" \
	> "out/${prefijo_archivo}_listas_funcs_susts"

rm "$temp_funcs_susts_full"

########################################################################
# En segundo lugar obtenemos un conector de sustantivos

#~ export lista1=$(head -n1 "out/${prefijo_archivo}_listas_funcs_susts")
#~ export lista2=$(tail -n+2 "out/${prefijo_archivo}_listas_funcs_susts" | head -n1)

#~ function conector_sustantivos {
	#~ archivo_entrada="$1"
	#~ grep -Po "\b($lista1) ($lista2) \S+ ($lista1)\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $NF}'
#~ }
#~ export -f conector_sustantivos

#~ if [[ $flag_split == true ]]; then parallel conector_sustantivos ::: "corpus/split_${prefijo_archivo}_out"/* 
#~ else conector_sustantivos "corpus/${prefijo_archivo}_out" 
#~ fi > "$temp_conector_susts"

#~ sort "$temp_conector_susts" | uniq -c | sort -rn | head -n1 | awk '{print $2}' \
	#~ > "out/${prefijo_archivo}_conector_susts"

#~ rm "$temp_conector_susts"
