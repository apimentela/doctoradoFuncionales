#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# vectores.py
#	Este programa entrena el word2vec

# TODO: FALTA PONER COMO PARAMETRO DE ENTRADA EL SUFIJO DE io

import nltk
from gensim.models import Word2Vec
from gensim.test.utils import datapath

def main(s_archivo_entrada):
	s_archivo_modelo=s_archivo_entrada
	model = Word2Vec.load(s_archivo_modelo)
	similarities = model.wv.evaluate_word_pairs(datapath('wordsim353.tsv'))
	analogy_scores = model.wv.evaluate_word_analogies(datapath('questions-words.txt'))
	similarities
	analogy_scores
	
	

if __name__ == '__main__':
	import sys
	#~ s_archivo_entrada=sys.argv[1]
	s_archivo_entrada="/home/pimentel/doctoradoFuncionales/out/gutemberg_model.bin"
	sys.exit(main(s_archivo_entrada))
