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

Parse.Cloud.define("upcLookup", function(request, response) {
    Parse.Cloud.httpRequest({
        url: "http://api.factual.com/t/products-cpg",
        params: {
            q : request.barcode,
            KEY : request.KEY
        },
        success: function (httpResponse) {
            response.success(httpResponse.data);
        },
        error: function (httpResponse) {
            response.error(httpResponse.data);
        }
    });
});