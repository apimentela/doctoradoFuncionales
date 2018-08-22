#!/bin/bash

##	preprocesamiento
#	Este programa tiene el propósito de manipular un corpus de texto (inicialmente diseñado para ser de wikipedia)
#	para limpiarlo en primer lugar (con ayuda de limpia_corpus) y para obtener vocabulario y frecuencias
#	La salida del vocabulario se encontrará en ../out/SUFIJO_SALIDA_vocab
#	La salida de las frecuencias se encontrará en ../out/SUFIJO_SALIDA_freqs
#	La salida de la lista de contextos funcionales se encontrará en ../out/SUFIJO_SALIDA_contexts
#	Las salidas del corpus limpio depende de si los archivos se van a dividir o no.
#	Si se dividen se sacan los corpus limpios a ../corpus/split_out/SUFIJO_SALIDA_*
#	Si no se divide, se saca el corpus limpio a ../corpus/SUFIJO_SALIDA_out
##	DEPENDENCIAS
#	- ../lib/limpia_corpus.sh
#	- ../lib/vocabulario_freqs.sh

nombre_programa="$BASH_SOURCE"
#export LC_ALL=C	# Esto es necesario para que el sort funcione bien con los caracteres raros

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... SUFIJO_SALIDA ARCHIVO_ENTRADA..."
    echo "	-s [LINES], --splitlines[=LINES]
		Divide el corpus en LINES cantidad de lineas si no se da un valor,
		se usan 50,000. Esta opción está activada por defecto y ocasiona que
		el corpus procesado vaya a la carpeta ../corpus/split_out
		Las division sin procesar se guardan en ../corpus/split/ARCHIVO_ENTRADA_*
		Si se usa un corpus ya dividido en la entrada no se volvera a dividir"
	echo "	-j
		Desactiva la división de líneas. Esto ocasiona que el corpus limpio
		se escriba en ../corpus/SUFIJO_SALIDA_out"
	echo "	-e REMPLAZO, --etiqueta=REMPLAZO
		Recibe como parámetro la etiqueta con la que se van a reemplazar
		todos los números, por defecto esta opción está activada
		con la etiqueta DIGITO. Es útil para filtrarse y quitarse de la lista
		de palabras funcionales"
}

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
	"--splitlines") set -- "$@" "-s" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--etiqueta") set -- "$@" "-e" ;; #FIXME: esta opción recibe un parámetro, hay que convertirla para que acepte el símbolo =
	"--"*) echo "Opción desconocida: $arg" >&2 ; usage ; exit 1;; #TODO: Hay que ver si esto funciona, sobre todo al usar tan solo -- que es para terminar opciones
	*)        set -- "$@" "$arg"
  esac
done

# Default behavior
flag_split=true
split_LINES=50000
etiqueta_DIGITO="DIGITO"
out="../out" #TODO: dar opcion
corpus="../corpus" #TODO: dar opcion
split="split" #TODO: dar opcion
split_out="split_out" #TODO: dar opcion

# Parse short options
OPTIND=1
while getopts "s:je:" opt
do
  case "$opt" in
	"s") split_LINES="$OPTARG"; flag_split=true;;
	"j") flag_split=false;;
	"e") etiqueta_DIGITO="$OPTARG" ;;
	":") if [[ $OPTARG != "s" ]]; then echo "La opción -$OPTARG necesita un argumento"; else flag_split=true; fi;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

dir_salida=$(realpath "$1")
	dir_salida="${dir_salida%/*}"
salida="${1##*/}"
shift
dir_entrada=$(realpath "$1")
	dir_entrada="${dir_entrada%/*}"
entrada_name="${1##*/}"
entrada1="$dir_entrada/${1##*/}"
for arg in "$@"; do
	shift
	set -- "$@" "$dir_entrada/${arg##*/}"
done
entrada=$@
flag_cleaned=false

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit # AQUI COMIENZA EL PROGRAMA
ruta=$(realpath ..)

if [[ ! -d "$ruta/corpus" ]]; then mkdir "$ruta/corpus"; fi
if [[ ! -d "$ruta/out" ]]; then mkdir "$ruta/out"; fi

if [[ $flag_split == true ]]; then
	if [[ ! -d "$ruta/corpus/split_${salida}" ]]; then
		mkdir -p "$ruta/corpus/split_${salida}"
		if [ "$#" -gt 1 ]; then cp -t "$ruta/corpus/split_${salida}/" $entrada
		else split -l "$split_LINES" "$entrada1" "$ruta/corpus/split_${salida}/${salida}_"
		fi
	else
		echo "Se encontró un corpus ya dividido"
	fi
	entrada="$ruta/corpus/split_${salida}/*"
fi

if [[ $flag_split == true ]]; then
	if [[ ! -d "$ruta/corpus/split_${salida}_out" ]]; then mkdir -p "$ruta/corpus/split_${salida}_out"; else echo "Se encontró un corpus ya limpiado y dividido"; flag_cleaned=true ; fi
	if [[ $flag_cleaned == false ]]; then bash ../lib/limpia_corpus.sh -s "$split_LINES" -wo "$ruta/corpus/split_${salida}_out/$salida" $entrada; fi
	bash ../lib/vocabulario_freqs.sh -o "$ruta/out/${salida}" "$ruta/corpus/split_${salida}_out"/*
else
	
	if [[ ! -f "$ruta/corpus/${salida}_out" ]]; then bash ../lib/limpia_corpus.sh -wo "$ruta/corpus/${salida}_out" $entrada; else echo "Se encontró un corpus ya limpiado"; fi
	bash ../lib/vocabulario_freqs.sh -o "$ruta/out/${salida}" "$ruta/corpus/${salida}_out"
fi
