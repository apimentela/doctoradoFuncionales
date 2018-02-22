#!/bin/bash

cuenta=1

while read input; do
	echo "$input"
	if [ "$input" == "1" ]; then
		let "cuenta++"
		echo -e "${palabra}\t${cuenta}"
	else
		echo -e "${palabra}\t${cuenta}" >> "vocabulario.txt"
		rm "/tmp/vocabulario/$palabra"
		exit
	fi
done < <(nc -lUk "/tmp/algo")
