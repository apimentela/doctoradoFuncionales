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

export prefijo_archivo="$1"

cd ..

temp_funcs_susts_full="out/temp_funcs_susts_full_${prefijo_archivo}"
temp_conector_susts="out/temp_conector_susts_${prefijo_archivo}"
export temp_lista_saca_comun="out/temp_lista_saca_comun_${prefijo_archivo}"
export temp_lista_saca_susts="out/temp_lista_saca_susts_${prefijo_archivo}"
export temp_lista_saca_verbos="out/temp_lista_saca_verbos_${prefijo_archivo}"
temp_lista_semillas_comun="out/temp_lista_semillas_comun_${prefijo_archivo}"

########################################################################
# En primer lugar se obtiene un par de listas de palabras funcionales
#	indicadoras de sustantivos, en el caso del ingles casos típicos
#	serían "a,the" para el que se encuentra justo antes del sustantivo
#	y cosas como "on, with, at" anteriores a éstas. Es decir, se tienen
#	palabras funcionales compuestas.

#~ function indicadoras_sustantivos {
	#~ archivo_entrada="$1"
	#~ grep -Po "\b(\S+) \S+ \S+ \1\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{printf("%s %s\n",$3,$4)}' 
#~ }
#~ export -f indicadoras_sustantivos

#~ if [[ $flag_split == true ]]; then parallel indicadoras_sustantivos ::: "corpus/split_${prefijo_archivo}_out"/* 
#~ else indicadoras_sustantivos "corpus/${prefijo_archivo}_out" 
#~ fi > "$temp_funcs_susts_full"

#~ sort "$temp_funcs_susts_full" | uniq -c | sort -rn |
	#~ python3 "src/ge_funcs_susts.py" "${prefijo_archivo}" \
	#~ > "out/${prefijo_archivo}_listas_funcs_susts"

#~ rm "$temp_funcs_susts_full"

########################################################################

export lista1=$(head -n1 "out/${prefijo_archivo}_listas_funcs_susts")
export lista2=$(tail -n+2 "out/${prefijo_archivo}_listas_funcs_susts" | head -n1)

########################################################################
# En segundo lugar obtenemos un conector de sustantivos

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

########################################################################

export conector_susts=$(head -n1 "out/${prefijo_archivo}_conector_susts")

########################################################################
# En tercer lugar buscamos las listas de palabras que nos llevarán a
#	obtener una semilla de sustantivos y verbos

#~ function lista_saca_comun {
	#~ archivo_entrada="$1"
	#~ grep -Po "^($lista2) \S+ \S+ ($lista1) ($lista2)\b" "$archivo_entrada" | grep -Pv "( $conector_susts |DIGITO|[^\w\s])"
#~ }
#~ export -f lista_saca_comun

#~ if [[ $flag_split == true ]]; then parallel lista_saca_comun ::: "corpus/split_${prefijo_archivo}_out"/* 
#~ else lista_saca_comun "corpus/${prefijo_archivo}_out" 
#~ fi > "$temp_lista_saca_comun"



#~ function lista_saca_susts {
	#~ awk '{printf("%s %s\n",$1,$2)}' "$temp_lista_saca_comun" \
		#~ > "$temp_lista_saca_susts"
	#~ sort -u "$temp_lista_saca_susts" | awk '{print $1}' | sort | uniq -c | sort -rn \
		#~ > "out/${prefijo_archivo}_lista_saca_susts"
	#~ rm "$temp_lista_saca_susts"
#~ }
#~ export -f lista_saca_susts
#~ function lista_saca_verbos {
	#~ awk '{printf("%s %s\n",$3,$4)}' "$temp_lista_saca_comun" \
		#~ > "$temp_lista_saca_verbos"
	#~ sort -u "$temp_lista_saca_verbos" | awk '{print $2}' | sort | uniq -c | sort -rn \
		#~ > "out/${prefijo_archivo}_lista_saca_verbos"
	#~ rm "$temp_lista_saca_verbos"
#~ }
#~ export -f lista_saca_verbos


#~ parallel ::: lista_saca_susts lista_saca_verbos

#~ rm "$temp_lista_saca_comun"


########################################################################

