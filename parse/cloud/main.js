function getClass(class_name) {
    return Parse.Object.extend(class_name);
}

function makeQuery(class_name) {
    return new Parse.Query(getClass(class_name));
}

function makeObject(class_name) {
    var parse_class = getClass(class_name);
    return new parse_class();
}

//called when a user scans a barcode that is missing from both factual and parse
Parse.Cloud.define("trackMissingBarcode", function(request, response) {
    ensureUnique("missing", "barcode", request.params.barcode).then(
        function (object) {
            object.increment("count", 1);
            object.save(null, {
                success : function (object) {
                    response.success();
                }
            });
        }, function (error) {
            var object = makeObject("missing");

            object.save({
                count : 1,
                barcode : request.params.barcode,
                creator : request.user
            }, {
                success : function (object) {response.success();},
                error : function (object) {response.error();}
            });
        });
});

function ensureUnique(class_name, key, value) {
    var query = makeQuery(class_name);
    query.equalTo(key, value);

    return query.first().then(function(fetchedObject) {
        if (fetchedObject) {
            return Parse.Promise.as(fetchedObject);
        } else {
            return Parse.Promise.error();
        }
    });
}

function checkJSON(json) {
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