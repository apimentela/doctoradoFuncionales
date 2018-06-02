#!/bin/bash

##	test_gp.sh
#	Este es un programa de prueba para escribir un script de gnuplot
#	para automatizar gráficas
##	DEPENDENCIAS
#	- gnuplot

nombre_programa="$BASH_SOURCE"

export prefijo="$1"
export ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit
ruta=$(realpath ..)

cat << EOF > test.gp
set term svg enhanced mouse size 600,400
set encoding utf8
plot \\
EOF

for i in "out/${prefijo}_ventanas_funcs_graphs_data/"*; do echo "'$i' w l, \\" >> test.gp ; done
