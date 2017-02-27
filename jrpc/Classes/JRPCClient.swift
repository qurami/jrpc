//
//  JRPCClient.swift
//  Pods
//
//  Created by Marco Musella on 24/02/2017.
//
//

import Foundation

enum JRPCClientError: Error{
    case unableToParseRequest
    case unableToParseResponse
    case badJSONRPCVersion
}

public class JRPCClient{
    
    public init() {
        // This initializer intentionally left empty
    }
    
    public func perform(request jrpcRequest: JRPCRequest, withURL endpointURL: URL, responseHandler callback: @escaping (JRPCResponse?, Error?) -> Void ){
        
        if let jsonData = jrpcRequest.toJson()!.data(using: String.Encoding.utf8) {
            
            let request = NSMutableURLRequest(url: endpointURL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (result, urlresponse, error) in
                
                if error != nil{
                    callback(nil, error)
                } else if result != nil {
                    
                    if let rawJson = try? JSONSerialization.jsonObject(with: result!),
                        let rawResponseDictionary = rawJson as? [String: Any]{
                        let parseResult = JRPCClient.parseJRPCResponse(dictionary: rawResponseDictionary)
                        callback(parseResult.response, parseResult.error)
                    } else{
                        callback(nil,JRPCClientError.unableToParseRequest)
                    }
                }
            })
            dataTask.resume()
        
        } else{
            callback(nil,JRPCClientError.unableToParseRequest)
        }
    }
    
    static func parseJRPCResponse(dictionary: Dictionary<String,Any>) -> (response: JRPCResponse?,error: JRPCClientError?){
        
        guard dictionary["jsonrpc"] != nil && dictionary["jsonrpc"] as? String == "2.0" else{
            return (nil, JRPCClientError.unableToParseResponse)
        }
        
        guard (dictionary["id"] == nil && dictionary["error"] != nil) ||
            (dictionary["id"] != nil && (dictionary["id"] is String || dictionary["id"] is Int)) else{
            return (nil, JRPCClientError.unableToParseResponse)
        }
        
        guard dictionary["error"] != nil || dictionary["result"] != nil else{
            return (nil, JRPCClientError.unableToParseResponse)
        }
        
        
        var jrpcError: JRPCResponseError? = nil
        if let rawError = dictionary["error"] as? Dictionary<String,Any>{
            let jrpcErrorParsingResult = JRPCClient.parseJRPCResponseError(dictionary: rawError)
            if let parseDictionaryError = jrpcErrorParsingResult.error{
                return (nil, JRPCClientError.unableToParseResponse)
            }
            jrpcError = jrpcErrorParsingResult.jrpcError
        }
        
        var ID: String? = nil
        if let rawID = dictionary["id"]{
                ID = "\(rawID)"
        }
        
        return (JRPCResponse(id: ID, result: dictionary["result"], error: jrpcError), nil)
    }
    
    static func parseJRPCResponseError(dictionary: Dictionary<String,Any>) -> (jrpcError: JRPCResponseError?,error: JRPCClientError?){
        
        guard dictionary["code"] != nil && dictionary["code"] is Int else{
            return (nil, JRPCClientError.unableToParseResponse)
        }
        
        guard dictionary["message"] != nil && dictionary["message"] is String else{
            return (nil, JRPCClientError.unableToParseResponse)
        }
        
        let code = dictionary["code"] as! Int
        let message = dictionary["message"] as! String
        
        return (JRPCResponseError(code: code , message: message, data: dictionary["data"]),nil)
    }
}
