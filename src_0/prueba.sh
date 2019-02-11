#!/bin/bash

entrada="$1"
while read linea; do
	echo "$linea"
done < <(cat "$entrada")
