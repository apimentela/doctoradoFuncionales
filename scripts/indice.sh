#!/bin/bash
# sudo mount -t tmpfs -o size=512M tmpfs /tmp/ram/

archivo_contenido="$1"
ruta=$(dirname "$archivo_contenido")
archivo_numeracion="$2"

#mkdir "${ruta}/vocabulario"
#mkdir "${ruta}/vocabulario/_"

function indizador {
	ruta="$1"
	index="$2"
	place=0
    for word in $line; do
		echo "$index $place" #>> "${ruta}/vocabulario/_${word}_"
		let "place++"
    done
}
export -f indizador

#parallel -j0 --link indizador ::: "$ruta" :::: "$archivo_numeracion" :::: "$archivo_contenido"

# find /tmp/vocabulario/ -mindepth 1 -maxdepth 1 -exec rm -r {} +;
#awk '{printf("%d \"%s\"\n",NR,$0)}' wiki_00
