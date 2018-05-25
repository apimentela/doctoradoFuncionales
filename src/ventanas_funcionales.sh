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

export prefijo="$1"

export archivo_palabras_funcionales="out/${prefijo}_funcs"

export ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

if [[ ! -d "$ruta/out/ventanas_funcs" ]]; then mkdir "$ruta/out/ventanas_funcs"; fi
if [[ -f "$ruta/out/${prefijo}_multifuncs_freqs" ]]; then rm "$ruta/out/${prefijo}_multifuncs_freqs"; fi

function main {
	palabra_funcional="$1"
	while read ventana; do
		python3 ventanas_funcionales.py "$ruta/$archivo_palabras_funcionales" "$ventana"
	done < <(perl -C -ne 'use utf8;/(\w+ '"$palabra_funcional"' \w+)/; print "$1\n"' "$ruta/$archivo_entrada" | sort -S1G --parallel="$procesadores" | uniq -c | sort -S1G --parallel="$procesadores" -rn) \
	> "$ruta/out/ventanas_funcs/$palabra_funcional"
	wc -l "$ruta/out/ventanas_funcs/$palabra_funcional" >> "$ruta/out/${prefijo}_multifuncs_freqs"
}
export -f main

export procesadores=$(nproc)

parallel main :::: "$ruta/$archivo_palabras_funcionales"
