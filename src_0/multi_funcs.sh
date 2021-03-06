#!/bin/bash

##	multi_funcs
#	Este programa trabaja en conjunto con su versión de perl para
#	obtener todos los conjuntos de palabras funcionales contiguos
#	lo que antexa este programa son funciones para contar palabras
## DEPENDENCIAS
#	parallel
#	multi_funcs.pl
#FIXME:	OJO, POR AHORA SE USA EL ARCHIVO DE TERMINACION funcs1, ESE LO HAGO A MANO, HAY QUE AUTOMATIZAR ESO

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
	echo "	-m NUM
		Establece el número mínimo de apariciones que tiene que tener un
		conjunto de palabras funcionales para entrar en la lista, por defecto
		está ilimitado"
}
# Default behavior
flag_splitted=false
flag_min_apariciones=false

# Parse short options
OPTIND=1
while getopts "sm:" opt
do
  case "$opt" in
	"s") flag_splitted=true;;
	"m") flag_min_apariciones=true; min_apariciones="$OPTARG";;
	":") echo "La opción -$OPTARG necesita un argumento";;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

prefijo_archivo="$1"

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

procesadores=$(nproc)

if [[ $flag_splitted == true ]]; then parallel perl -C multi_funcs.pl ::: "$ruta/out/${prefijo_archivo}_funcs1" ::: "$ruta/corpus/split_${prefijo_archivo}_out"/* 
else perl -C multi_funcs.pl "$ruta/out/${prefijo_archivo}_funcs1" "$ruta/corpus/${prefijo_archivo}_out" 
fi | sort -r | uniq > "$ruta/out/${prefijo_archivo}_multifuncs"
#uniq > "$ruta/out/${prefijo_archivo}_multifuncs"
#OJO: esto último es un cambio para que no importe la frecuencia en la que aparecen las combinaciones, puede ser solo algo temporal
