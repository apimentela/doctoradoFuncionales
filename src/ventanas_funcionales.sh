#!/bin/bash

##	ventanas_funcionales
#	Este programa tiene el propósito de obtener ventanas de contextos de
#	palabras funcionales con sus cuentas con la particularidad de que asegurarse
#	de que no estén rodeadas de más palabras funcionales, el punto de esto es hacer gráficas
#	más adelante de manera que se pueda encontrar si hay algún patrón en las
#	distribuciones de lo que serian frases hechas y las que solo se usan
#	para conectar diferentes sintagmas
##	DEPENDENCIAS
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
export flag_splitted=false

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
export archivo_palabras_funcionales="out/${prefijo}_funcs"

export ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

if [[ ! -d "$ruta/out/${prefijo}_ventanas_funcs" ]]; then mkdir "$ruta/out/${prefijo}_ventanas_funcs"; fi
if [[ -f "$ruta/out/${prefijo}_multifuncs_freqs_temp" ]]; then rm "$ruta/out/${prefijo}_multifuncs_freqs_temp"; fi

export expresion="("$(cat "$ruta/$archivo_palabras_funcionales" | tr -s "\n" | perl -pe 'chomp if eof'| tr '\n' '|')")"	#TODO: Aquí se pone un seguro (tr -s "\n") para no tomar en cuenta líneas vacías, esto no debería ser necesario si la creación lista de palabras funcionales tiene lo mismo, hay que checar eso

function por_palabra {
	procesadores=$(nproc)
	palabra_funcional="$1"
	grep -P "\t${palabra_funcional}\t" "$ruta/out/${prefijo}_contextos" \
	| sort -S1G --parallel="$procesadores" | uniq -c | sort -S1G --parallel="$procesadores" -rn \
	> "$ruta/out/${prefijo}_ventanas_funcs/$palabra_funcional"
	frecuencia=$(cat "$ruta/out/${prefijo}_ventanas_funcs/$palabra_funcional" | wc -l)
	if [[ "$frecuencia" == "0" ]]; then rm "$ruta/out/${prefijo}_ventanas_funcs/$palabra_funcional"
	else echo -e "${frecuencia}\t${palabra_funcional}"	>> "$ruta/out/${prefijo}_multifuncs_freqs_temp"
	fi
}
export -f por_palabra

function contextos {
	ruta_funcs="$1"
	ruta_corpus="$2"
	perl -C contextos_funcs.pl "$ruta_funcs" "$ruta_corpus" \
	| grep -Pv "^${expresion}\t" \
	| grep -Pv "\t${expresion}$"
}
export -f contextos

if [[ $flag_splitted == true ]]; then parallel --linebuffer contextos ::: "$ruta/out/${prefijo}_funcs" ::: "$ruta/corpus/split_${prefijo}_out"/*
else contextos "$ruta/out/${prefijo}_funcs" "$ruta/corpus/${prefijo}_out"
fi \
> "$ruta/out/${prefijo}_contextos"

parallel por_palabra :::: "$ruta/$archivo_palabras_funcionales"
sort -rn "$ruta/out/${prefijo}_multifuncs_freqs_temp" > "$ruta/out/${prefijo}_multifuncs_freqs"
rm "$ruta/out/${prefijo}_multifuncs_freqs_temp"
