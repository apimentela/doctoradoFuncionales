#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# ge_funcs_susts.py
#
# Este programa es el encargado de clasificar las palabras que se 
#	obtienen de el primer patron en sus respectivos lugares de las
#	funcionales compuestas, se obtienen dos grupos y una tabla
#	de sus relaciones.

def main(args):
	s_prefijo_archivo=args[1]
	
	lis_palabras_extra=[]
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
		
		if s_palabra_der in lis_palabras_izq :	# Si en la segunda columna hay una palabra que ha aparecido como la primera, entonces la que aparece como la primera no se toma en cuenta asi que se continua sin cambiar nada
			if not s_palabra_der in lis_palabras_extra:	# O mejor se guardan en una tercera lista por si acaso
				lis_palabras_extra.append(s_palabra_der)
			continue 
		
		if s_palabra_izq in lis_palabras_der: 	# Si en la primera columna aparece una palabra que ha aparecido como la segunda, entonces se tienen que revisar algunas cosas
			if len(dic_relaciones_derAizq[s_palabra_izq])>1:	# Si la palabra que se encontró en la izquierda es una palabra de la derecha que está relacionada a varias de la izquierda, quiere decir que se encontró una palabra confiable, se debe saltar o terminar el programa
				continue
				
			lis_palabras_der.remove(s_palabra_izq)	# De lo contrario, se saca de la lista de palabras de la derecha y se agrega a las de la izquierda
			for palabra_izq in dic_relaciones_derAizq[s_palabra_izq]:	# Además. para cada palabra que apunta a esta EX-palabra derecha 
				if len(dic_relaciones_izqAder[palabra_izq])==1:	# Si dicha palabra no apunta a ninguna otra, se quita de las relaciones
					dic_relaciones_izqAder.pop(palabra_izq)
					lis_palabras_izq.remove(palabra_izq)
				else: dic_relaciones_izqAder[palabra_izq].remove(s_palabra_izq)	# Su apunta a otras también, entonces solo quita de las relaciones a la EX-palabra derecha
			dic_relaciones_derAizq.pop(s_palabra_izq)	# Por último, también se quitan las relaciones que de la derecha apuntaban a las palabras inzquierdas
		
		# Si se llega a este punto, es que se van a agregar las palabras
		#	a sus respectivas listas y se van a actualizar sus relaciones
		
		if not s_palabra_der in lis_palabras_der:
				lis_palabras_der.append(s_palabra_der)
		if not s_palabra_izq in lis_palabras_izq:	
				lis_palabras_izq.append(s_palabra_izq)
				
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
	
	print("|".join(lis_palabras_izq))
	print("|".join(lis_palabras_der))
	
	print()
	print("|".join(lis_palabras_extra))
	#~ max_key=max(dic_relaciones_izqAder,key=lambda x:len(dic_relaciones_izqAder[x]))
	#~ print(max_key)
	
	print()
	for key in dic_relaciones_izqAder:
		campos="|".join(dic_relaciones_izqAder[key])
		salida=key+":"+campos
		print(salida)
	print()
	for key in dic_relaciones_derAizq:
		campos="|".join(dic_relaciones_derAizq[key])
		salida=key+":"+campos
		print(salida)
	
	#~ with open("out/"+s_prefijo_archivo+"_dicts_relaciones.json","w") as archivo:
		#~ json.dump(dic_relaciones_izqAder,archivo)
		#~ json.dump(dic_relaciones_derAizq,archivo)
				
	return 0

if __name__ == '__main__':
	import sys
	sys.exit(main(sys.argv))
