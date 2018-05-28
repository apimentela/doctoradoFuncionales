# doctoradoFuncionales



Ejemplo de uso:



bash src/preprocesamiento.sh -s 50000 esWiki corpus/wiki_00

bash src/functionScore.sh -k 50 esWiki # FIXME: en este paso, la lista de palabras funcionales en realidad las estoy sacando a mano, hay que tener cuidado con eso, y recordar que lo que estoy usando es el orden, primero de la magnitud de frecuencia, luego de la longitud de la palabra, y por último, de la frecuencia.

bash src/multi_funcs.sh -s esWiki	# FIXME: esta función utiliza el archivo de funcs1 que se hace a mano luego del paso anterior y escribe a las palabras funcionales, el filtro, por ahora TAMBIEN se hace a mano, y no debería, hay que arreglar ambas cosas.

bash src/ventanas_funcionales.sh -s esWiki

bash src/vectores.sh -sp esWiki	# OJO,FIXME,TODO: esta función necesita el archivo funcs ya con las palabras funcionales, pero OJO, es necesario que esa lista esté ordenada en orden inverso, para que no haya problemas cuando se hagan las búsquedas y se encuentre la opción más larga en lugar de la más corta.



bash src/clusters.sh esWiki	# Esto arma muchos clusters a diferentes niveles



bash src/ventanas2graphs.sh



(hay que recordar correr "parallel --record-env" antes de la primera vez que se ejecuta)



Para la limipieza de las novelas electronicas se están usando las siguientes opciones:
--no-chapters-in-toc
--enable-heuristics
--unsmarten-punctuation
--max-line-length=0
--txt-output-formatting=plain
--no-inline-fb2-toc *si es fb2
