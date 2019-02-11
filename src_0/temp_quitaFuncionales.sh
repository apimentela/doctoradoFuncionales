#!/bin/bash

##	temp_quitaFuncionales
#	CUIDADO: lo hace en el mismo lugar

function main {
	perl -C -ne 'print lc' "$1" \
	| perl -C -pe 's/\b(a|abajo|además|al|algo|alguien|alguna|algunas|algunos|ante|aquel|aquella|aquellas|aquello|aquellos|aunque|bajo|cabe|cómo|con|conmigo|consigo|contigo|contra|cual|cuál|cuales|cualesquiera|cualquiera|cuanto|cuantos|cuántos|cuyo|cuyos|de|del|demás|demasiada|demasiadas|demasiado|demasiados|desde|donde|durante|e|el|él|ella|ellas|ello|ellos|empero|en|entre|esa|esas|escasa|escasas|escaso|escasos|ese|eso|esos|esta|estas|este|esto|estos|hacia|hasta|la|las|le|les|alguno|lo|los|luego|mas|me|mediante|mi|mía|mías|mientras|mío|míos|misma|mismas|mismo|mismos|mucha|muchas|mucho|muchos|nada|nadie|ni|ninguna|ningunas|ninguno|ningunos|no|nos|nosotras|nosotros|nuestro|o|os|otra|otras|otro|otros|para|pero|poca|pocas|poco|pocos|por|probablemente|pues|que|qué|quien|quién|quienes|quienesquiera|quienquiera|quizás|se|según|si|sí|sin|so|sobre|suya|suyas|suyo|suyos|tampoco|tan|tanta|tantas|tanto|tantos|te|ti|toda|todas|todavía|todo|todos|tras|tú|tuya|tuyas|tuyo|tuyos|u|un|una|unas|uno|unos|usted|ustedes|varias|varios|versus|vía|vos|vosotras|vosotros|vuestra|vuestras|vuestro|vuestros|y|yo)\b//g' \
	| tr -s "[:space:]" > "${1}_temp"
	mv "${1}_temp" "$1"
}
export -f main

parallel main ::: $@
