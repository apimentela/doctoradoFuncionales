#!/bin/bash
# sudo mount -t tmpfs -o size=512M tmpfs /tmp/ram/

linea="$1"

function creador {
	line="$1"
	place=0
    for word in $line; do
		echo "$word $place" >> vocabulario/_${word}_
		let "place++"
    done
}
export -f creador

parallel -j0 creador :::: "$archivo"

# find /tmp/vocabulario/ -mindepth 1 -maxdepth 1 -exec rm -r {} +;
#awk '{printf("%d \"%s\"\n",NR,$0)}' wiki_00
