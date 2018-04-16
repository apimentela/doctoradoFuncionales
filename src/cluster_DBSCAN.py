#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# cluster.py
#	Este programa es el encargado de obtener clusters a partir de los
#	vectores. Recibe como parámetro el nombre del archivo con los vectores

import numpy as np
import matplotlib.pyplot as plt

from sklearn.cluster import DBSCAN
from sklearn import metrics
from sklearn.preprocessing import StandardScaler

def lector_vectores():
	vectores=[]
	with open(archivo_vectores,"r") as archivo:
		for linea in archivo:
			elementos=linea.split()
			#~ vectores[elementos[0]]=elementos[1:]
			vectores.append(elementos[1:])
	return vectores

def main():
	# #############################################################################
	# Compute DBSCAN
	db = DBSCAN(eps=0.5, min_samples=100).fit(vectores)
	core_samples_mask = np.zeros_like(db.labels_, dtype=bool)
	core_samples_mask[db.core_sample_indices_] = True
	labels = db.labels_
	
	# Number of clusters in labels, ignoring noise if present.
	n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)
	print('Estimated number of clusters: %d' % n_clusters_)
	
	# #############################################################################
	# Plot result

	# Black removed and is used for noise instead.
	unique_labels = set(labels)
	colors = [plt.cm.Spectral(each)
			  for each in np.linspace(0, 1, len(unique_labels))]
	for k, col in zip(unique_labels, colors):
		if k == -1:
			# Black used for noise.
			col = [0, 0, 0, 1]

		class_member_mask = (labels == k)

		xy = vectores[class_member_mask & core_samples_mask]
		plt.plot(xy[:, 0], xy[:, 1], 'o', markerfacecolor=tuple(col),
				 markeredgecolor='k', markersize=14)

		xy = vectores[class_member_mask & ~core_samples_mask]
		plt.plot(xy[:, 0], xy[:, 1], 'o', markerfacecolor=tuple(col),
				 markeredgecolor='k', markersize=6)

	plt.title('Estimated number of clusters: %d' % n_clusters_)
	plt.show()
	
	return 0

if __name__ == '__main__':
	import sys
	args=sys.argv
	archivo_vectores= args[1]
	vectores=lector_vectores()
	vectores = StandardScaler().fit_transform(vectores)
	sys.exit(main())
