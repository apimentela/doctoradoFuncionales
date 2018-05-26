#!/bin/bash

##	functionScore
#	Este programa tiene el propósito de manipular el vocabulario y frecuencias para obtener scores
#	de palabras funcionales (con vocabulario_frecuencias y functionScores respectivamente).
#	La salida de la lista de palabras funcionales se encontrará en ../out/SUFIJO_SALIDA_funcs
#	La salida de la lista de scores funcionales se encontrará en ../out/SUFIJO_SALIDA_scores
##	DEPENDENCIAS
#	../lib/functionScore.sh

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... SUFIJO_IO"
    echo "	-n VAL
		Establece un valor de peso para el numerador, por defecto 1"
    echo "	-d VAL
		Establece un valor de peso para el denominador, por defecto 1"
	echo "	-e REMPLAZO, --etiqueta=REMPLAZO
		Recibe como parámetro la etiqueta con la que se van a reemplazar
		todos los números, por defecto esta opción está activada
		con la etiqueta DIGITO. Es útil para filtrarse y quitarse de la lista
		de palabras funcionales"
	echo "	-k DIM
		Establece el número de dimensiones que se espera obtener del vector
		OJO: este número debe ser igual o menor al que se tenga de palabras
		funcionales. Este número indica cuántas palabras funcionales se van
		a usar, por lo que el número de dimensiones será del doble, por 
		dejecto, este valor toma 50 palabras funcionales a crear"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--etiqueta") set -- "$@" "-e" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior
export n=1
export d=1
export etiqueta_DIGITO="DIGITO"
export dim_funcs=50

# Parse short options
OPTIND=1
while getopts "n:d:k:" opt
do
  case "$opt" in
	"n") n="$OPTARG" ;;
	"d") d="$OPTARG" ;;
	"k") dim_funcs="$OPTARG" ;;
	"e") etiqueta_DIGITO="$OPTARG" ;;
	":") echo "La opción $OPTARG necesita parámetros" >&2 ; usage ; exit 1;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

# Opción final de la salida
entrada="$1"
salida="$1"
#~ : ${salida:="salida_functionScores"} # Esto es una asignación por defecto de un valor, si no se ha establecido el valor de salida, se usa el segundo valor (el de la primera entrada)

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit # AQUI COMIENZA EL PROGRAMA
ruta=$(realpath ..)

# AQUI COMIENZA EL PROGRAMA

bash ../lib/functionScore.sh -n "$n" -d "$d" -o "$ruta/out/${salida}_scores" "$ruta/out/${salida}_freqs"
awk '{printf("%s\n"),$2}' "$ruta/out/${salida}_scores" | grep -v "$etiqueta_DIGITO" | head -n "$dim_funcs" > "$ruta/out/${salida}_funcs"
