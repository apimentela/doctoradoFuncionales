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
temp_susts_confs="out/temp_susts_confs_${prefijo_archivo}"
export temp_pares_adjs_susts="out/temp_pares_adjs_susts_${prefijo_archivo}"
temp_filtra_adjs="out/temp_filtra_adjs_${prefijo_archivo}"

temp_lista_pronombres_verbos="out/temp_lista_pronombres_verbos_${prefijo_archivo}"
temp_lista_semillas_comun="out/temp_lista_semillas_comun_${prefijo_archivo}"

########################################################################
# En primer lugar se obtiene un par de listas de palabras funcionales
	# indicadoras de sustantivos, en el caso del ingles casos típicos
	# serían "a,the" para el que se encuentra justo antes del sustantivo
	# y cosas como "on, with, at" anteriores a éstas. Es decir, se tienen
	# palabras funcionales compuestas.

function indicadoras_sustantivos {
	archivo_entrada="$1"
	#~ grep -Po "\b(\S+) \S+ \S+ \1\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{printf("%s %s\n",$3,$4)}' 
	perl -C -wln -e "/\b(\S+) \S+ \S+ \1\b/ and print $&" "$archivo_entrada" | perl -C -wln -e "/(DIGITO|[^\w\s])/ or print" | awk '{print $3,$4}' 
}
export -f indicadoras_sustantivos

