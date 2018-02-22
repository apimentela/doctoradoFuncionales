#!/bin/bash

ruta="$1"
index="$2"
line="$3"
place=0
echo "$index/10345117"
for word in $line; do
    echo "$index $place" >> "${ruta}/vocabulario/_${word}_"
    let "place++"
done
