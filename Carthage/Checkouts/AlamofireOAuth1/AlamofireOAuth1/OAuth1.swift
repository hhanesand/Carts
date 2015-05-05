//
//  OAuth1.swift
//  AlamofireOAuth1
//
//  Created by Hakon Hanesand on 4/27/15.
//  Copyright (c) 2015 Hakon Hanesand. All rights reserved.

import Alamofire
import CommonCrypto

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

//from http://stackoverflow.com/a/24888789/4080860
extension String {
    func stringByAddingPercentEncodingForFormUrlencoded() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._* ")
        
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)?.stringByReplacingOccurrencesOfString(" ", withString: "+")
    }
    
    func indexOf(target: String) -> Int {
        var range = self.rangeOfString(target)
        
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
}

public enum Factual: URLRequestConvertible {
    
    static let baseURLString = "http://api.v3.factual.com/t/"
    
    static let clientId = "n5md5zTCv67RV2ctEQKrhK2cAzggCqs3khynDhKT"
    static let clientSecret = "Utn7HYXJ77lW3fTYMFiB9Zvu0GjT1AInnjeqYFct"
    
    case GetBarcode(String)
    
    var method: Alamofire.Method {
        switch self {
        case .GetBarcode:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .GetBarcode:
            return "products-cpg"
        }
    }
    
    public var URLRequest: NSURLRequest {
        let URL = NSURL(string: Factual.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue;
        var parameters = OAuth.constructOAuthParametersWith(ClientId: Factual.clientId, clientSecret: Factual.clientSecret, tokenId: nil, tokenSecret: nil)
        
        switch self {
            
        case .GetBarcode(let barcode): //I believe this is the most optimal solution if I still want to use Alamofire's URL.encode code...
            parameters.merge(["q" : barcode])
            let request = OAuth.process(Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters)).0 as! NSMutableURLRequest
            
            //we want to build the OAuth signature base string described here http://nouncer.com/oauth/authentication.html
            let oauthBaseString = calculateOAuthBaseString(Request: request)
            let oauth_signature = generateOAuthSignatureWithHMACAlgorithmWith(oauthBaseString)

            request.URL = NSURL(string: "\(request.URLString)&oauth_signature=\(oauth_signature)".stringByAddingPercentEncodingForFormUrlencoded()!)
            
            return request
        }
    }
    
    private func calculateOAuthBaseString(Request request: NSMutableURLRequest) -> String {
        let indexOfQueryParameters = request.URLString.rangeOfString("?")!.startIndex
        
        let urlString = request.URLString.substringToIndex(indexOfQueryParameters)
        let queryParameters = request.URLString.substringFromIndex(advance(indexOfQueryParameters, 1)) //exclude ? in string
        let encodedQueryParameters = queryParameters.stringByAddingPercentEncodingForFormUrlencoded()!
        
        return "\(Alamofire.Method.GET.rawValue)&\(urlString)&\(encodedQueryParameters)"
    }
    
    private func generateOAuthSignatureWithHMACAlgorithmWith(oauthBaseString: String) -> String {
        let oauthRequestKey = "\(Factual.clientSecret)&"
        
        let key = oauthRequestKey.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let text = oauthBaseString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        let oauthSignature = UnsafeMutablePointer<CUnsignedChar>.alloc(Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key.bytes, Int(key.length), text.bytes, Int(text.length), oauthSignature)
        
        let result = NSData(bytes: oauthSignature, length: Int(CC_SHA1_DIGEST_LENGTH))
        oauthSignature.destroy()
        
        return result.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
    }
}

public extension NSMutableURLRequest {
    
    
}


public class OAuth {
    
    private struct Variables { //class vars not supported yet
        static let nonceHistory: Set<String> = []
        static var previousTimestamp: String = ""
        static var timestamp: String = ""
    }
    
    private class var previousTimestamp: String {
        get {return Variables.previousTimestamp}
        set {Variables.previousTimestamp = newValue}
    }
    
    private class var timestamp: String {
        var time = timeval()
        gettimeofday(&time, nil)
        
        Variables.previousTimestamp = Variables.timestamp
        Variables.timestamp = "\(time.tv_sec)"
        return Variables.timestamp
    }
    
    private class var nonceHistory: Set<String> {
        return Variables.nonceHistory
    }
    
    public class func generateNonceAndTimestamp() -> (nonce: String, timestamp: String) {
        var nonce: String
        var timestamp: String
        
        do {
            timestamp = self.timestamp;
            
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let length = UInt32(count(letters))
    
            nonce = (0..<32).map { (_) in letters[advance(letters.startIndex, Int(arc4random_uniform(length)))]}
                    .reduce("") { (string, char) in string + [char]}
        

        } while timestamp != previousTimestamp && nonceHistory.contains(nonce)
        
        return (nonce, timestamp)
    }
    
    struct Constants {
        static let OAuthVersionKey = "oauth_version"
        static let OAuthVersion = "1.0"
        
        static let OAuthConsumerIdentifierKey = "oauth_consumer_key"
        static let OAuthTokenIdentifierKey = "oauth_token"
        
        static let OAuthSignatureMethod = "HMAC-SHA1"
        static let OAuthSignatureMethodKey = "oauth_signature_method"
        
        static let OAuthTimestampKey = "oauth_timestamp"
        static let OAuthNonceKey = "oauth_nonce"
    }
    
    public class func constructOAuthParametersWith(ClientId clientId: String, clientSecret: String, tokenId: String?, tokenSecret: String?) -> [String : AnyObject] {
        var parameters = [String : AnyObject]()
        
        if let tokenId = tokenId {
            parameters.updateValue(tokenId, forKey: Constants.OAuthTokenIdentifierKey)
        }
        
        parameters.updateValue(Constants.OAuthVersion, forKey: Constants.OAuthVersionKey)
        parameters.updateValue(Constants.OAuthSignatureMethod, forKey: Constants.OAuthSignatureMethodKey)
        parameters.updateValue(clientId, forKey: Constants.OAuthConsumerIdentifierKey)
        
        let (nonce, timestamp) = OAuth.generateNonceAndTimestamp()
        parameters.updateValue(nonce, forKey: Constants.OAuthNonceKey)
        parameters.updateValue(timestamp, forKey: Constants.OAuthTimestampKey)
        
        return parameters
    }
    
    public class func process(tuple: (NSURLRequest, NSError?)) -> (NSURLRequest, NSError?) {
        let mutableCopy = tuple.0.mutableCopy() as! NSMutableURLRequest
        return (tuple.0, tuple.1)
    }
}

public enum OAuth1SignatureMethod {
    case PlainText
    case HMAC_SHA1
}

