#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# vectores.py
#	Este programa es el encargado de armar los vectores según las palabras
#	funcionales que rodean a cada una de las palabras del vocabulario
#	(que no sean funcionales). Como parámetros de entrada, necesita el
#	archivo de vocabulario, en segundo lugar necesita la lista de palabras
#	funcionales, como tercer parámetro necesita la lista de pares PRE,
#	como cuarto parámetro recibe la lista de pares POST y por último
#	recibe el archivo de salida en el que se van a guardar los vectores en texto

import numpy as np
import csv

def main(args):
	min_apariciones=1	# Parametros para ignorar pares con pocas apariciones
	min_suma=1			# Parámetro para ignorar palabras con pocas apariciones totales
	
	nombre_archivo_vocabulario=args[1]
	nombre_archivo_funcionales=args[2]
	nombre_archivo_pares1=args[3]
	nombre_archivo_pares2=args[4]
	nombre_archivo_salida=args[5]
	
	archivo_vocabulario=open(nombre_archivo_vocabulario,"r")
	archivo_funcionales=open(nombre_archivo_funcionales,"r")
	archivo_pares1=open(nombre_archivo_pares1,"r")
	archivo_pares2=open(nombre_archivo_pares2,"r")
	archivo_salida=open(nombre_archivo_salida,"w")
	
	escritor_archivo_salida=csv.writer(archivo_salida,delimiter=" ")
	
	lista_funcionales=archivo_funcionales.readlines()	# La lista de palabras funcionales no es tan larga y si conviene tenerla en memoria
	archivo_funcionales.close()
	
	dimension_funcionales=len(lista_funcionales)
	
	freq1,palabra1,funcional1=archivo_pares1.readline().split()	# Lectura inicial
	freq2,palabra2,funcional2=archivo_pares2.readline().split()
	
	for palabra_vocabulario in archivo_vocabulario:	# Recorrido para armar el vector de cada una de las palabras del vocabulario
		if palabra_vocabulario in lista_funcionales: continue
		vector=np.zeros(dimension_funcionales)
		
		while True:	# Recorrido para el primer archivo
			if freq1 <= min_apariciones :
				freq1,palabra1,funcional1=archivo_pares1.readline().split()
				continue
			if palabra1 != palabra_vocabulario:
				break
			vector[lista_funcionales.index(funcional1)]=freq1
			freq1,palabra1,funcional1=archivo_pares1.readline().split()
		while True:	# Recorrido para el segundo archivo
			if freq2 <= min_apariciones :
				freq2,palabra2,funcional2=archivo_pares2.readline().split()
				continue
			if palabra2 != palabra_vocabulario:
				break
			vector[dimension_funcionales+lista_funcionales.index(funcional1)]=freq1	# La diferencia de ambos archivos esta aqui, ya que forma la segunda parte del vector
			freq2,palabra2,funcional2=archivo_pares2.readline().split()
	
		if np.sum(vector) > min_suma :
			vector_normalizado=vector/np.sum(vector)
			escritor_archivo_salida.writerow([palabra_vocabulario]+[vector_normalizado])
	
	return 0

if __name__ == '__main__':
	import sys
	if len(sys.argv) != 6:
		print ("ERROR: en el numero de archivos de entrada, deben ser 5")
		sys.exit(1)
	sys.exit(main(sys.argv))