if [[ $flag_split == true ]]; then parallel indicadoras_sustantivos ::: "corpus/split_${prefijo_archivo}_out"/* 
else indicadoras_sustantivos "corpus/${prefijo_archivo}_out" 
fi > "$temp_funcs_susts_full"

sort "$temp_funcs_susts_full" | uniq -c | sort -rn |
	python3 "src/ge_funcs_susts.py" "${prefijo_archivo}" \
	> "out/${prefijo_archivo}_listas_funcs_susts"

rm "$temp_funcs_susts_full"

# En el de salida, también están las relaciones con el formato:
	# KEY:W|W|W|...
	# uno por linea
	# las salidas primero estan el diccionario de  izq
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
	#~ grep -Po "\b($lista1) ($lista2) \S+ ($lista1) ($lista2)\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $4}'
	perl -C -wln -e "/\b($lista1) ($lista2) \S+ ($lista1) ($lista2)\b/ and print $&" "$archivo_entrada" | perl -C -wln -e "/(DIGITO|[^\w\s])/ or print" | awk '{print $4}'
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
funcs_susts_confs=$(grep "^${conector_susts}:" "out/${prefijo_archivo}_listas_funcs_susts")
export funcs_susts_confs=${funcs_susts_confs##*:}

########################################################################
# En tercer lugar filtramos de la lista2 aquellos elementos dudosos y nos
	# quedamos con los de mayor confiaza para la tarea de encontrar sustantivos.
	# Esto lo logramos mediante la relación que tiene el elemento conector
	# de sustantivos con los elementos de la lista2, lo cual se puede
	# obtener directamente de las relaciones que se obtuvieron al conseguir
	# las listas 1 y 2.

function sustantivos_confiables {
	archivo_entrada="$1"
	#grep -Po "\b($funcs_susts_confs) \S+ ($lista1)\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $2}'
	grep -Po "\b($funcs_susts_confs) \S+ ($conector_susts)\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $2}'
}
export -f sustantivos_confiables

if [[ $flag_split == true ]]; then parallel sustantivos_confiables ::: "corpus/split_${prefijo_archivo}_out"/* 
else sustantivos_confiables "corpus/${prefijo_archivo}_out" 
fi > "$temp_susts_confs"

sort "$temp_susts_confs" | uniq -c | sort -rn \
	> "out/${prefijo_archivo}_susts_confs"

rm "$temp_susts_confs"

########################################################################

#~ lista_sustantivos=$(awk '{print $2}' "out/${prefijo_archivo}_susts_confs" | tr "\n" "|")
#~ export lista_sustantivos=${lista_sustantivos%|}
# Esta lista es demasiado larga

########################################################################
# En cuarto lugar se tiene que ir ampliando el número de palabras.

function pares_adjs_susts {
	archivo_entrada="$1"
	grep -Po "\b($funcs_susts_confs) \S+ \S+ ($conector_susts)\b" "$archivo_entrada" | grep -Pv "(DIGITO|[^\w\s])" | awk '{printf("%s %s\n",$2,$3)}'
}
export -f pares_adjs_susts

function filtra_adjs {
	set $1
	candidato1="$1"
	candidato2="$2"
	if grep --quiet " ${candidato2}$" "out/${prefijo_archivo}_susts_confs"; then	# Si la segunda palabra está identificada como sustantivo, se prosigue
		if grep --quiet " ${candidato1}$" "out/${prefijo_archivo}_susts_confs"; then # En este caso, ambos son posibles sustantivos, hay que revisar cuál tiene mayor peso
			peso2=$(grep " ${candidato2}$" "out/${prefijo_archivo}_susts_confs" | awk '{print $1}')
			peso1=$(grep " ${candidato1}$" "out/${prefijo_archivo}_susts_confs" | awk '{print $1}')
			if [[ "$peso1" -gt "$peso2" ]]; then	# Si la primer palabra tiene mas peso, se muestra la segunda como adjetivo, de lo contrario, se muestra la primera
				echo "$candidato2"
			else
				echo "$candidato1"
			fi
		else	# Si la primer palabra no aparece como sustantivo, entonces se muestra como adjetivo
			echo "$candidato1"
		fi
	else	# Si la segunda palabra no aparece como sustantivo, se revisa la primera
		if grep --quiet " ${candidato1}$" "out/${prefijo_archivo}_susts_confs"; then	# Si si aparece, se muestra la segunda como adjetivo
			echo "$candidato2"
		fi
	fi
}
export -f filtra_adjs

if [[ $flag_split == true ]]; then parallel pares_adjs_susts ::: "corpus/split_${prefijo_archivo}_out"/* 
else pares_adjs_susts "corpus/${prefijo_archivo}_out" 
fi  > "$temp_pares_adjs_susts"

sort -u "$temp_pares_adjs_susts" | # Se hará el seccionamiento por pareja de candidatos
	parallel filtra_adjs > "${temp_filtra_adjs}" 

sort "${temp_filtra_adjs}" | uniq -c | sort -rn > "out/${prefijo_archivo}_adjs"

rm "$temp_pares_adjs_susts"
rm "${temp_filtra_adjs}"

########################################################################
# PRUEBA

#~ function busca_sustantivos {
	#~ sustantivo="$1"
	#~ archivo="$2"
	#~ while read match; do
		#~ candidato=$(echo "$match" | awk '{print $3}')
		#~ if grep --quiet " ${candidato}$" "out/${prefijo_archivo}_susts_confs"; then
			#~ echo "$match" | awk '{print $2}'
		#~ fi
	#~ done < <(grep -Po "\b$sustantivo \S+ \S+\b" "$archivo")
#~ }
#~ export -f busca_sustantivos

#~ head -n300 "out/${prefijo_archivo}_susts_confs" | awk '{print $2}' |
	#~ if [[ $flag_split == true ]]; then parallel busca_sustantivos :::: - ::: "corpus/split_${prefijo_archivo}_out"/* 
	#~ else parallel busca_sustantivos :::: - ::: "corpus/${prefijo_archivo}_out" 
	#~ fi  > "$temp_pares_adjs_susts" # Mal temporal

#~ sort "${temp_pares_adjs_susts}" | uniq -c | sort -rn > "out/${prefijo_archivo}_PRUEBA"


########################################################################
########################################################################

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
	#~ grep -Po "^($lista2) \S+ \S+ ($lista1) ($lista2)\b" "$archivo_entrada" | grep -Pv "( $conector_susts |DIGITO|[^\w\s])"
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
