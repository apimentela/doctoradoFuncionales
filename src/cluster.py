#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# cluster.py
#	Este programa es el encargado de obtener clusters a partir de los
#	vectores. Recibe como parámetro el nombre del archivo con los vectores

from __future__ import division
from sklearn.cluster import KMeans
from numbers import Number
from pandas import DataFrame
import sys, codecs, numpy

class autovivify_list(dict):
  '''A pickleable version of collections.defaultdict'''
  def __missing__(self, key):
    '''Given a missing key, set initial value to an empty list'''
    value = self[key] = []
    return value

  def __add__(self, x):
    '''Override addition for numeric types when self is empty'''
    if not self and isinstance(x, Number):
      return x
    raise ValueError

  def __sub__(self, x):
    '''Also provide subtraction method'''
    if not self and isinstance(x, Number):
      return -1 * x
    raise ValueError

def build_word_vector_matrix(vector_file, n_words=67207):
  '''Return the vectors and labels for the first n_words in vector file'''
  numpy_arrays = []
  labels_array = []
  with codecs.open(vector_file, 'r', 'utf-8') as f:
    for c, r in enumerate(f):
      sr = r.split()
      labels_array.append(sr[0])
      numpy_arrays.append( numpy.array([float(i) for i in sr[1:]]) )

      if c == n_words:
        return numpy.array( numpy_arrays ), labels_array

  return numpy.array( numpy_arrays ), labels_array

def find_word_clusters(labels_array, cluster_labels):
  '''Return the set of words in each cluster'''
  cluster_to_words = autovivify_list()
  for c, i in enumerate(cluster_labels):
    cluster_to_words[ i ].append( labels_array[c] )
  return cluster_to_words

if __name__ == "__main__":
  input_vector_file = sys.argv[1] # Vector file input (e.g. glove.6B.300d.txt)
  #n_words = int(sys.argv[2]) # Number of words to analyze 
  n_clusters = int( sys.argv[3] ) # Number of clusters to make
  df, labels_array = build_word_vector_matrix(input_vector_file)#, n_words)
  kmeans_model = KMeans(init='k-means++', n_clusters=n_clusters, n_init=10)
  kmeans_model.fit(df)

  cluster_labels  = kmeans_model.labels_
  cluster_inertia   = kmeans_model.inertia_
  cluster_to_words  = find_word_clusters(labels_array, cluster_labels)

  with open ("../out/clusters_"+str(n_clusters),"w") as salida:
	  for c in cluster_to_words:
		  print >> salida, cluster_to_words[c]
		  print >> salida, "\n"

  #~ for c in cluster_to_words:
    #~ print cluster_to_words[c]
    #~ print "\n"
