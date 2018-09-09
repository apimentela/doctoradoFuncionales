#!/bin/bash

##	ventanas_funcionales
#	Este programa tiene el propósito de obtener ventanas de contextos de
#	palabras funcionales con sus cuentas con la particularidad de que asegurarse
#	de que no estén rodeadas de más palabras funcionales, el punto de esto es hacer gráficas
#	más adelante de manera que se pueda encontrar si hay algún patrón en las
#	distribuciones de lo que serian frases hechas y las que solo se usan
#	para conectar diferentes sintagmas
##	DEPENDENCIAS
#	- triple_funcs.pl
#	- parallel

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
}
# Default behavior
flag_splitted=false

# Parse short options
OPTIND=1
while getopts "s" opt
do
  case "$opt" in
	"s") flag_splitted=true;;
	"?") echo "Opción desconocida: -$OPTARG" >&2 ; usage ; exit 1;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

export prefijo="$1"
archivo_palabras_funcionales="out/${prefijo}_multifuncs"

export ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

function contextos {
	ruta_funcs="$1"
	ruta_corpus="$2"
	perl -C triple_funcs.pl "$ruta_funcs" "$ruta_corpus"
}
export -f contextos

function instrucciones_mongo {
	read frecuencia palabra1 palabra2 rel1 rel2 rel3 <<< "$1"	# La entrada se lee y entra como una oración junta en un solo parámetro, aquí se separa
	relacion_funcional="$rel1 $rel2 $rel3"
	#~ mongo --eval 'db.relacionesFuncionales.update({palabra1:"'"$palabra1"'",palabra2:"'"$palabra2"'",relacion:"'"$relacion_funcional"'"},{$inc:{frecuencia:1}},{upsert:true})' "$prefijo"
	echo 'db.relacionesFuncionales.insert({palabra1:"'"$palabra1"'",palabra2:"'"$palabra2"'",r1:"'"$rel1"'",r2:"'"$rel2"'",r3:"'"$rel3"'",frecuencia:'"$frecuencia"'})'
}
export -f instrucciones_mongo

function agrupador {
	procesadores=$(nproc)
	export LC_ALL=C
	cat | sort -S1G --parallel="$procesadores" | uniq -c
}

if [[ $flag_splitted == true ]]; then parallel --linebuffer contextos ::: "$ruta/out/${prefijo}_multifuncs" ::: "$ruta/corpus/split_${prefijo}_out"/*
else contextos "$ruta/out/${prefijo}_multifuncs" "$ruta/corpus/${prefijo}_out"
fi \
| agrupador | parallel instrucciones_mongo :::: - > "$ruta/out/${prefijo}_mongo.js"	# Se usa - para leer del stdin
mongo "${prefijo}_sep" < "$ruta/out/${prefijo}_mongo.js"
