#!/bin/bash

##	vocabulario_freqs
#	Este programa tiene el propósito de obtener el vocabulario de un corpus
#	y opcionalmente de encontrar la frecuencia de cada una de las palabras del vocabulario
#	de manera estándar hace ambas cosas

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... [-o SUFIJO_SALIDA] ARCHIVO_ENTRADA..."
    echo "	-o SUFIJO_SALIDA, --output=SUFIJO_SALIDA
		Establece el sufijo para los diferentes archivos de salida,
		si se omite se usará como salida: salida_vocabulario_freqs"
    echo "	-f, --freqs
		Activa la opción de cuenta de frecuencias
		Esta opción está activada por defecto"
    echo "	-r, --raw
		Desactiva la cuenta de frecuencias"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--output") set -- "$@" "-o" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--freqs") set -- "$@" "-f" ;;
	"--raw") set -- "$@" "-r" ;;
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior
flag_count=true

# Parse short options
OPTIND=1
while getopts "o:fr" opt
do
  case "$opt" in
	"o") salida="$OPTARG" ;;
	"f") flag_count=true ;;
	"r") flag_count=false ;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

# Opción final de la salida
: ${salida:="salida_vocabulario_freqs"} # Esto es una asignación por defecto de un valor, si no se ha establecido el valor de salida, se usa el segundo valor (el de la primera entrada)
entrada=$@

# AQUI COMIENZA EL PROGRAMA

cat $entrada | tr [:space:] "\n" | tr -s [:space:] | sort \
| if [[ $flag_count == true ]]; then uniq -c | sort -rn ; else uniq | sort;fi > "${salida}"
