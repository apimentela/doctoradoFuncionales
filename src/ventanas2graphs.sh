#!/bin/bash

##	ventanas_funcionales
#	Este programa tiene el propósito de obtener tablas de datos graficables
#	a partir de las cuentas de ventanas funcionales de ventanas_funcionales
#	con esto se puede pasar a gnuplot para que se hagan las gráficas directamente
##	DEPENDENCIAS
#	- parallel

nombre_programa="$BASH_SOURCE"

export prefijo="$1"
export ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

if [[ ! -d "$ruta/out/${prefijo}_ventanas_funcs_graphs" ]]; then mkdir "$ruta/out/${prefijo}_ventanas_funcs_graphs_data"; fi

function main {
	archivo_entrada="$1"
	palabra_funcional="${1##*/}"
	awk '{printf("%d %d\n",NR,$1)}' "$ruta/out/${prefijo}_ventanas_funcs/$palabra_funcional" > "$ruta/out/${prefijo}_ventanas_funcs_graphs_data/$palabra_funcional"
}
export -f main

parallel main ::: "$ruta/out/${prefijo}_ventanas_funcs/"*
