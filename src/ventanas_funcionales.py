#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# DEPRECATED
#
# ventanas_funcionales.py
#	Este programa se encarga de recibir una coincidencia de la ventana
#	funcional de programa de terminal. Además, recibe el archivo que tiene la lista de palabras
#	funcionales y se asegura de que la coincidencia no comienza ni termine con 
#	una palabra de esa lista

def main():
	
	ventana_dividida=ventana_funcional.strip().split("\t")
	ventana_unida=" ".join(ventana_dividida[1:])
	for funcional in lista_funcionales:
		if ventana_unida.startswith(funcional) or ventana_unida.endswith(funcional):
			return 0
	print(ventana_funcional)

	return 0

if __name__ == '__main__':
	import sys
	if len(sys.argv) != 3:
		print ("ERROR: en el numero de archivos de entrada, deben ser 2")
		sys.exit(1)
	
	# DEFINICIÓN DE VARIABLES GENERALES
	args=sys.argv

	nombre_archivo_funcionales = args[1]
	ventana_funcional = args[2]
	
	archivo_funcionales=open(nombre_archivo_funcionales,"r")
	
	lista_funcionales=archivo_funcionales.read().splitlines()	# La lista de palabras funcionales no es tan larga y si conviene tenerla en memoria
	archivo_funcionales.close()
	
	# LLAMADA A MAIN
	
	sys.exit(main())
