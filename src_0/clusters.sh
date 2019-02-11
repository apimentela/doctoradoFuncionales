#!/bin/bash

##	clusters
#	Este programa llama al programa de python que junta las palabras en clusters,
#	para tener muchos grupos tal vez lo mejor sea mandar a hacer muchos clusters
#	para ver cual funciona mejor
# DEPENDENCIAS:
#	parallel

nombre_programa="$BASH_SOURCE"
prefijo_archivo="$1"

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit # AQUI COMIENZA EL PROGRAMA
ruta=$(realpath ..)

entradas="2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100 200 300 400 500 600 700 800 900 1000"

parallel "python2 cluster.py $ruta/out/${prefijo_archivo}_vectores 0" ::: $entradas
