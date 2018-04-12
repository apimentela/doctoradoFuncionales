#!/bin/bash

##	vectires
#	Este programa llama al programa de python que arma los vectores de
#	las palabras una vez que se ha llevado a cabo el preprocesamiento

nombre_programa="$BASH_SOURCE"

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit # AQUI COMIENZA EL PROGRAMA
ruta=$(realpath ..)

python3 vectores.py "$ruta/out/esWiki_vocab" "$ruta/out/esWiki_funcs" "$ruta/out/esWiki_pares1" "$ruta/out/esWiki_pares2" "$ruta/out/esWiki_vectores"
