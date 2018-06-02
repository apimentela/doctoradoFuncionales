#!/bin/bash


if [[ ! -d "salidas" ]]; then mkdir "salidas"; fi


function por_palabra {
	palabra_funcional="$1"
	cat "/home/alejandro/doctoradoFuncionales/corpus/novelas_out" \
	| tr -d ",;" \
	| perl -C -ne '/(\S+ '"$palabra_funcional"' \S+)/; print("$1\n")' \
	| sort \
	| uniq -c \
	| sort -rn \
	> "salidas/${palabra_funcional}"
}
export -f por_palabra

parallel por_palabra :::: "/home/alejandro/doctoradoFuncionales/out/novelas_funcs"
