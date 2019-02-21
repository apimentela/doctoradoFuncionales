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
temp_lista_pronombres_verbos="out/temp_lista_pronombres_verbos_${prefijo_archivo}"
temp_lista_semillas_comun="out/temp_lista_semillas_comun_${prefijo_archivo}"

########################################################################
# En primer lugar se obtiene un par de listas de palabras funcionales
	# indicadoras de sustantivos, en el caso del ingles casos típicos
	# serían "a,the" para el que se encuentra justo antes del sustantivo
	# y cosas como "on, with, at" anteriores a éstas. Es decir, se tienen
	# palabras funcionales compuestas.

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

# En el archivo json, las salidas primero estan el diccionario de  izq
	# a derecha y luego el de derecha a izquierda

########################################################################

export lista1=$(head -n1 "out/${prefijo_archivo}_listas_funcs_susts")
export lista2=$(tail -n+2 "out/${prefijo_archivo}_listas_funcs_susts" | head -n1)

########################################################################
# En segundo lugar obtenemos un conector de sustantivos. La intuición
	# detrás de esto es buscar un sustantivo (después de la combinación de
	# las primeras dos listas) seguido de nuevo por una palabra de la primera
	# lista, es decir, buscar un sustantivo seguido de otro. Esa última 
	# palabra (que está en la primera lista) es la que nos interesa, pues
	# la que más se repita será, seguramente, un conector de sustantivos.

function conectores_sustantivos {
	archivo_entrada="$1"
	#grep -Po "\b($lista1) ($lista2) \S+ ($lista1)\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $NF}'
	grep -Po "\b($lista2) \S+ ($lista1)\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $NF}'
}
export -f conectores_sustantivos

