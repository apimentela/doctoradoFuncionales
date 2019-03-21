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

#OJO, el patrón anterior no funciona para español, con algunos experimentos creo que vale mas jugar con algo mas abstracto: la variedad de palabras con las que se juntan, algo como esto:

grep -Po "^($lista2) \S+ \S+ ($lista1) ($lista2)\b" novelas_out | grep -Pv "( de |DIGITO|[^\w\s])" | awk '{printf("%s %s\n",$1,$2)}' | sort -u | awk '{print $1}' | sort | uniq -c | sort -rn | less
y
grep -Po "^($lista2) \S+ \S+ ($lista1) ($lista2)\b" novelas_out | grep -Pv "( de |DIGITO|[^\w\s])" | awk '{printf("%s %s\n",$3,$4)}' | sort -u | awk '{print $2}' | sort | uniq -c | sort -rn | less

donde el punto es buscar un sustantivo en las primeras dos palabras, seguido de un verbo y luego otro indicador de sustantivo, y con lo siguiente es buscar la primera y cuarta palabra que tengan mayor variedad (que indicarían sustantivos y verbos respectivamente) para luego ir bajando



# Encontré un buen patrón para encontrar pronombres que inicialmente pasaron como parte de la lista2. y es buscar palabras de la lista2 seguidas de palabras de la lista1. Sin embargo, para esto es MUY importante que se tengan bien identificadas las palabras que son indicadoras de sustantivos, porque pueden aparecer también con ese filtro, sobre todo por homónimo. Así que hay que quitarlas antes












# AQUI, hay un nuevo patrón para encontrar pronombre que creo que sirve también para el español: el "en" se encuentra por ser la palabra funcional con mayor variedad de palabras anteriores en el patrón anterior (que yo pensaría que es un indicador de verbo). La condición de paro sería la misma de encontrar una de las palabras confiables (como 'el' o 'la', quizá sea mejor buscar cualquiera de las primeras 2 en cualquier caso)

grep -Po "^(la|el|los|su|las|tan|del|al|se|sus|un|una|the|lo|mi|me|le|sin|muy|no|mis|tu|sea) \S+ en (la|el|los|su|las|tan|del|al|se|sus|un|una|the|lo|mi|me|le|sin|muy|no|mis|tu|sea)" novelas_out | grep -Pv "(DIGITO|[^\w\s])" | sort | uniq -c | sort -rn | less










# Es importante encontrar encontrar preposiciones, y creo que una manera es mediante:

grep -Po "\by (\S+) (el|la|los|las)\b" novelas_out | grep -Pv "(DIGITO|[^\w\s])" | awk '{print $2}' | sort | uniq -c | sort -rn | less

Aunque entonces también es importante encontrar las combinaciones de estas palabras, que creo que pueden dar aún más información que ellas por separado (OJO, quitar el "de" de la lista). En el siguiente patrón, la lista sale del anterior.

grep -Po "\b(en|a|con|que|por|se|todos|cuando|si|como|sobre|no|todas|hasta|todo|toda|para|luego|entre|desde|yo|bajo|durante|mientras|aunque|entonces|es|era|sin|hacia)( .*?)? (en|a|con|que|por|se|todos|cuando|si|como|sobre|no|todas|hasta|todo|toda|para|luego|entre|desde|yo|bajo|durante|mientras|aunque|entonces|es|era|sin|hacia)\b" novelas_out | grep -Pv "(DIGITO|[^\w\s])" | sort | uniq -c | sort -rn | less









Con la lista de pronombres, se pueden buscar mas de esos CONECTORES GENERALES al ver si se pueden combinar entre ellos, dandole prioridad a poderse combinar con MUCHOS de ellos como en el siguiente código:

grep -Po "^(it|there|he|this|i|you|she|here|that) (it|there|he|this|i|you|she|here|that)\b" gutemberg_out | grep -Pv "(DIGITO|[^\s\w])" | sort -u | awk '{print $1}'| sort | uniq -c | sort -rn | less

Ya con la lista de verbos, se puede hacer la búsqueda de otro patrón para encontrar ahora palabra que une verbos compuestos, en este caso será:

