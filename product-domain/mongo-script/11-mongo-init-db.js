// TODO form db name env
db = new Mongo().getDB("product-domain");

db.createCollection('product', { 
    capped: false 
});

db.createCollection('manufacturer', { 
    capped: false 
});


db.createCollection('user', { 
    capped: false 
});