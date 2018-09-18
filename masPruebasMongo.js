db.relacionesFuncionales.aggregate([{$group:{_id:{p1:"$palabra1",r:"$r2",p2:"$palabra2"},total:{$sum:"$frecuencia"}}},{$group:{_id:{p1:"$_id.p1",p2:"$_id.p2"},total:{$sum:"$total"},sum:{$sum:1}}},{$match:{sum:1}},{$sort:{total:-1}}],{allowDiskUse:true})

db.relacionesFuncionales.aggregate([{$group:{_id:{p1:"$palabra1",r:"$r2",p2:"$palabra2"},total:{$sum:"$frecuencia"}}},{$group:{_id:{p1:"$_id.p1",p2:"$_id.p2"},total:{$sum:"$total"},sum:{$sum:1},funcs:{$addToSet:"$_id.r"}}},{$match:{sum:1,funcs:["por"]}},{$sort:{total:-1}}],{allowDiskUse:true})


db.relacionesFuncionales.aggregate([{$match:{palabra1:"medalla",palabra2:"plata"}},{$group:{_id:{r1:"$r1",r2:"$r2",r3:"$r3"},sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])

db.relacionesFuncionales.aggregate([{$match:{palabra1:"medalla",r1:"la",r2:"de",r3:"en_los"}},{$group:{_id:"$palabra2",sum:{$sum:"$frecuencia"}}},{$sort:{sum:-1}}])
