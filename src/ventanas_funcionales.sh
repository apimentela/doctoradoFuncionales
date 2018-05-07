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
archivo_entrada="$1"
export palabra_funcional="$2"	# Es necesario exportarla para usarla en perl

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

if [[ ! -d "$ruta/out/ventanas_funcs" ]]; then mkdir "$ruta/out/ventanas_funcs"; fi

perl -C -ne 'use utf8;/(\w+ '"$palabra_funcional"' \w+)/; print "$1\n"' "$ruta/$archivo_entrada" | sort | uniq -c | sort -rn > "$ruta/out/ventanas_funcs/$palabra_funcional"