if [[ $flag_split == true ]]; then parallel conectores_sustantivos ::: "corpus/split_${prefijo_archivo}_out"/* 
else conectores_sustantivos "corpus/${prefijo_archivo}_out" 
fi > "$temp_conector_susts"

sort "$temp_conector_susts" | uniq -c | sort -rn \
	> "out/${prefijo_archivo}_conectores_susts"

rm "$temp_conector_susts"

########################################################################

export conector_susts=$(head -n1 "out/${prefijo_archivo}_conectores_susts" | awk '{print $2}')

########################################################################
# En tercer lugar filtramos de la lista2 aquellos elementos dudosos y nos
	# quedamos con los de mayor confiaza para la tarea de encontrar sustantivos.
	# Esto lo logramos mediante la relación que tiene el elemento conector
	# de sustantivos con los elementos de la lista2, lo cual se puede
	# obtener directamente de las relaciones que se obtuvieron al conseguir
	# las listas 1 y 2.


########################################################################
# En X lugar buscamos las listas de palabras que nos llevarán a
	# obtener una semilla de sustantivos y verbos. La lógica detrás de esto
	# es el simplificar lo más posible las posibilidades de combinaciones de
	# palabras, es decir, si buscamos que una oración comienze con un elemento
	# de la segunda lista, casi podemos garantizar que la siguiente palabra
	# será un sustantivo (o un sustantivo compuesto), pero en el caso de que
	# no sea un sustantivo compuesto, la siguiente será un verbo, y para cortar
	# allí, buscamos de nuevo el patrón de lista1 seguido de lista2. Para
	# aumentar la probabilidad de que no haya sustantivos compuestos, eliminamos
	# todo aquello que tenga al conector de sustantivos.

#~ function lista_saca_comun {
	#~ archivo_entrada="$1"
	#~ grep -Po "^($lista2) \S+ ($lista1) ($lista2)\b" "$archivo_entrada" | grep -Pv "( $conector_susts |DIGITO|[^\w\s])"
#~ }
#~ export -f lista_saca_comun

#~ if [[ $flag_split == true ]]; then parallel lista_saca_comun ::: "corpus/split_${prefijo_archivo}_out"/* 
#~ else lista_saca_comun "corpus/${prefijo_archivo}_out" 
#~ fi > "$temp_lista_saca_comun"

#~ # Con los patrones antes obtenidos, hacemos una separación de dos pares:
	#~ # primera-segunda; tercera-cuarta. Que esperamos que sean:
	#~ # funcional-sustantivo; verbo-funcional. Esto nos daría muy buena información
	#~ # de dichas funcionales, por lo que para aumentar la probabilidad de
	#~ # tengan información significativa, se buscan las funcionales que estén
	#~ # relacionadas a mayor cantidad de palabras diferentes

#~ function lista_saca_susts {
	#~ awk '{printf("%s %s\n",$1,$2)}' "$temp_lista_saca_comun" \
		#~ > "$temp_lista_saca_susts"
	#~ sort -u "$temp_lista_saca_susts" | awk '{print $1}' | sort | uniq -c | sort -rn \
		#~ > "out/${prefijo_archivo}_lista_saca_susts"
	#~ rm "$temp_lista_saca_susts"
#~ }
#~ export -f lista_saca_susts
#~ function lista_saca_verbos {
	#~ awk '{printf("%s %s\n",$2,$3)}' "$temp_lista_saca_comun" \
		#~ > "$temp_lista_saca_verbos"
	#~ sort -u "$temp_lista_saca_verbos" | awk '{print $2}' | sort | uniq -c | sort -rn \
		#~ > "out/${prefijo_archivo}_lista_saca_verbos"
	#~ rm "$temp_lista_saca_verbos"
#~ }
#~ export -f lista_saca_verbos


#~ parallel ::: lista_saca_susts lista_saca_verbos

#~ rm "$temp_lista_saca_comun"


########################################################################

#~ lista_saca_susts=$(awk '{print $2}' "out/${prefijo_archivo}_lista_saca_susts" | tr "\n" "|")
#~ lista_saca_susts=${lista_saca_susts%|}
#~ lista_saca_verbos=$(awk '{print $2}' "out/${prefijo_archivo}_lista_saca_verbos" | tr "\n" "|")
#~ lista_saca_verbos=${lista_saca_verbos%|}
#~ export primer_saca_susts=$(head -n1 "out/${prefijo_archivo}_lista_saca_susts" | awk '{print $2}')
#~ export primer_saca_verbos=$(head -n1 "out/${prefijo_archivo}_lista_saca_verbos" | awk '{print $2}')

########################################################################
# En cuarto lugar buscamos pronombres. La lógica detrás de esto es que
	# en la lista2 puede haber pronombres (es decir que luego de ellos
	# venga un verbo) y para encontrarlo, usaremos la principal palabra
	# asociada a los verbos para encontrar palabras de la lista2 seguida
	# de verbos (o buenos candidatos)
# FIXME: Esto falló

#~ function lista_pronombres_verbos {
	#~ archivo_entrada="$1"
	#~ #grep -Po "^($lista2) \S+ $primer_saca_verbos ($lista2)" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])"
	#~ #grep -Po "^($lista2) \S+ $conector_susts\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $2}'
	#~ grep -Po "\b$conector_susts \S+" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $2}'
#~ }
#~ export -f lista_pronombres_verbos

#~ if [[ $flag_split == true ]]; then parallel lista_pronombres_verbos ::: "corpus/split_${prefijo_archivo}_out"/* 
#~ else lista_pronombres_verbos "corpus/${prefijo_archivo}_out" 
#~ fi > "$temp_lista_pronombres_verbos"

#~ sort "$temp_lista_pronombres_verbos" | uniq -c | sort -rn \
	#~ > "out/${prefijo_archivo}_listas_pronombres_verbos"

#~ rm "$temp_lista_pronombres_verbos"

########################################################################
# En X lugar buscamos la primer semilla de sustantivos y verbos.



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

#~ grep -Po "^($lista2) \S+ $conector_susts ($lista2) \S+\b" "corpus/${prefijo_archivo}_out"  | sort | uniq -c | sort -rn 

########################################################################

#~ lista_susts=$(awk '{print $3}' "out/${prefijo_archivo}_listas_semillas_comun" | sort | uniq -c | sort -rn | awk '{print $2}' | tr "\n" "|")
#~ lista_susts=${lista_susts%|}
#~ lista_verbos=$(awk '{print $4}' "out/${prefijo_archivo}_listas_semillas_comun" | sort | uniq -c | sort -rn | awk '{print $2}' | tr "\n" "|")
#~ lista_verbos=${lista_verbos%|}

########################################################################

#~ echo "$lista_verbos" | tr "|" "\n" | while read verbo; do
	#~ grep -Po "\S+ ($verbo)\b" "corpus/${prefijo_archivo}_out"  | sort | uniq -c | sort -rn | head -n1 
#~ done #| awk '{print $2}' | sort | uniq -c | sort -rn 


#grep -Po "\S+ ($lista_verbos)" "corpus/${prefijo_archivo}_out"   | awk '{print $1}' | sort | uniq -c | sort -rn 



#python3-q-text-as-data 'SELECT SUM(c1) AS total,c2 FROM temporal.tsv GROUP BY c2 ORDER BY total desc'
