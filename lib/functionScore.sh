#!/bin/bash

##	functionScore
#	Este programa tiene el propósito de calcular un valor que
#	indique que tan funcional es una palabra.
#	como entrada recibe una lista de palabras con sus frecuencias
#	(ver salida de vocabulario_freqs)

nombre_programa=$0

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... [-o SUFIJO_SALIDA] ARCHIVO_ENTRADA..."
    echo "	-o SUFIJO_SALIDA, --output=SUFIJO_SALIDA
		Establece el sufijo para los diferentes archivos de salida,
		si se omite se usará como salida: salida_vocabulario_freqs"
    echo "	-n VAL
		Establece un valor de peso para el numerador, por defecto 1"
    echo "	-d VAL
		Establece un valor de peso para el denominador, por defecto 1"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--output") set -- "$@" "-o" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior
export n=1
export d=1

# Parse short options
OPTIND=1
while getopts "o:nd" opt
do
  case "$opt" in
	"o") salida="$OPTARG" ;;
	"n") n="$OPTARG" ;;
	"d") d="$OPTARG" ;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

# Opción final de la salida
entrada="$1"
: ${salida:="salida_functionScores"} # Esto es una asignación por defecto de un valor, si no se ha establecido el valor de salida, se usa el segundo valor (el de la primera entrada)

awk -v n=$n -p=$p '{printf "%f %s\n", ($1*n)/(length($2)*p),$2}' "${entrada}" | sort -rn > "${salida}"
