#!/bin/bash

##	vectores
#	Este programa viene después del preprocesamiento, tiene como objetvo obtener
#	los vectores de las palabras, por lo que primero obtiene los contextos con
#	ayuda del programa de perl
#	Este programa también llama al programa de python que arma los vectores de
#	las palabras una vez que se ha llevado a cabo el preprocesamiento
#	se recibe como entrada el prefijo del archivo a procesar
##	DEPENDENCIAS
#	- parallel

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... SUFIJO_IO"
    echo "	-s
		Establece si se trata de un archivo dividido o no, por defecto
		esta opción está desactivada"
	echo "	-k DIM
		Establece el número de dimensiones que se espera obtener del vector
		OJO: este número debe ser igual o menor al que se tenga de palabras
		funcionales. Este número indica cuántas palabras funcionales se van
		a usar, por lo que el número de dimensiones será del doble"
	echo "	-e REMPLAZO
		Recibe como parámetro la etiqueta con la que se van a reemplazar
		todos los números, por defecto esta opción está activada
		con la etiqueta DIGITO. Es útil para filtrarse y quitarse de la lista
		de palabras funcionales"
}
# Default behavior
flag_splitted=false
etiqueta_DIGITO="DIGITO"

# Parse short options
OPTIND=1
while getopts "sk:e:" opt
do
  case "$opt" in
	"s") flag_splitted=true;;
	"k") dimension="$OPTARG";;
	"e") etiqueta_DIGITO="$OPTARG" ;;
	":") echo "La opción -$OPTARG necesita un argumento";;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

#~ dir_io=$(realpath "$1")
#~ dir_io="${dir_salida%/*}"
#~ prefijo_archivo="${1##*/}"
prefijo_archivo="${1##*/}"

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit # AQUI COMIENZA EL PROGRAMA
ruta=$(realpath ..)

python3 vectores.py "$ruta/out/${prefijo_archivo}_vocab" "$ruta/out/${prefijo_archivo}_funcs" "$ruta/out/${prefijo_archivo}_pares1" "$ruta/out/${prefijo_archivo}_pares2" "$ruta/out/${prefijo_archivo}_vectores_temp" "$dimension"
dimension_sort=$(( dimension * 2 + 2 ))	# El vector es del doble de las palabras funcionales a usar, la suma de otros dos es 1 para la palabra y otro para la suma del total de apariciones que es la que usa el sort
sort -nr -k "$dimension_sort" "$ruta/out/${prefijo_archivo}_vectores_temp" | awk '{$NF--; print}' > "$ruta/out/${prefijo_archivo}_vectores"
rm "$ruta/out/${prefijo_archivo}_vectores_temp"
