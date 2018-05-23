#!/bin/bash

##	limpia_corpus
#	Este programa tiene el propósito de manipular un corpus de texto (inicialmente diseñado para ser de wikipedia)
#	el programa tiene una serie de opciones para modificar la salida y las cosas que se eliminan del texto
#	pero de manera estándar:
#		- Quita todas las etiquetas de los artículos de wikipedia (como son extraídas de wikiextractor)
#		- Elimina todo aquello que se encuentra entre paréntesis.
#		- Elimina todos los signos de puntuación.
#		- Convierte todas las letras en minúsculas.
#		- Cambia todos los entes (separados por espacios) que contengan algún número por la palabra clave DIGITO.
#		- Elimina las líneas vacías.
##	DEPENDENCIAS
#	- parallel

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... [-o SUFIJO_SALIDA] ARCHIVO_ENTRADA..."
    echo "	-o SUFIJO_SALIDA, --output=SUFIJO_SALIDA
		Establece el sufijo para los diferentes archivos de salida,
		si se omite se usará como salida: salida_limpia_corpus"
    echo "	-w, --wikipedia
		Activa la opción de eliminación de las etiquetas xml
		de los artículos de wikipedia" 
    echo "	-b, --brackets,--parentesis, --parenthesis
		Desactiva la eliminación de los objetos entre parentesis" 
	echo "	-p, --punct, --punctuation, --puntuacion
		Desactiva la eliminación de los signos de puntuación" 
	echo "	-M, --mayus
		Desactiva la transformación a minúsculas" 
	echo "	-m, --minus
		Activa la transformación a minúsculas, activado por defecto" 
    echo "	-h, --help, --ayuda
		Muestra la ayuda"
	echo "	-n,--num
		Desactiva la eliminación de los números" 
	echo "	-d REMPLAZO, --digito=REMPLAZO
		Recibe como parámetro la etiqueta con la que se van a reemplazar
		todos los números, por defecto esta opción está activada
		con la etiqueta DIGITO" 
    echo "	-e, --empty
		Desactiva la eliminación de las líneas vacías"
	echo "	-s [LINES], --splitlines[=LINES]
		Divide la salida en LINES cantidad de lineas
		si no se da un valor, se usan 50,000"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--output") set -- "$@" "-o" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--wikipedia") set -- "$@" "-w" ;;
	"--brackets") set -- "$@" "-b" ;;
	"--parentesis") set -- "$@" "-b" ;;
	"--parenthesis") set -- "$@" "-b" ;;
	"--punct") set -- "$@" "-p" ;;
	"--punctuation") set -- "$@" "-p" ;;
	"--puntuacion") set -- "$@" "-p" ;;
	"--mayus") set -- "$@" "-M" ;;
	"--minus") set -- "$@" "-m" ;;
	"--help") set -- "$@" "-h" ;;
	"--ayuda") set -- "$@" "-h" ;;
	"--num") set -- "$@" "-n" ;;
	"--digito") set -- "$@" "-d" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--empty") set -- "$@" "-e" ;;
	"--splitlines") set -- "$@" "-s" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior
export flag_wiki=false
export flag_parentesis=false
export flag_punct=false
export flag_mayus=false
export flag_minus=true
export flag_num=false
export etiqueta_DIGITO="DIGITO"
export flag_empty=false
export flag_split=false
export split_LINES=50000

# Parse short options
OPTIND=1
while getopts "o:wpbs:Mmhnd:e" opt
do
  case "$opt" in
	"o") salida="$OPTARG" ;;
	"w") flag_wiki=true ;;
	"b") flag_parentesis=true ;;
	"p") flag_punct=true ;;
	"M") flag_mayus=true ; flag_minus=false ;;
	"m") flag_minus=true ; flag_mayus=false ;;
	"h") usage; exit 0 ;;
	"n") flag_num=true ;;
	"d") etiqueta_DIGITO="$OPTARG" ;;
	"e") flag_empty=true ;;
	"s") split_LINES="$OPTARG"; flag_split=true;;
	":") if [[ $OPTARG != "s" ]]; then echo "La opción -$OPTARG necesita un argumento"; else flag_split=true; fi;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

# Opción final de la salida
: ${salida:="salida_limpia_corpus"} # Esto es una asignación por defecto de un valor, si no se ha establecido el valor de salida, se usa el segundo valor (el de la primera entrada)
export salida

# AQUI COMIENZA EL PROGRAMA

function main() {
##	Esta es la función principal del programa
#	utiliza las banderas de las opciones para hacer el procedimiento de cada una de las limpiezas.
	cat "$1" | iconv -f utf-8 -t utf-8 -c \
	| if [[ $flag_wiki == true ]]; then sed -e 's|^</*doc.*$||g'; else cat; fi \
	| if [[ $flag_parentesis == false ]]; then sed -e 's|([^)]*)||g'; else cat; fi \
	| if [[ $flag_minus == true ]]; then perl -C -ne 'print lc'; else cat; fi \
	| if [[ $flag_num == false ]]; then perl -C -pe 's/\S*\d\S*/'"$etiqueta_DIGITO"'/g'; else cat; fi \
	| if [[ $flag_punct == false ]]; then perl -C -pe 's/(?<=\S)\.(?=\S+)/\a/g' | tr -d '\f' | tr -d '\a' | tr -d '\v' | tr '.' '\n' | tr ';' '\v' | tr ',' '\f' | sed -e 's/[[:punct:]]//g' | tr '\f' ',' | tr '\a' '.' | tr '\v' ';' | sed -e 's/,/ , /g' | sed -e 's/;/ ; /g'; else cat; fi
#then sed -e 's|[[:punct:]]||g'; else cat; fi # ESTA INSTRUCCION ESTABA ORIGINALMENTE PARA QUITAR TODA LA PUNTUACION, PERO SERÍA INTERESANTE ANALIZAR LAS COMAS
}
export -f main

#FIXME: En algunos puntos del corpus hay espacios que son identicos a los espacios per no son espacios, hay que limpiar eso, tampoco son capturados por [:space:]
parallel --env _ --linebuffer main ::: $@ \
| if [[ $flag_empty == false ]]; then tr -s [:space:]; else cat; fi \
| if [[ $flag_split == true ]]; then split -l "$split_LINES" - "${salida}_"; else cat - > "$salida";fi
