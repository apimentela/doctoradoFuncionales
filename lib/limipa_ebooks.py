#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  limpi_ebooks.py
#	Este programa es el encargado de quitar los encabezados y
#	la información inicial que no es de interés para el análisis del texto
#	Recibe como parámetro el nombre del archivo y lo sobreescribe ya limpio

def main():
	with open(nombre_archivo,"r") as archivo:
		texto=archivo.read()
	lineas_gruesas=texto.split("\n\n\n\n\n\n")
	resumen=lineas_gruesas[0]
	lineas_gruesas=lineas_gruesas[1:]	# El primer texto que aparece antes de un gran espacio es el resúmen, no lo necestamos.
	index_inicio=0
	for index,linea_gruesa in enumerate(lineas_gruesas):
		if linea_gruesa.startswith("Título original:"): continue
		for linea in linea_gruesa.splitlines():
			if len(linea) > 100:
				index_inicio=index
				break
		if index_inicio : break
	linea_gruesa_anterior=lineas_gruesas[index_inicio-1]	# muchas veces el texto comienza, pero en la sección anterior se tiene el nombre del capítulo o algo asi
	if len(linea_gruesa_anterior.splitlines()) == 1: index_inicio-=1	# tiene la particularidad de estar aislado, así que se agrega simplemente retrocediendo un númer el índice si es que se encuentra
	resultado="\n\n\n\n\n\n".join(lineas_gruesas[index_inicio:])
	print(resultado)
	return 0

if __name__ == '__main__':
	import sys
	args=sys.argv
	nombre_archivo=args[1]
	sys.exit(main())
