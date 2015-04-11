Parse.Cloud.beforeSave("missing", function(request, response) {
    ensureUniqueObject("missing", request.object, "barcode").then(function(object) {
        console.log(object);
        console.log("done finding unique object");
        object.increment("count", 1);
        object.barcode = request.params.barcode; //the ensureUnique object can return an object whose barcode has not been set
    
        if (!object.get("user")) {
            object.set("user", request.params.user);
            console.log("Saved new user");
        }

        object.save().done(function(object) {
            response.success("Added or updated object.");
        });
    });
});

function ensureUniqueObject(className, object, checkKey) {
    console.log(object);
    var query = new Parse.Query(className);
    query.equalTo(checkKey, object.checkKey);

    return query.first().then(function (returnedObject) {
        if (object) {
            console.log("Similar object found");
            return returnedObject;
        } else {
            console.log("Object is unique");
            return object;
        }
    }, function (error) {
        console.log("Error in ensureUniqueObject");
    });
}

function createUniqueObject(className, checkKey, value) {
    console.log("Finding object");
    var query = new Parse.Query(className);
    query.equalTo(checkKey, value);

    return query.first().then(function(object) {
        if (object) {
            console.log("Returning old object");
            return object;
        } else {
            console.log("Returning new object");
            return createNewParseObject(className);
        }
    }, function(object) {
        console.log("Error in ensureUniqueObject function while fetching for className " + className + " , key " + checkKey + " and value " + value);
    });
}

function checkJSON (json) {
    var parsed;

    try {
        parsed = JSON.parse(json);
    } catch(err) {
        console.log("returing original");
        return json;
    }

    return parsed;
}

function normalizeInput(p1, p2, p3) {
    var results = [];

    console.log(checkJSON(p1.text)[0].productname.toLowerCase());
    console.log(checkJSON(p2.text).itemname.toLowerCase());
    console.log(checkJSON(p3.text).name.toLowerCase());

    results.push(checkJSON(p1.text)[0].productname.toLowerCase());
    results.push(checkJSON(p2.text).itemname.toLowerCase());
    results.push(checkJSON(p3.text).name.toLowerCase());

    console.log(results);
    return results;
}

var urls = ["http://www.outpan.com/api/get-product.php?apikey=4308c0742cfa452985e8cd4d569336aa&barcode=",
            "http://api.upcdatabase.org/json/938a6e05f72b4e5b7531c35374a4457d/",
            "http://www.searchupc.com/handlers/upcsearch.ashx?request_type=3&access_token=C9D1021E-37EA-4C29-BAF0-EE92A5AB03BE&upc="];

Parse.Cloud.define("upcLookup", function(request, response) {
    var promises = [];

    for (var i = urls.length - 1; i >= 0; i--) {
        promises.push(Parse.Cloud.httpRequest({url: urls[i] + request.params.barcode}));
    }

    Parse.Promise.when(promises).then(function(p1, p2, p3) {
        var results_json = normalizeInput(p1, p2, p3);
        var names = getBestName(results_json);

        ensureUniqueObject("pending", "barcode", request.params.barcode).then(function(object) {
            console.log("Starting update");
            object.barcode = request.params.barcode;
            object.name = names.join(" ");
            object.sources = results_json;

            object.save();

            console.log(names);
            response.success(names);
        }, function(object) {
            console.log("Error in ensureUniqueObject");
            response.error("Error in ensureUniqueObject");
        });
    }, function(p1, p2, p3) {
        console.error("There was an error in networking or parsing JSON");
        response.error("There was an error in networking or parsing JSON");
    });
});

function createNewParseObject (name) {
    var class_new = Parse.Object.extend(name);
    return new class_new();
}

function getBestName (results_json) {
    var numberOfOccurences = {};

    for (var i = results_json.length - 1; i >= 0; i--) {
            var words = results_json[i].split(" ");

            for (var j = words.length - 1; j >= 0; j--) {
                var word = words[j];

                if (word === "") {
                    continue;
                }

                if (numberOfOccurences[word]) {
                    numberOfOccurences[word] = numberOfOccurences[word] + 1;  
                } else {
                    numberOfOccurences[word] = 1;
                }
            }
        }

    console.log(numberOfOccurences);

    var keys = Object.keys(numberOfOccurences);
    var results_name = [];

    for (var k = keys.length - 1; k >= 0; k--) {
        var key = keys[k];

        if (numberOfOccurences[key] > 1) {
            results_name.push(key);
        }
    }

    return results_name;
}