#!/bin/bash

##	ventanas_funcionales
#	Este programa tiene el propósito de obtener ventanas de contextos de
#	palabras funcionales con sus cuentas, el punto de esto es hacer gráficas
#	más adelante de manera que se pueda encontrar si hay algún patrón en las
#	distribuciones de lo que serian frases hechas y las que solo se usan
#	para conectar diferentes sintagmas
##	DEPENDENCIAS
#	- parallel

nombre_programa="$BASH_SOURCE"
export archivo_entrada="$1"
export archivo_palabras_funcionales="$2"
#~ palabra_funcional="$3"

export ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

if [[ ! -d "$ruta/out/ventanas_funcs" ]]; then mkdir "$ruta/out/ventanas_funcs"; fi

function main {
	palabra_funcional="$1"
	while read ventana; do
		python3 ventanas_funcionales.py "$ruta/$archivo_palabras_funcionales" "$ventana"
	done < <(perl -C -ne 'use utf8;/(\w+ '"$palabra_funcional"' \w+)/; print "$1\n"' "$ruta/$archivo_entrada" | sort | uniq -c | sort -rn) \
	> "$ruta/out/ventanas_funcs/$palabra_funcional"
}
export -f main

parallel main :::: "$ruta/$archivo_palabras_funcionales"
