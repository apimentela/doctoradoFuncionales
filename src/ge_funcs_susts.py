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
	set_palabras_izq=set()
	set_palabras_der=set()
	set_relaciones=set()
	for linea in sys.stdin:
		l_linea=linea.strip().split()
		if len(l_linea) != 2: continue	# Si no hay dos palabras se ignora la linea
		s_palabra_izq=l_linea[0]
		s_palabra_der=l_linea[1]
		if s_palabra_der in set_palabras_izq : continue # Si en la segunda columna hay una palabra que ha aparecido como la primera, entonces la que aparece como la primera no se toma en cuenta asi que se continua sin cambiar nada
		else: set_palabras_der.add(s_palabra_der)
		if s_palabra_izq in set_palabras_der: # Si se encuentra una palabra en la primera columna que haya aparecido en la segunda antes, entonces se saca de la segunda lista para que solo esté en la primera
			set_palabras_izq.add(s_palabra_izq)
			set_palabras_der.remove(s_palabra_izq)
    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
