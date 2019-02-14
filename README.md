# doctoradoFuncionales


Ejemplo de uso:


bash src/preprocesamiento.sh -fs 50000 esWiki corpus/wiki_00

bash src/functionScore.sh -k 50 esWiki # FIXME: en este paso, la lista de palabras funcionales en realidad las estoy sacando a mano, hay que tener cuidado con eso, y recordar que lo que estoy usando es el orden, primero de la magnitud de frecuencia, luego de la longitud de la palabra, y por último, de la frecuencia.

bash src/multi_funcs.sh -sm 1000 esWiki	# FIXME: esta función utiliza el archivo de funcs1 que se hace a mano luego del paso anterior y escribe a las palabras funcionales, el filtro, por ahora TAMBIEN se hace a mano, y no debería, hay que arreglar ambas cosas.

bash src/triple_funcionales.sh -s esWiki

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


# TODO

Las observaciones que estoy haciendo son muy interesantes, he encontrado un patrón que me sirve estupéndamente para encontrar palabras funcionales que son indicadoras de sustantivos:

grep -Po "\b(\S+) \S+ \S+ \1\b" gutemberg_out | grep -Pv "(DIGITO|[^\w\s])" | awk '{printf("%s %s %s\n",$1,$3,$4)}' | sort | uniq -c | sort -rn | less

La instrucción anterior (que repite una primera aparición con dos palabras intermedias) me proporciona, en las dos últimas palabras, una buena lista de palabras funcionales que son indicadoras de sustantivos. Pero es importante considerarque son compuestos, las palabras que aparecen únicamente en la derecha son las que aparecen más antes de los sustantivos, pero las que aparecen en medio, aparecen ANTES de ellas, por ejemplo: and a, of the, in his. A veces las palabras que aparecen en medio también aparecen a la derecha, pero es mas importante que se queden en la lista de las de en medio. De hecho, creo que un buen punto para dejar de tomar en cuenta esto, es cuando aparece la primer palabra de hasta la derecha (the para el ingles) en la columna de en medio. Por otro lado, si se encuentra una palabra hasta la derecha que solo ha aparecido en el medio y una palabra en el medio que no está en ninguna de las dos listas, esa nueva palabra no se añade.

Hay que encontrar las funcionales que me forman sustantivos compuestos (como el 'of'). Una forma de encontrar dicha palabra es al tomar la primera de el siguiente patrón:

grep -Po "\b(LISTA1) (LISTA2) \S+ (LISTA1)\b" gutemberg_out | grep -Pv "[^\w\s]" | awk '{print $NF}' | sort | uniq -c | sort -rn | less

El primero parece ser muy bueno en encontrar unificadores de sustantivos, no se si pueda haber mas de uno, en español e ingles creo que no hay, pero podría haber en otro idioma y no se cómo saber si debería tomar más de uno. Esta información creo que me serviría mucho para encontrar verbos en los siguientes verbos, para filtrarlo y no tomarlo en cuenta.



En el primer paso (el primer patrón), al procesar, es importante conservar la información de las parejas con las que se encuentran las listas de palabras, ya que cuando se presentan pronombres (i,he,she) no se puede confiar demasiado en el patrón. Sin embargo es posible recuperar los pronombres con otro patrón y entonces usar esa información para "LIMPIAR" los resultados anteriores, es decir, quitar aquellos que solo hayan salido con pronombres. El nuevo patrón es:

grep -Po "^\S+ \S+ (LISTA1+2)\b" gutemberg_out | grep -Pv "(DIGITO|[^\w\s])" | awk '{printf("%s %s\n",$1,$2)}' | sort | uniq -c | sort -rn | less

En este caso, la idea es que la primer palabra de una oracion sea el sustantivo seguida de un verbo, seguida de una de las palabras funcionales sustantivadoras (y que por lo tanto sería a lo que afecta el verbo) de esta manera, las palabras que se encuentren como primeras y que hayan estado en la segunda lista de el módulo anterior serán pronombres, y no solo eso, sino que las palabras que les sigan serán verbos. Si hay una palabra antes de un verbo identificado además, esta se puede catalogar también como un pronombre. Y si en primer o segundo lugar se encuentra no una palabra nueva sino una de las que conforman la primera parte de las funcionales-sustantivos o que ninguna de las dos palabras haya sido vista antes, entonces se puede considerar a esa anterior como una expresión nada más (por ejemplo 'one of ...', 'at last', 'and as'),. Hay que tener en cuenta también que si nos encontramos un verbo y antes de él una de las palabras de la primera lista, entonces esa palabra es un CONECTOR GENERAL y verbos especificadores (is, was), ese conector puede ir antes tanto de verbos como de sustantivos y va a estar ligado siempre a un verbo pues esta refiriendo a algo antes mencionado o lo que está justo después.

Lo ideal sería que en este módulo se mantuvieran también las palabras que siguen después de las primeras dos para que aquellas que se van "LIMPIANDO" del modulo anterior también se quiten de este al mismo tiempo.

Con la lista de pronombres, se pueden buscar mas de esos CONECTORES GENERALES al ver si se pueden combinar entre ellos, dandole prioridad a poderse combinar con MUCHOS de ellos como en el siguiente código:

grep -Po "^(it|there|he|this|i|you|she|here|that) (it|there|he|this|i|you|she|here|that)\b" gutemberg_out | grep -Pv "(DIGITO|[^\s\w])" | sort -u | awk '{print $1}'| sort | uniq -c | sort -rn | less

Ya con la lista de verbos, se puede hacer la búsqueda de otro patrón para encontrar ahora palabra que une verbos compuestos, en este caso será:

grep -Po "\b(LISTA-VERBOS) \S+ (LISTA-VERBOS)\b" gutemberg_out | grep -Pv "[^\w\s]" | awk '{print $2}' | sort | uniq -c | sort -rn | less

De la lista resultante los primeros serán un gran indicador de verbos, tanto anterior como posterior, si además de ser indicador de verbo posterior es indicador de sustantivo posterior, entonces se puede usar como indicador de ARGUMENTO (ya que los argumentos pueden ser verbales o sustantivos)


Lo siguiente es encontrar verbos auxiliares:

grep -Po "\b(LISTA-PRONOMBRE) \S+ (LISTA-VERBOS)\b" gutemberg_out | grep -Pv "(DIGITO|[^\s\w])" | sort | uniq -c | sort -rn | less


