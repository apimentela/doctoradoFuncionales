
db.relacionesFuncionales.aggregate([{$match:{palabra2:"rápido"}},{$group:{_id:{r1:"$r1",r2:"$r2",r3:"$r3"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.find({palabra2:"rápido",r1:"el",r2:"de",r3:"que"})
db.relacionesFuncionales.find({palabra2:"rápido",r1:"el",r2:"de",r3:"que"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra1:"doble",r1:"el",r2:"de",r3:"que"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra2:"rápido",r2:"de",r3:"que"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra1:"doble",r1:"el",r2:"de"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra2:"rápido",r1:"el",r2:"de"}).sort({frecuencia:-1})
db.relacionesFuncionales.aggregate([{$match:{r2:"y"}},{$sort:{frecuencia:-1}}],{allowDiskUse:true})
db.relacionesFuncionales.find({palabra2:"rápido",r1:"por",r2:"tan"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra1:"contestar",r1:"por",r2:"tan"}).sort({frecuencia:-1})
db.relacionesFuncionales.aggregate([{$match:{palabra2:"rápido"}},{$group:{_id:{r1:"$r1",r2:"$r2"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}]) //Esto dio mejor combinacion de palabras funcionales

db.relacionesFuncionales.aggregate([{$match:{palabra1:"rápido"}},{$group:{_id:{r2:"$r2",r3:"$r3"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.find({palabra2:"fácil",r2:"y",r3:"que"}).sort({frecuencia:-1})

db.relacionesFuncionales.find({palabra1:"contestar",r1:"por",r2:"tan",r3:"y"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra1:"ser",r1:"no",r2:"tan",r3:"y"}).sort({frecuencia:-1})

db.relacionesFuncionales.find({palabra2:"desvanece",r1:"la",r2:"se"}).sort({frecuencia:-1})
db.relacionesFuncionales.aggregate([{$match:{palabra1:"desvanece"}},{$group:{_id:{r2:"$r2",r3:"$r3"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.find({palabra2:"fin",r1:"se",r2:"el",r3:"de"}).sort({frecuencia:-1})

db.relacionesFuncionales.aggregate([{$match:{palabra2:"tonto"}},{$group:{_id:{r1:"$r1",r2:"$r2"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.find({palabra2:"tonto",r1:"el",r2:"mas"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra1:"angel",r1:"el",r2:"mas"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra1:"niño",r1:"el",r2:"mas"}).sort({frecuencia:-1}

db.relacionesFuncionales.aggregate([{$match:{palabra1:"tonto"}},{$group:{_id:{r2:"$r2",r3:"$r3"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.find({palabra1:"tonto",r2:"que",r3:"que"}).sort({frecuencia:-1})

db.relacionesFuncionales.aggregate([{$match:{palabra1:"estúpido"}},{$group:{_id:{r2:"$r2",r3:"$r3"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.aggregate([{$match:{palabra2:"estúpido"}},{$group:{_id:{r1:"$r1",r2:"$r2"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])

db.relacionesFuncionales.aggregate([{$match:{palabra1:"esposa"}},{$group:{_id:"$palabra2",sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.aggregate([{$match:{palabra2:"esposa"}},{$group:{_id:"$palabra1",sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.aggregate([{$match:{palabra1:"esposo"}},{$group:{_id:"$palabra2",sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.aggregate([{$match:{palabra2:"esposo"}},{$group:{_id:"$palabra1",sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])

db.relacionesFuncionales.aggregate([{$match:{palabra1:"esposa"}},{$group:{_id:{r2:"$r2",r3:"$r3"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
db.relacionesFuncionales.find({palabra1:"esposa",r2:"de",r3:"y"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra2:"pedro",r1:"la",r2:"de",r3:"y"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra2:"pedro",r2:"de",r3:"y"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra1:"esposa",r2:"de",r3:"del"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra1:"esposa",r2:"del",r3:"de"}).sort({frecuencia:-1})
db.relacionesFuncionales.find({palabra2:"presidente",r1:"la",r2:"del",r3:"de"}).sort({frecuencia:-1})
