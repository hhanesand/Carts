//track whenever the user scans a barcode that is not in the database
Parse.Cloud.define("trackMissingBarcode", function(request, response) {
    var query = new Parse.Query("missingProducts");
    query.equalTo("barcode", request.params.barcode);
                   
    query.first({
        success : function(object) {
            if(object) {
                object.increment("count", 1);
                object.save(null, {
                        success : function(missingBarcode) {
                        response.success("Updated count");
                    },
                    error : function(error) {
                        response.error("Error saving updated count");
                    }
                });
            } else {
                var MissingBarcodeClass = new Parse.Object.extend("missingProducts");
                var missingBarcode = new MissingBarcodeClass();
                missingBarcode.set("barcode", request.params.barcode);
                missingBarcode.set("count", 0);
                missingBarcode.save(null, {
                    success : function(missingBarcode) {
                        response.success("Added new item");
                    },
                    error : function(error) {
                        response.error("Error saving new item");
                    }
                });
            }
        },
        error : function() {
            response.error("Error querying");
        }
    });
});

function checkJSON (json) {
    var parsed;

    try {
        parsed = JSON.parse(json);
    } catch(err) {
        return json;
    }

    return parsed;
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
        var results_json = [checkJSON(p1.text)[0].productname, checkJSON(p2.text).itemname, checkJSON(p3.text).name];
        console.log(results_json);

        var numberOfOccurences = [];

        for (var i = results_json.length - 1; i >= 0; i--) {
            var name = results_json[i];
            var words = name.split(" ");

            for (var j = words.length - 1; j >= 0; j--) {
                numberOfOccurences[words[j]] = numberOfOccurences[words[j]] + 1;
            }
        }

        console.log("Occurences " + numberOfOccurences);

        response.success("");
    }, function(p1, p2, p3) {
        console.error("There was an error in networking or parsing JSON");
        response.error("There was an error in networking or parsing JSON");
    });

    // Parse.Cloud.httpRequest({
    //     url: "http://www.outpan.com/api/get-product.php?apikey=4308c0742cfa452985e8cd4d569336aa&barcode=" + request.params.barcode
    // }).then(
    //     function(object) {
    //         console.log(JSON.parse(object["text"])["name"]);

    //         var itemClass = new Parse.Object.extend("item");
    //         var newObject = new itemClass();
    //         newObject.set("upc", )

    //         response.success(object);
    //     },
    //     function(object) {
    //         response.error(object);
    //     }
    // );
});