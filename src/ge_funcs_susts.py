#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# ge_funcs_susts.py
#
# Este programa es el encargado de clasificar las palabras que se 
#	obtienen de el primer patron en sus respectivos lugares de las
#	funcionales compuestas, se obtienen dos grupos y una tabla
#	de sus relaciones.

import json

def main(args):
	lis_palabras_izq=[]
	lis_palabras_der=[]
	dic_relaciones_izqAder={}
	dic_relaciones_derAizq={}
	s_derecha_confiable=""

	for linea in sys.stdin:
		l_linea=linea.strip().split()
		if len(l_linea) != 3: continue	# Si no hay dos palabras se ignora la linea
		s_palabra_izq=l_linea[1]
		s_palabra_der=l_linea[2]
		
		if not s_derecha_confiable : s_derecha_confiable=s_palabra_der	# Se guarda la primer palabra que ocurre a la derecha para usarla como purnto de corte cuando se encuentre en otra posición.
		elif s_derecha_confiable==s_palabra_izq:break	# Aquí se checa la condición de paro
		
		if s_palabra_der in lis_palabras_izq : continue # Si en la segunda columna hay una palabra que ha aparecido como la primera, entonces la que aparece como la primera no se toma en cuenta asi que se continua sin cambiar nada
		else: 
			if not s_palabra_der in lis_palabras_der:
				lis_palabras_der.append(s_palabra_der)
			try:
				if not s_palabra_der in dic_relaciones_izqAder[s_palabra_izq]:
					dic_relaciones_izqAder[s_palabra_izq].append(s_palabra_der)	# Se guarda la relación en los diccionarios (en ambas direcciones)
			except:
				dic_relaciones_izqAder[s_palabra_izq]=[s_palabra_der]
			try:
				if not s_palabra_izq in dic_relaciones_derAizq[s_palabra_der]:
					dic_relaciones_derAizq[s_palabra_der].append(s_palabra_izq)
			except:
				dic_relaciones_derAizq[s_palabra_der]=[s_palabra_izq]
		if not s_palabra_izq in lis_palabras_der: 	# Si no esta la palabra de la izquierda en la lista de la derecha, se agrega a su lista y punto
			if not s_palabra_izq in lis_palabras_izq:
				lis_palabras_izq.append(s_palabra_izq)
		else:	# Si se encuentra una palabra en la primera columna que haya aparecido en la segunda antes, entonces se saca de la segunda lista para que solo esté en la primera
			if not s_palabra_izq in lis_palabras_izq:
				lis_palabras_izq.append(s_palabra_izq)
			lis_palabras_der.remove(s_palabra_izq)
			
			for palabra_izq in dic_relaciones_derAizq[s_palabra_izq]:	# Para cada palabra que apunta a esta EX-palabra derecha 
				if len(dic_relaciones_izqAder[palabra_izq])==1:	# Si dicha palabra no apunta a ninguna otra, se quita de las relaciones
					dic_relaciones_izqAder.pop(palabra_izq)
					lis_palabras_izq.remove(palabra_izq)
				else: dic_relaciones_izqAder[palabra_izq].remove(s_palabra_izq)	# Su apunta a otras también, entonces solo quita de las relaciones a la EX-palabra derecha
			dic_relaciones_derAizq.pop(s_palabra_izq)	# Por último, también se quitan las relaciones que de la derecha apuntaban a las palabras inzquierdas

	for derecha in lis_palabras_der:
		print(derecha,dic_relaciones_derAizq[derecha])
	print("\n")
	for izquierda in lis_palabras_izq:
		print(izquierda,dic_relaciones_izqAder[izquierda])
				
	return 0

if __name__ == '__main__':
	import sys
	sys.exit(main(sys.argv))
