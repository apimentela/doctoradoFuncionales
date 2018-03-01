#!/bin/bash

##	preprocesamiento
#	Este programa tiene el propósito de manipular un corpus de texto (inicialmente diseñado para ser de wikipedia)
#	para limpiarlo en primer lugar (con ayuda de limpia_corpus) y para obtener vocabulario, frecuencias y scores
#	de palabras funcionales (con vocabulario_frecuencias y functionScores respectivamente).
#	Más adelante también usa los patrones para hacer la detección de contextos funcionales y no funcionales
#	con ayuda de un programa de perl.
#	La salida del vocabulario con las frecuencias se encontrará en ../out/SUFIJO_SALIDA_freqs
#	La salida de la lista de palabras funcionales se encontrará en ../out/SUFIJO_SALIDA_funcs
#	La salida de la lista de scores funcionales se encontrará en ../out/SUFIJO_SALIDA_scores
#	La salida de la lista de contextos funcionales se encontrará en ../out/SUFIJO_SALIDA_contexts
#	Las salidas del corpus limpio depende de si los archivos se van a dividir o no.
#	Si se dividen se sacan los corpus limpios a ../corpus/split_out/SUFIJO_SALIDA_*
#	Si no se divide, se saca el corpus limpio a ../corpus/SUFIJO_SALIDA_out
##	DEPENDENCIAS
#	- parallel

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... SUFIJO_SALIDA ARCHIVO_ENTRADA..."
    echo "	-S [LINES], --Splitlines[=LINES]
		Divide la entrada en LINES cantidad de lineas si no se da un valor,
		se usan 50,000.
		Las divisiones se guardan en ../corpus/split/ARCHIVO_ENTRADA_*"
    echo "	-s [LINES], --splitlines[=LINES]
		Divide la salida en LINES cantidad de lineas si no se da un valor,
		se usan 50,000. Esta opción está activada por defecto y ocasiona que
		el corpus vaya a la carpeta ../corpus/split_out"
	echo "	-j
		Desactiva la división de líneas. Esto ocasiona que el corpus limpio
		se escriba en ../corpus/SUFIJO_SALIDA_out"
	echo "	-e REMPLAZO, --etiqueta=REMPLAZO
		Recibe como parámetro la etiqueta con la que se van a reemplazar
		todos los números, por defecto esta opción está activada
		con la etiqueta DIGITO. Es útil para filtrarse y quitarse de la lista
		de palabras funcionales"
	echo "	-h NUM, --head=NUM
		Determina el NUM de palabras que se van a tomar como funcionales,
		esto es a partir de los scores funcionales"
	echo "	-n VAL
		Establece un valor de peso para el numerador, por defecto 1"
    echo "	-d VAL
		Establece un valor de peso para el denominador, por defecto 1"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--Splitlines") set -- "$@" "-S" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--splitlines") set -- "$@" "-s" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--head") set -- "$@" "-h" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--etiqueta") set -- "$@" "-e" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
	*)        set -- "$@" "$arg"
  esac
done

# Default behavior
export flag_split=true
export split_LINES=50000
export flag_Split=false
export Split_LINES=50000
export etiqueta_DIGITO="DIGITO"
export head_funcs=50
export n=1
export d=1
export out="../out" #TODO: dar opcion
export corpus="../corpus" #TODO: dar opcion
export split="split" #TODO: dar opcion
export split_out="split_out" #TODO: dar opcion

# Parse short options
OPTIND=1
while getopts "s:je:S:h:nd" opt
do
  case "$opt" in
	"S") Split_LINES="$OPTARG"; flag_Split=true;;
	"s") split_LINES="$OPTARG"; flag_split=true;;
	"j") flag_split=false;;
	"e") etiqueta_DIGITO="$OPTARG" ;;
	"h") head_funcs="$OPTARG" ;;
	"n") n="$OPTARG" ;;
	"d") d="$OPTARG" ;;
	":") if [[ $OPTARG != "s" ]]; then echo "La opción -$OPTARG necesita un argumento"; else flag_split=true; fi;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

export dir_salida=$(realpath "$1")
	dir_salida="${dir_salida%/*}"
export salida="${1##*/}"
shift
export dir_entrada=$(realpath "$1")
	dir_entrada="${dir_entrada%/*}"
export entrada_name="${1##*/}"
export entrada1="$dir_entrada/${1##*/}"
for arg in "$@"; do
	shift
	set -- "$@" "$dir_entrada/${arg##*/}"
done
export entrada=$@

cd "${BASH_SOURCE%/*}" || exit # AQUI COMIENZA EL PROGRAMA

ruta=$(realpath ..)

if [[ ! -d "../corpus" ]]; then mkdir "../corpus"; fi
if [[ ! -d "../out" ]]; then mkdir "../out"; fi

if [[ $flag_Split == true ]]; then
	if [[ ! -d "../corpus/split" ]]; then mkdir -p "../corpus/split"; fi
	split -l "$Split_LINES" "$entrada1" "../corpus/split/${entrada_name}_"
	entrada=$(realpath "../corpus/split")
	entrada="$entrada/*"
fi

if [[ $flag_split == true ]]; then
	if [[ ! -d "../corpus/split_out" ]]; then mkdir -p "../corpus/split_out"; fi
	bash ../lib/limpia_corpus.sh -s "$split_LINES" -wo "$ruta/corpus/split_out/$salida" $entrada
	bash ../lib/vocabulario_freqs.sh -o "$ruta/out/${salida}_freqs" "$ruta/corpus/split_out"/*
	bash ../lib/functionScore.sh -n "$n" -d "$d" -o "$ruta/out/${salida}_scores" "$ruta/out/${salida}_freqs"
	awk '{printf "%s\n",$2}' "../out/${salida}_scores" | grep -v "$etiqueta_DIGITO" | head -n "$head_funcs" > "../out/${salida}_funcs"
	parallel --linebuffer perl -C contextos_funcs.pl ::: "../out/${salida}_funcs" ::: "../corpus/split_out"/* > "../out/${salida}_contextos"
else
	bash ../lib/limpia_corpus.sh -wo "$ruta/corpus/${salida}_out" $entrada
	bash ../lib/vocabulario_freqs.sh -o "$ruta/out/${salida}_freqs" "$ruta/corpus/${salida}_out"
	bash ../lib/functionScore.sh -n "$n" -d "$d" -o "$ruta/out/${salida}_scores" "$ruta/out/${salida}_freqs"
	awk '{printf "%s\n",$2}' "../out/${salida}_scores" | grep -v "$etiqueta_DIGITO" | head -n "$head_funcs" > "../out/${salida}_funcs"
	perl -C contextos_funcs.pl "../out/${salida}_funcs" "../corpus/${salida}_out" > "../out/${salida}_contextos"
fi
