# doctoradoFuncionales

Ejemplo de uso:

bash src/preprocesamiento.sh -s 50000 esWiki corpus/wiki_00
bash src/functionScore.sh -k 50 esWiki 
bash src/vectores.sh -sp esWiki 

(hay que recordar correr "parallel --record-env" antes de la primera vez que se ejecuta)

Para la limipieza de las novelas electronicas se están usando las siguientes opciones:
--no-chapters-in-toc
--enable-heuristics
--unsmarten-punctuation
--max-line-length=0
--txt-output-formatting=plain
--no-inline-fb2-toc *si es fb2
