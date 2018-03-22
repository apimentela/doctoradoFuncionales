#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# vectores.py
#	Este programa es el encargado de armar los vectores según las palabras
#	funcionales que rodean a cada una de las palabras del vocabulario
#	(que no sean funcionales). Como parámetros de entrada, necesita el
#	archivo de vocabulario, en segundo lugar necesita la lista de palabras
#	funcionales, como tercer parámetro necesita la lista de pares PRE y por
#	último, la lista de pares POST


def main(args):
	nombre_archivo_vocabulario=args[1]
	archivo_vocabulario=open(nombre_archivo_vocabulario,"r")
	contador=0
	
	for palabra_vocabulario in archivo_vocabulario:
		print(palabra_vocabulario)
		contador+=1
		if contador>2 : break
	
	print()
	
	contador=0
	for palabra_vocabulario in archivo_vocabulario:
		print(palabra_vocabulario)
		contador+=1
		if contador>2 : break
	
	return 0

if __name__ == '__main__':
	import sys
	sys.exit(main(sys.argv))