lista_saca_susts=$(awk '{print $2}' "out/${prefijo_archivo}_lista_saca_susts" | tr "\n" "|")
lista_saca_susts=${lista_saca_susts%|}
lista_saca_verbos=$(awk '{print $2}' "out/${prefijo_archivo}_lista_saca_verbos" | tr "\n" "|")
lista_saca_verbos=${lista_saca_verbos%|}

########################################################################
# En cuarto lugar buscamos la primer semilla de sustantivos y verbos

#~ export primer_saca_susts=$(echo "$lista_saca_susts" | tr "|" "\n" | head -n1)
#~ export primer_saca_verbos=$(echo "$lista_saca_verbos" | tr "|" "\n" | head -n1)

#~ function lista_semillas_comun {
	#~ archivo_entrada="$1"
	#~ grep -Po "^($primer_saca_susts) \S+ \S+ ($primer_saca_verbos)\b" "$archivo_entrada" | grep -Pv "( $conector_susts |DIGITO|[^\w\s])"
#~ }
#~ export -f lista_semillas_comun

#~ if [[ $flag_split == true ]]; then parallel lista_semillas_comun ::: "corpus/split_${prefijo_archivo}_out"/* 
#~ else lista_semillas_comun "corpus/${prefijo_archivo}_out" 
#~ fi > "$temp_lista_semillas_comun"

#~ sort "$temp_lista_semillas_comun" | uniq -c | sort -rn \
	#~ > "out/${prefijo_archivo}_listas_semillas_comun"

#~ rm "$temp_lista_semillas_comun"



########################################################################
# Para encontrar la palabra funcional con mayor variación después de los
#	verbos creo que tendría que ser algo como esto:
#TODO::::

#~ function agrupa_susts {
	#~ awk '{printf("%s %s\n",$2,$3)}' "out/${prefijo_archivo}_listas_semillas_comun" \
		#~ > "$temp_lista_saca_susts"
	#~ sort -u "$temp_lista_saca_susts" | awk '{print $1}' | sort | uniq -c | sort -rn \
		#~ > "out/${prefijo_archivo}_agrupa_susts"
	#~ rm "$temp_lista_saca_susts"
#~ }
#~ export -f agrupa_susts
#~ function agrupa_verbos {
	#~ awk '{printf("%s %s\n",$3,$4)}' "out/${prefijo_archivo}_listas_semillas_comun" \
		#~ > "$temp_lista_saca_verbos"
	#~ sort -u "$temp_lista_saca_verbos" | awk '{print $2}' | sort | uniq -c | sort -rn \
		#~ > "out/${prefijo_archivo}_agrupa_verbos"
	#~ rm "$temp_lista_saca_verbos"
#~ }
#~ export -f agrupa_verbos

#~ parallel ::: agrupa_susts agrupa_verbos


########################################################################

grep -Po "^($lista2) \S+ $conector_susts ($lista2) \S+\b" "corpus/${prefijo_archivo}_out"  | sort | uniq -c | sort -rn 

########################################################################

lista_susts=$(awk '{print $3}' "out/${prefijo_archivo}_listas_semillas_comun" | sort | uniq -c | sort -rn | awk '{print $2}' | tr "\n" "|")
lista_susts=${lista_susts%|}
lista_verbos=$(awk '{print $4}' "out/${prefijo_archivo}_listas_semillas_comun" | sort | uniq -c | sort -rn | awk '{print $2}' | tr "\n" "|")
lista_verbos=${lista_verbos%|}

########################################################################

#~ echo "$lista_verbos" | tr "|" "\n" | while read verbo; do
	#~ grep -Po "\S+ ($verbo)\b" "corpus/${prefijo_archivo}_out"  | sort | uniq -c | sort -rn | head -n1 
#~ done #| awk '{print $2}' | sort | uniq -c | sort -rn 


#grep -Po "\S+ ($lista_verbos)" "corpus/${prefijo_archivo}_out"   | awk '{print $1}' | sort | uniq -c | sort -rn 



#python3-q-text-as-data 'SELECT SUM(c1) AS total,c2 FROM temporal.tsv GROUP BY c2 ORDER BY total desc'
