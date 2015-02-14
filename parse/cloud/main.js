
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.beforeSave("missingProducts", function(request, response) {
    if(!request.object.get("barcode")) {
        response.error("Barcode must be specified");
    } else {
        var query = new Parse.Query("missingProducts");
        query.equalTo("barcode", request.object.get("barcode"))
        
        query.first({
            success : function(object) {
                if(object) {
                    response.error("Already exists");
                } else {
                    response.success();
                }
            },
            error : function(object) {
                response.error("Could not validate completeness");
            }
        });
    }
});