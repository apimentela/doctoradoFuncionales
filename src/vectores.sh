#!/bin/bash

##	vectores
#	Este programa viene después del preprocesamiento, tiene como objetvo obtener
#	los vectores de las palabras, por lo que primero obtiene los contextos con
#	ayuda del programa de perl
#	Este programa también llama al programa de python que arma los vectores de
#	las palabras una vez que se ha llevado a cabo el preprocesamiento
#	se recibe como entrada el prefijo del archivo a procesar
##	DEPENDENCIAS
#	- parallel

nombre_programa="$BASH_SOURCE"

function usage {
##	Uso
#	Esta función muestra en pantalla el modo de empleo de este programa

    echo "Uso: $nombre_programa [OPCIÓN]... SUFIJO_IO"
    echo "	-s
		Establece si se trata de un archivo dividido o no, por defecto
		esta opción está desactivada"
	echo "	-k
		Establece el número de dimensiones que se espera obtener del vector
		OJO: este número debe ser igual o menor al que se tenga de palabras
		funcionales"
	echo "	-e REMPLAZO, --etiqueta=REMPLAZO
		Recibe como parámetro la etiqueta con la que se van a reemplazar
		todos los números, por defecto esta opción está activada
		con la etiqueta DIGITO. Es útil para filtrarse y quitarse de la lista
		de palabras funcionales"
}

dir_io=$(realpath "$1")
dir_io="${dir_salida%/*}"
prefijo_archivo="${1##*/}"

ruta=$(realpath "$BASH_SOURCE")
cd "${ruta%/*}" || exit # AQUI COMIENZA EL PROGRAMA
ruta=$(realpath ..)

python3 vectores.py "$ruta/out/${prefijo_archivo}_vocab" "$ruta/out/${prefijo_archivo}_funcs" "$ruta/out/${prefijo_archivo}_pares1" "$ruta/out/${prefijo_archivo}_pares2" "$ruta/out/${prefijo_archivo}_vectores_temp"
sort -nr -k 102 "$ruta/out/${prefijo_archivo}_vectores_temp" | awk '{$NF--; print}' > "$ruta/out/${prefijo_archivo}_vectores"	#FIXME: es mejor que el número entre como parámetro para el k del sort
rm "$ruta/out/${prefijo_archivo}_vectores_temp"
