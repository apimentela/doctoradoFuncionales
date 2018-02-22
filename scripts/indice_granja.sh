#!/bin/bash
# sudo mount -t tmpfs -o size=512M tmpfs /tmp/ram/

archivo_contenido="$1"
ruta=$(dirname "$archivo_contenido")
#ruta="/home/gil/GRANJA/WIKIPEDIA"
archivo_numeracion="$2"

#mkdir "${ruta}/vocabulario"
#mkdir "${ruta}/vocabulario/_"

parallel --xapply ./indizador.sh ::: "$ruta" :::: "$archivo_numeracion" :::: "$archivo_contenido"

# find /tmp/vocabulario/ -mindepth 1 -maxdepth 1 -exec rm -r {} +;
#awk '{printf("%d \"%s\"\n",NR,$0)}' wiki_00
