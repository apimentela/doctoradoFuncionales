#!/bin/bash

##	vocabulario_freqs
#	Este programa tiene el propósito de obtener el vocabulario de un corpus
#	y opcionalmente de encontrar la frecuencia de cada una de las palabras del vocabulario
#	de manera estándar hace ambas cosas
##	DEPENDENCIAS
#	- parallel

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
function post_perl {
	export LC_ALL=C
	sort "$salida_temp" \
	| if [[ $flag_count == true ]]; then uniq -c | sort -rn -S1G --parallel="$procesadores" | tee "${salida_freqs}" | awk '{printf("%s\n",$2)}' | sort -S1G --parallel="$procesadores" ; else uniq ;fi | grep -v $'[\xc2\x93]' > "$salida_vocab"
	#~ | if [[ $flag_count == true ]]; then uniq -c | sort -rn -S1G --parallel="$procesadores" | grep -v $'[\xc2\x80-\xc2\xa0]' | tee "${salida_freqs}" | awk '{printf("%s\n",$2)}' | sort -S1G --parallel="$procesadores" ; else uniq | grep -v $'[\xc2\x80-\xc2\xa0]';fi > "$salida_vocab"
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
export flag_count=true

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
: ${salida:="salida_vocabulario"} # Esto es una asignación por defecto de un valor, si no se ha establecido el valor de salida, se usa el segundo valor (el de la primera entrada)
entrada=$@
export salida_temp="${salida}_temp"
export salida_freqs="${salida}_freqs"
export salida_vocab="${salida}_vocab"

export procesadores=$(nproc)


# AQUI COMIENZA EL PROGRAMA
# tr [:space:] "\n" NO FUNCIONA PORQUE HAY ESPACIOS RAROS QUE NO SON ESPACIOS Y NO SON DETECTADOS TAMPOCO
# grep -v $'[\xc2\x80-\xc2\xa0]' ESTA FUNCION LA PONGO PARA QUE SE ELIMINEN UNOS CARACTERES QUE NO PUEDO ELIMINAR CON NADA GENERAL....

function main() {
##	Esta es la función principal del programa
#	si es que se detectan muchos archivos de entrada para paralelización
	entrada="$1"
	cat "$entrada" | perl -C -pe "s/\s/\n/g" | tr -s [:space:]
}
export -f main

if [ "$#" -gt 1 ]; then parallel main ::: $entrada
else cat $entrada | perl -C -pe "s/\s/\n/g" | tr -s [:space:]
fi > "$salida_temp"

post_perl

rm "$salida_temp"
