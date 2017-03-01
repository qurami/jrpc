//
//  JRPCObjects.swift
//  Pods
//
//  Created by Marco Musella on 23/02/2017.
//  Copyright © 2017 Quami s.r.l. All rights reserved.
//

import Foundation



/** A JSON RPC 2.0 request object, for further informations refer to http://www.jsonrpc.org/specification#request_object
 
    Since JSON RPC allows two different methods for passing parameters, named or positional, 
    this exposes a generic type Any params attribute.
*/
@objc public class JRPCRequest: NSObject{

    /// the ID of the request object
    public let ID: String
    /// the remote method to call on the JSONRPC server
    public let method: String
    /// the parameters for the remote method
    public let params: Any?
    
    
    /**
     Initializes a new JRPCRequest object, using named parameters as
     parameters passing method.
     
     - Parameters:
        - ID: the id of the JSONRPC request
        - method: the remote method to call
        - params: the dictionary or array of named parameters, depending on the chosen param input method
     
     - Returns: a new JRPCRequest object with named parameters.
     */
    public init(ID:String, method: String, params: Any?) {
        assert(!ID.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        assert(!method.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        
        self.ID = ID
        self.method = method
        self.params = params
        super.init()
    }
    
    /// Returns a JSON representation of the JRPCRequest, returns nil if the JSON encoding 
    /// fails.
    public func toJSON() -> String?{
        
        var jsonData: Data
        
        let raw = ["jsonrpc":"2.0", "id": self.ID, "method": self.method, "params":  self.params]
        do{
            jsonData = try JSONSerialization.data(withJSONObject: raw, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch{
            return nil
        }
        
        
        return String(data: jsonData, encoding: String.Encoding.utf8)
    }
}

/// A JSON RPC 2.0 error object
/// for further informations refer to http://www.jsonrpc.org/specification#error_object
@objc public class JRPCResponseError: NSObject{
    
    /// the error code of the JSONRPC error object
    public let code: Int
    /// the error message
    public let message: String
    /// a payload attached to the error
    public let data: Any?
    
    /** Initializes and returns a JRPCResponseError
     
     - Parameters:
        - code: the error code
        - message: the error message
        - data: a custom payload to attach to the error
    */
    public init(code: Int, message: String, data: Any?) {
        self.code = code
        self.message = message
        self.data = data
        super.init()
    }
}

/* A JSON RPC 2.0 response object
 for further informations refer to http://www.jsonrpc.org/specification#response_object

 As the specification states, when a response has errors the id and the result fields are null
 and the error field contains informations about the error.
 */
@objc public class JRPCResponse: NSObject{
    /// the ID of the JSONRPC response
    public let ID: String?
    /// the result of the remote method
    public let result: Any?
    /// the error
    public let error: JRPCResponseError?
    
    /** Initializes and returns a JRPCResponseError
     
     - Parameters:
        - ID: the id of the response, nil if the response is errored
        - result: the message of the remote procedure, nil if the response is errored
        - error: the error of the remote procedure, nil if the reponse is successful
     */
    public init(ID: String?, result: Any?, error: JRPCResponseError?){
        self.ID = ID
        self.result = result
        self.error = error
        super.init()
    }
}
