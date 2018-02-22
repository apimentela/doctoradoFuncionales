#!/bin/bash

salida_en_lineas () {
	entrada="$1"
	salida="$2"
	while read -ra linea; do	# la bandera -r es para que la diagonal invertida no sea caracter especial, la bandera -a es para que las palabras que se leen seinserten en un arrglo dentro de la varialbe
		for palabra in "${linea[@]}"; do
			echo "$palabra" >> "$salida"
		done
	done < "$entrada"
}
export -f salida_en_lineas

entrada="$1"
salida="$2"
#salida="$entrada"

if [ -d "$entrada" ]; then
	#~ for arhivo in "$entrada", do
		#~ salida_en_lineas "$archivo" "$salida"
	#~ done
	find "$entrada" -type f -exec cat {} >> "$entrada" \;
fi

#sed -e 's|^</*doc.*$||g' -e 's|([^)]*)||g' -e 's|[[:punct:]]| & |g' -e '/^$/d' "$entrada" | tr -s [:space:] > "$salida"
sed -e 's|^</*doc.*$||g' -e 's|([^)]*)||g' -e 's|[[:punct:]]||g' "$entrada" | tr -s [:space:] > "$salida"
#perl -C -ne 'print lc' "$salida" | perl -C -pe 's/\d+([^ ]\d+)*/DIGITO/g' > "${salida}_minusculas"
perl -C -ne 'print lc' "$salida" | perl -C -pe 's/[^ ]*\d[^ ]*/DIGITO/g' > "${salida}_minusculas"
cat "${salida}_minusculas" | tr [:space:] "\n" | tr -s [:space:] > "${salida}_oneperline"
sort "${salida}_oneperline" | uniq -c | sort -rn > "${salida}_freqs"
awk '{printf "%f %s\n", $1/length($2),$2}' "${salida}_freqs" | sort -rn > "${salida}_functionScores"
