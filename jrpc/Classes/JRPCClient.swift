//
//  JRPCClient.swift
//  Pods
//
//  Created by Marco Musella on 24/02/2017.
//  Copyright © 2017 Quami s.r.l. All rights reserved.
//

import Foundation

public enum JRPCClientError: Error{
    case unableToParseRequest
    case unableToParseResponse
    case badJSONRPCVersion
}



/// A protocol used by the client to parse a passed Request to JSON.
@objc public protocol JRPCParsable{
    
    
    /// Must return a JSONRPC 2.0 compliant request object, for furter informations
    /// refer to http://www.jsonrpc.org/specification#request_object
    func toJSON() -> String?
}

extension JRPCRequest: JRPCParsable{}

/**
 A client that performs JSONRPC 2.0 requests
 */
@objc public class JRPCClient: NSObject{
    
    /// the http headers to pass along with the JSONRPC request, contains
    /// `Content-Type: application/json` by default
    public var httpHeader: Dictionary<String,String>
    
    /**
     Initializes a new JRPCClient with the passed header fields
     
     - Parameters:
        - header: header fields to pass along with the JSONRPC request, headers are `Content-Type: application/json`  by default
     
     - Returns: a newly initialized JRPCClient
     */
    public init(header: Dictionary<String,String> = ["Content-Type":"application/json"]) {
        self.httpHeader = header
        super.init()
    }
    
    /**
     Performs a JSONRPC request to the specified endpoint.
     
     - Parameters:
        - jrpcRequest: the JSONRPC request to perform, could be a JRPCRequest or any object implementing the JRPCParsable protocol
        - endpointURL: url of the JSONRPC server
        - callback: the callback closure that gets executed when the http operation finishes
     */
    @objc public func performRPC(request jrpcRequest: JRPCParsable, remoteURL endpointURL: URL, responseHandler callback: @escaping (JRPCResponse?, Error?) -> Void ){
        
        let jsonData = jrpcRequest.toJSON()?.data(using: String.Encoding.utf8)
        if jsonData == nil{
            callback(nil,JRPCClientError.unableToParseRequest)
            return
        }
        
        let request = NSMutableURLRequest(url: endpointURL)
        request.httpMethod = "POST"
        
        for headerField in self.httpHeader.keys{
            request.addValue(self.httpHeader[headerField]!, forHTTPHeaderField: headerField)
        }
        
        request.httpBody = jsonData
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (result, urlresponse, error) in
            
            // checking http error
            if error != nil{
                callback(nil, error)
                return
            }
            
            // checking response is parsable
            let rawJson = try? JSONSerialization.jsonObject(with: result!)
            let rawResponseDictionary = rawJson as? [String: Any]
            if rawResponseDictionary == nil{
                callback(nil,JRPCClientError.unableToParseRequest)
                return
            }
            
            // returning parse result
            let parseResult = JRPCClient.parseJRPCResponse(dictionary: rawResponseDictionary!)
            callback(parseResult.response, parseResult.error)
            
        })
        dataTask.resume()
        
    }
    
    // parses a dictionary into a JRPCResponse, returns an error if something goes wrong.
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
            if jrpcErrorParsingResult.error != nil{
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
    
    // parses a dictionary into a JRPCResponseError, returns an error if something goes wrong.
    static func parseJRPCResponseError(dictionary: Dictionary<String,Any>) -> (jrpcError: JRPCResponseError?,error: JRPCClientError?){
        
        guard dictionary["code"] != nil && dictionary["code"] is Int else{
            return (nil, JRPCClientError.unableToParseResponse)
        }
        
        guard dictionary["message"] != nil && dictionary["message"] is String else{
            return (nil, JRPCClientError.unableToParseResponse)
        }
        
        
        if let code = dictionary["code"] as? Int , let message = dictionary["message"] as? String{
            return (JRPCResponseError(code: code , message: message, data: dictionary["data"]),nil)
        }else{
            return (nil, JRPCClientError.unableToParseResponse)
        }
        
    }
}
