#!/bin/bash

##	freeling_client
# Programa fijo

cd ..

function llama_freeling {
	archivo_entrada="$1"
	sed 's/<[^>]*>//g' "$archivo_entrada"  | analyzer_client 8080 > "out/split_esWiki_tagged/${archivo_entrada##*/}"
}
export -f llama_freeling

parallel llama_freeling ::: corpus/split_esWiki/*
