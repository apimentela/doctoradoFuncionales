#!/bin/bash

##	vectires
#	Este programa llama al programa de python que arma los vectores de
#	las palabras una vez que se ha llevado a cabo el preprocesamiento
#	se recibe como entrada el prefijo del archivo a procesar

nombre_programa="$BASH_SOURCE"
prefijo_archivo="$1"

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit # AQUI COMIENZA EL PROGRAMA
ruta=$(realpath ..)

python3 vectores.py "$ruta/out/${prefijo_archivo}_vocab" "$ruta/out/${prefijo_archivo}_funcs" "$ruta/out/${prefijo_archivo}_pares1" "$ruta/out/${prefijo_archivo}_pares2" "$ruta/out/${prefijo_archivo}_vectores_temp"
sort -nr -k 102 "$ruta/out/${prefijo_archivo}_vectores_temp" | awk '{$NF--; print}' > "$ruta/out/${prefijo_archivo}_vectores"	#FIXME: es mejor que el número entre como parámetro para el k del sort
rm "$ruta/out/${prefijo_archivo}_vectores_temp"
