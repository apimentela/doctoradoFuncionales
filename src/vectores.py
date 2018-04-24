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
#	recibe un último parámetro opcional para determinar el número de
#	dimensiones del vector, este número no puede ser mayor que las palbras
#	en el archivo de palabras funcionales. El vector resultante será del doble.

import numpy as np
import csv

def lector_par(archivo_pares):
	indice_freq=0
	indice_funcional=1
	indice_palabra=2
	while True:	# lo que se busca es que la lectura tenga sentido
		lista_valores=archivo_pares.readline().strip().split()
		if not lista_valores: return False, False, False	# Si ya se acabó el archivo, regresa puro falso para terminar el loop
		if len(lista_valores) != 3: continue	# hay entradas erroneas, esto es necesario
		if lista_valores[indice_palabra].strip() in lista_funcionales: continue	# NO SE DEBEN COMPARAR FUNCIONALES PORQUE LAS DEL VOCABULARIO TAMPOCO SERAN TOMADAS EN CUENTA
		break
	freq=int(lista_valores[indice_freq])
	palabra=lista_valores[indice_palabra].strip()
	funcional=lista_valores[indice_funcional].strip()
	return freq,palabra,funcional

def main():
	
	palabra_anterior=""
	
	freq1,palabra1,funcional1=lector_par(archivo_pares1)	# Primera lectura
	freq2,palabra2,funcional2=lector_par(archivo_pares2)
	
	for palabra_vocabulario in archivo_vocabulario:	# Recorrido para armar el vector de cada una de las palabras del vocabulario
		
		palabra_vocabulario=palabra_vocabulario.strip().split() # Esta parte es para limpiar cualquier palabra que venga con ruido
		if not palabra_vocabulario or len(palabra_vocabulario) != 1 or palabra_vocabulario == palabra_anterior: continue
		palabra_vocabulario=palabra_vocabulario[0]
		palabra_anterior=palabra_vocabulario
		
		if palabra_vocabulario in lista_funcionales: continue
		
		vector=np.zeros(dimension_funcionales*2)
		
		while freq1 or palabra1 or funcional1:	# Recorrido para el primer archivo
			#~ print(palabra_vocabulario,palabra1)	# DEBUG
			if palabra1 != palabra_vocabulario:
				break
			if freq1 <= min_apariciones:	# si la frecuencia es menor al mínimo, pasa a la siguiente palabra
				freq1,palabra1,funcional1=lector_par(archivo_pares1)
				continue
			vector[lista_funcionales.index(funcional1)]=freq1
			freq1,palabra1,funcional1=lector_par(archivo_pares1)
		while freq2 or palabra2 or funcional2:	# Recorrido para el segundo archivo
			if palabra2 != palabra_vocabulario:
				break
			if freq2 <= min_apariciones:
				freq2,palabra2,funcional2=lector_par(archivo_pares2)
				continue
			vector[dimension_funcionales+lista_funcionales.index(funcional2)]=freq2	# La diferencia de ambos archivos esta aqui, ya que forma la segunda parte del vector
			freq2,palabra2,funcional2=lector_par(archivo_pares2)
	
		if np.sum(vector) > min_suma :
			vector_normalizado=vector/np.sum(vector)
			#~ escritor_archivo_salida.writerow([palabra_vocabulario]+vector_normalizado.tolist())
			vector_completo=np.append(vector_normalizado,[np.sum(vector)])
			escritor_archivo_salida.writerow([palabra_vocabulario]+vector_completo.tolist())
	
	return 0

if __name__ == '__main__':
	import sys
	if len(sys.argv) != 6 and len(sys.argv) != 7:
		print ("ERROR: en el numero de archivos de entrada, deben ser 5 o 6")
		sys.exit(1)
	
	# DEFINICIÓN DE VARIABLES GENERALES
	args=sys.argv
	
	min_apariciones=1	# Parametros para ignorar pares con pocas apariciones	#TODO: dar opción de entrada
	min_suma=1			# Parámetro para ignorar palabras con pocas apariciones totales	#TODO: dar opción de entrada
	
	nombre_archivo_vocabulario=args[1]
	nombre_archivo_funcionales=args[2]
	nombre_archivo_pares1=args[3]
	nombre_archivo_pares2=args[4]
	nombre_archivo_salida=args[5]
	
	if len(args) > 6 : num_dimensiones=int(args[6])	#TODO: dar opción de entrada
	else: num_dimensiones=0
		
	archivo_vocabulario=open(nombre_archivo_vocabulario,"r")
	archivo_funcionales=open(nombre_archivo_funcionales,"r")
	archivo_pares1=open(nombre_archivo_pares1,"r")
	archivo_pares2=open(nombre_archivo_pares2,"r")
	archivo_salida=open(nombre_archivo_salida,"w")
	
	escritor_archivo_salida=csv.writer(archivo_salida,delimiter=" ")
	
	lista_funcionales=archivo_funcionales.read().splitlines()	# La lista de palabras funcionales no es tan larga y si conviene tenerla en memoria
	archivo_funcionales.close()
	if not num_dimensiones: num_dimensiones=len(lista_funcionales)
	lista_funcionales=lista_funcionales[:num_dimensiones]
	
	dimension_funcionales=len(lista_funcionales)
	
	# LLAMADA A MAIN
	
	sys.exit(main())
