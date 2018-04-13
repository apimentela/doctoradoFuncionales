#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  limpi_ebooks.py
#	Este programa es el encargado de quitar los encabezados y
#	la información inicial que no es de interés para el análisis del texto
#	Recibe como parámetro el nombre del archivo y lo sobreescribe ya limpio
#	Para la obtención de los textos, se está usando el comando ebook-convert
#	con las opciones:
#	--no-chapters-in-toc
#	--enable-heuristics
#	--unsmarten-punctuation
#	--max-line-length=0
#	--txt-output-formatting=plain
#	--no-inline-fb2-toc (si es fb2)
#
#	ESTE PROGRAMA ESTA INCOMPLETO YA QUE AÚN HAY MUCHOS CASOS QUE NO SE TOMAN EN CUENTA
#	POR LO QUE NO FUNCIONA CORRECTAMENTE


import re

def main():
	with open(nombre_archivo,"r") as archivo:
		texto=archivo.read()
	lineas_gruesas=texto.split("\n\n\n\n\n\n")
	resumen=lineas_gruesas[0]
	lineas_gruesas=lineas_gruesas[1:]	# El primer texto que aparece antes de un gran espacio es el resúmen, no lo necestamos.
	indice_inicio=0
	indice_fin=len(lineas_gruesas)
	indice_extra=0	# para recorrer de atrás hacia adelante y encontrar lo último que no queresmos tampoco
	
	for index,linea_gruesa in enumerate(lineas_gruesas):
		if linea_gruesa.startswith("Título original:"): continue
		for linea in linea_gruesa.splitlines():
			if len(linea) > 100:
				indice_inicio=index
				break
		if indice_inicio : break
	
	expresion_notas=re.compile(r"^\[\d+\]")
	for extra in range(1,5):	# se recorrerán 4 parrafos de abajo hacia arriba para buscar no deseados
		lineas = lineas_gruesas[-extra].splitlines()
		if lineas and len(lineas[0]) >= 100 : indice_extra=extra
		for linea in lineas:
			if expresion_notas.match(linea):
				indice_extra=extra
				break
			
	linea_gruesa_anterior=lineas_gruesas[indice_inicio-1]	# muchas veces el texto comienza, pero en la sección anterior se tiene el nombre del capítulo o algo asi
	if len(linea_gruesa_anterior.splitlines()) == 1: indice_inicio-=1	# tiene la particularidad de estar aislado, así que se agrega simplemente retrocediendo un númer el índice si es que se encuentra
	
	if indice_fin-indice_extra > indice_inicio : indice_fin=indice_fin-indice_extra	# el indice final se ajusta, pero hay que asegurarse de que sea mayor al de inicio o se puede quedar vacío el archivo
	
	resultado="\n\n\n\n\n\n".join(lineas_gruesas[indice_inicio:indice_fin])
	with open(nombre_archivo,"w") as archivo:
		archivo.write(resultado)
	return 0

if __name__ == '__main__':
	import sys
	args=sys.argv
	nombre_archivo=args[1]
	sys.exit(main())
