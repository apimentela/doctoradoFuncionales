#!/bin/bash

archivo="$1"

cp "$archivo" "${archivo}_temp"

archivo="${archivo}_temp"

linea=$(tail -n 1 "$archivo")	# Se procesará el archivo de atrás para adelante
linea=$(echo "$linea" | xargs) # strip

palabra=$(echo "${linea%% *}" | xargs)	# se lee la primer palabra de la linea
resto=$(echo "${linea#* }" | xargs)	# y el resto para ser regresado al archivo

dd if=/dev/null of="$archivo" bs=1 seek=$(echo $(stat --format=%s "$archivo" ) - $( tail -n1 "$archivo" | wc -c) | bc )

if [ -n "$resto" ] ; then
echo "$resto" >> "$archivo"
fi

gawk -i inplace -v s="$palabra" -v c="" '{count+=gsub(s,c)}1
END{print s "\t" count}' "$archivo" >> vocabulario.txt

while [ -s "$archivo" ]; do

linea=$(tail -n 1 "$archivo")	# Se procesará el archivo de atrás para adelante
linea=$(echo "$linea" | xargs) # strip

if [ -n "$linea" ] ; then
	palabra=$(echo "${linea%% *}" | xargs)	# se lee la primer palabra de la linea
	resto=$(echo "${linea#* }" | xargs)	# y el resto para ser regresado al archivo

	dd if=/dev/null of="$archivo" bs=1 seek=$(echo $(stat --format=%s "$archivo" ) - $( tail -n1 "$archivo" | wc -c) | bc )

	if [ -n "$resto" ] ; then
		echo "$resto" >> "$archivo"
	fi

	gawk -i inplace -v s="$palabra" -v c="" '{count+=gsub(s,c)}1
	END{print s "\t" count}' "$archivo" >> vocabulario.txt
fi

linea=$(tail -n 1 "$archivo")	# Se procesará el archivo de atrás para adelante
linea=$(echo "$linea" | xargs) # strip

done
