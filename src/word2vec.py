#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# vectores.py
#	Este programa entrena el word2vec

# TODO: FALTA PONER COMO PARAMETRO DE ENTRADA EL SUFIJO DE io

import nltk
from gensim.models import Word2Vec

def main(s_archivo_entrada):
	with open(s_archivo_entrada) as f:
		lineas=f.readlines()
	lineas_tokens=[]
	for linea in lineas:
		lineas_tokens.append(nltk.word_tokenize(linea))
	
	model = Word2Vec(lineas_tokens,min_count=2)
	
	# summarize the loaded model
	print(model)
	# summarize vocabulary
	words = list(model.wv.vocab)
	print(words)
	# access vector for one word
	print(model['sentence'])
	# save model
	model.save('model.bin')
	#~ # load model
	#~ new_model = Word2Vec.load('model.bin')
	#~ print(new_model)

if __name__ == '__main__':
	import sys
	#~ s_archivo_entrada=sys.argv[1]
	s_archivo_entrada="/home/pimentel/doctoradoFuncionales/corpus/gutemberg_out"
	sys.exit(main(s_archivo_entrada))