grep -Po "\b(LISTA-VERBOS) \S+ (LISTA-VERBOS)\b" gutemberg_out | grep -Pv "[^\w\s]" | awk '{print $2}' | sort | uniq -c | sort -rn | less

De la lista resultante los primeros serán un gran indicador de verbos, tanto anterior como posterior, si además de ser indicador de verbo posterior es indicador de sustantivo posterior, entonces se puede usar como indicador de ARGUMENTO (ya que los argumentos pueden ser verbales o sustantivos)


Lo siguiente es encontrar verbos auxiliares:

grep -Po "\b(LISTA-PRONOMBRE) \S+ (LISTA-VERBOS)\b" gutemberg_out | grep -Pv "(DIGITO|[^\s\w])" | sort | uniq -c | sort -rn | less

##

para continuar con los experimentos, necesito primero una lista de palabras funcionales para agarrar convinaciones, comienzo con esto: 30 parece ser un buen head, o que la relación de frecuencia sea menor a 5e-3 

perl -C -wlne "/\b(\S+) \S+ y \1 \S+\b/ and print $&" esWiki_out | perl -C -wlne "/(DIGITO|[^\w\s])/ or print" | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 30 | awk '{print $2}' | tr "\n" "|"  > ../temp/lista_funcionales

No es tan fácil la expansión, empiezan a salir cosas mucho mas ruidosas. Sin embargo, creo que aquí entra perfecto mi detector de palabras funcionales indicadoras de sustantivos, porque con esas se pueden filtrar de las combinaciones del "y" las que no son de sustantivos, y quitarlas de las combinaciones. POR SUPUESTO si es la misma palabra, entonces aunque no sea indicadora de sustantivo esta bien. Por otro lado, con la combinación de información también puede detectar de forma un poco mas segura palabras como "del"


##############################################################################
# He encontrado que el esquema de anillos es bastante bueno, al menos para lo que no sea whatsapp (mas que la primera parte)

perl -C -wlne "/\b(\S+) (\S+) \S+ \2 \1\b/ and print $&" whatsApp_out | perl -C -wlne "/(?:DIGITO|[^\w\s]|\b(\S+) (\S+) (\1 )?\2\b)/ or print" | sort -u | awk '{print $3}' | sort | uniq -c | sort -rn | less

El patrón anterior son para la búsqueda de palabras que sean el centro de espejos, si se quitan en el whats las líneas que tienen puras repeticiones nada mas (ultima parte de las elecciones del segundo perl) incluso allí sirve para encontrar el "y" (o el "o"), entre más palabras se buscan, se reducen los resultados, pero las disyunciones siempre se conservan.

Luego de eso, se pueden ver en los anillos:

grep -Po "\b(\S+) (\S+) \S+ \1 \2\b" enWiki_out | perl -C -wlne "/(DIGITO|[^\w\s])/ or print" | sort | uniq -c | sort -rn | less

allí aparecen las convinaciones indicadoras de sustantivos (no en whats) y en primer lugar la preposición que une sustantivos, además de que sale una gran lista de sustantivos luego luego. Si se aumenta a 3 palabras a coincidir con una de pivote, vuelve a aparecer el "y" central, por lo que 2 son las palabras que forman estructura (para ingles y español).

grep -Po "\b(\S+) (\S+) \S+ \1 \2\b" esWiki_out | perl -C -wlne "/(DIGITO|[^\w\s])/ or print" | sort -u | awk '{print $1, $2}' | sort | uniq -c | sort -rn | less

Así que es mejor mantener solo dos palabras alrededor, las de pivote se puede aumentar a 2 y aparecen entidades de dos palabras y adjetivos. Si se sigue aumentando van apareciendo más fenómenos.

Esto saca muy buenas relaciones aunque se tiene que pulir mas:

perl -C -wlne "/\b(.+) \S+ y \1 \S+\b/ and print $&" esWiki_out | perl -C -wlne "/(DIGITO|[^\w\s])/ or print" | sort | uniq -c | sort -rn | less
