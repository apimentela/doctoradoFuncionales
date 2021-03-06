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
	echo "	-f, --punct2func
		Utiliza signos de puntuacion (comas y puntos y comas) como palabras funcionales.
		Esta opción tiene precedencia sobre -p."
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
	echo "	-t , --splitted
		Especifica si la entrada ya se encuentra dividida"
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
	"--punct2func") set -- "$@" "-f" ;;
	"--mayus") set -- "$@" "-M" ;;
	"--minus") set -- "$@" "-m" ;;
	"--help") set -- "$@" "-h" ;;
	"--ayuda") set -- "$@" "-h" ;;
	"--num") set -- "$@" "-n" ;;
	"--digito") set -- "$@" "-d" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--empty") set -- "$@" "-e" ;;
	"--splitlines") set -- "$@" "-s" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--splitted") set -- "$@" "-t";;
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior
export flag_wiki=false
export flag_parentesis=false
export flag_punct=false
export flag_punct2func=false
flag_mayus=false
export flag_minus=true
export flag_num=false
export etiqueta_DIGITO="DIGITO"
export flag_empty=false
flag_split=false
split_LINES=50000
export flag_splitted=false

# Parse short options
OPTIND=1
while getopts "o:wpbs:Mmhnd:eft" opt
do
  case "$opt" in
	"o") salida="$OPTARG" ;;
	"w") flag_wiki=true ;;
	"b") flag_parentesis=true ;;
	"p") flag_punct=true ;;
	"f") flag_punct2func=true ;;
	"M") flag_mayus=true ; flag_minus=false ;;
	"m") flag_minus=true ; flag_mayus=false ;;
	"h") usage; exit 0 ;;
	"n") flag_num=true ;;
	"d") etiqueta_DIGITO="$OPTARG" ;;
	"e") flag_empty=true ;;
	"s") split_LINES="$OPTARG"; flag_split=true;;
	"t") flag_splitted=true ; flag_split=false ;;
	":") if [[ $OPTARG != "s" ]]; then echo "La opción -$OPTARG necesita un argumento"; else flag_split=true; fi;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

# Opción final de la salida
: ${salida:="salida_limpia_corpus"} # Esto es una asignación por defecto de un valor, si no se ha establecido el valor de salida, se usa el segundo valor (el de la primera entrada)
export salida
# AQUI COMIENZA EL PROGRAMA

# | sed 's/ / /g'

function main {
##	Esta es la función principal del programa
#	utiliza las banderas de las opciones para hacer el procedimiento de cada una de las limpiezas.
	archivo_entrada="$1"
	nombre="${archivo_entrada##*/}"
	cat "$archivo_entrada" | iconv -f utf-8 -t utf-8 -c \
	| if [[ $flag_wiki == true ]]; then sed -e 's|^</*doc.*$||g'; else cat; fi \
	| if [[ $flag_parentesis == false ]]; then sed -e 's|([^)]*)||g'; else cat; fi \
	| if [[ $flag_minus == true ]]; then perl -C -ne 'print lc'; else cat; fi \
	| if [[ $flag_num == false ]]; then perl -C -pe 's/\S*\d\S*/'"$etiqueta_DIGITO"'/g'; else cat; fi \
	| if [[ $flag_punct2func == true ]]; then perl -C -pe 's/(?<=\S)\.(?=\S)/\a/g' | tr '.' '\n' | tr '\a' '.' | perl -C -pe 's/([^\w\s])(?=[^\w\s])/\1 /g' | perl -C -pe 's/(?<=\S)([^\w\s])(?=\s|$)/ \1/g' | perl -C -pe 's/(?:\s|^)\K([^\w\s])(?=\S)/\1 /g' | sed -e 's/^ *//g'
		else if [[ $flag_punct == false ]]; then sed -e 's|[[:punct:]]||g'; else cat; fi
	  fi \
	| if [[ $flag_empty == false ]]; then tr -s [:space:]; else cat; fi \
	| if [[ $flag_splitted == true ]]; then cat - > "${salida}_$nombre"; echo "escrito archivo $nombre"; else cat - > "$salida"; fi
}
export -f main

#FIXME: En algunos puntos del corpus hay espacios que son identicos a los espacios per no son espacios, hay que limpiar eso, tampoco son capturados por [:space:]
#TODO: Este programa procesa en paralelo el archivo dividido, pero después los junta para volverlos a dividir nuevamente, creo que se puede evitar ese paso

parallel --linebuffer main ::: $@ \
| if [[ $flag_splitted == true ]]; then echo "estaba dividido"; else cat; fi \
| if [[ $flag_split == true ]]; then split -l "$split_LINES" - "${salida}_"; else cat - > "$salida";fi
