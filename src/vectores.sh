#!/bin/bash

##	vectores
#	Este programa viene después del preprocesamiento, tiene como objetvo obtener
#	los vectores de las palabras, por lo que primero obtiene los contextos con
#	ayuda del programa de perl
#	Este programa también llama al programa de python que arma los vectores de
#	las palabras una vez que se ha llevado a cabo el preprocesamiento
#	se recibe como entrada el prefijo del archivo a procesar
#	La salida de la lista de contextos funcionales se encontrará en ../out/SUFIJO_SALIDA_contextos
##	DEPENDENCIAS
#	- parallel
#	- contextos_funcs.pl

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
	echo "	-k DIM
		Establece el número de dimensiones que se espera obtener del vector
		OJO: este número debe ser igual o menor al que se tenga de palabras
		funcionales. Este número indica cuántas palabras funcionales se van
		a usar, por lo que el número de dimensiones será del doble"
	echo "	-p
		Establece si es necesario hacer el preprocesamiento de vectores,
		esto se refiere a los contextos de los que finalmente se obtendran
		dichos vectores, en caso de duda activar esta opción, por defecto
		se encuentra desactivada"
}
# Default behavior
export flag_splitted=false
export flag_pre=false

# Parse short options
OPTIND=1
while getopts "sk:p" opt
do
  case "$opt" in
	"s") flag_splitted=true;;
	"k") dimension="$OPTARG";;
	"p") flag_pre=true ;;
	":") echo "La opción -$OPTARG necesita un argumento";;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

#~ dir_io=$(realpath "$1")
#~ dir_io="${dir_salida%/*}"
#~ prefijo_archivo="${1##*/}"
export prefijo_archivo="${1}"
export salida="$prefijo_archivo"

export ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

function prevectores {
	if [[ $flag_splitted == true ]]; then parallel --linebuffer perl -C contextos_funcs.pl ::: "$ruta/out/${salida}_funcs" ::: "$ruta/corpus/split_${prefijo_archivo}_out"/* > "$ruta/out/${salida}_contextos"
	else perl -C contextos_funcs.pl "$ruta/out/${salida}_funcs" "$ruta/corpus/${salida}_out" > "$ruta/out/${salida}_contextos"
	fi
	parallel ::: pares1 pares2
}

function pares1 {
procesadores=$(nproc)
export LC_ALL=C
awk -F ":" '{
	if ($1 != ""){
		#~ n=split($2,mid, " ");
		#~ printf("%s:%s\n",mid[1],$1);	# Aqui se busca al final la palabra (que es la primera de las que se encontraron entre palabras funcionales, SE MUESTRA SEGUNDA PORQUE ES MEJOR PARA ORDENARLA SIN RUIDO, ESTO ES IMPORTANTE), como primer dato, la palabra funcional de la izquierda (la pre)
		printf("%s:%s\n",$2,$1);	# Ahora probamos sin dividir nada, la expresion funcional completa
		}
	}' "$ruta/out/${salida}_contextos" \
| sort -S1G --parallel="$procesadores" --field-separator=":" -k 2 | uniq -c | grep -v $'[\xc2\x93]' \
| awk '{
	$1=$1":";print;	# para que quede separado también el número por dos puntos
	}' > "$ruta/out/${salida}_pares1" # La opción -k es para ordenar según la segunda columna, IMPORTANTE
	#~ }' "$ruta/out/${salida}_contextos" | sort -S1G --parallel="$procesadores" -k 2 | uniq -c | grep -v $'[\xc2\x80-\xc2\xa0]' > "$ruta/out/${salida}_pares1" # La opción -k es para ordenar según la segunda columna, IMPORTANTE
}
export -f pares1
function pares2 {
procesadores=$(nproc)
export LC_ALL=C
awk -F ":" '{
	if ($3 != ""){
		#~ n=split($2,mid, " ");
		#~ printf("%s:%s\n",mid[n],$3);	# Aqui se busca al final la palabra (que es última de las que se encontraron entre palabras funcionales) , como primer dato la palabra funcional de la derecha (la post)
		printf("%s:%s\n",$2,$3);	# Ahora probamos sin dividir nada, la expresion funcional completa
		}
	}' "$ruta/out/${salida}_contextos" \
| sort -S1G --parallel="$procesadores" --field-separator=":" -k 2 | uniq -c | grep -v $'[\xc2\x93]' \
| awk '{
	$1=$1":";print;	# para que quede separado también el número por punto y coma
	}' > "$ruta/out/${salida}_pares2"
	#~ }' "$ruta/out/${salida}_contextos" | sort -S1G --parallel="$procesadores" -k 2 | uniq -c | grep -v $'[\xc2\x80-\xc2\xa0]' > "$ruta/out/${salida}_pares2"
}
export -f pares2


# AQUI COMIENZA EL PROGRAMA

if [[ $flag_pre == true ]]; then prevectores; fi
export procesadores=$(nproc)

if [ -z "$dimension" ]; then dimension=$(cat "$ruta/out/${prefijo_archivo}_funcs" | wc -l); fi	 # si no se especifica una dimension, podemos usar la longitud de las palabras funcionales
python3 vectores.py "$ruta/out/${prefijo_archivo}_vocab" "$ruta/out/${prefijo_archivo}_funcs" "$ruta/out/${prefijo_archivo}_pares1" "$ruta/out/${prefijo_archivo}_pares2" "$ruta/out/${prefijo_archivo}_vectores_temp" "$dimension"
dimension_sort=$(( dimension * 2 + 2 ))	# El vector es del doble de las palabras funcionales a usar, la suma de otros dos es 1 para la palabra y otro para la suma del total de apariciones que es la que usa el sort
sort -S1G --parallel="$procesadores" -nr -k "$dimension_sort" "$ruta/out/${prefijo_archivo}_vectores_temp" | awk '{NF--; print}' > "$ruta/out/${prefijo_archivo}_vectores"
rm "$ruta/out/${prefijo_archivo}_vectores_temp"
