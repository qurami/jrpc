//
//  JRPCObjects.swift
//  Pods
//
//  Created by Marco Musella on 23/02/2017.
//
//

import Foundation



/// A protocol to used to ensure that some given data
/// is JSON encodable when passed into an array or a dictionary
public protocol JSONEncodable{}

extension String: JSONEncodable{}
extension Int: JSONEncodable{}
extension Double: JSONEncodable{}
extension Bool: JSONEncodable{}


/** A JSON RPC 2.0 request object, for further informations refer to http://www.jsonrpc.org/specification#request_object
 
    Since JSON RPC allows two different methods for passing parameters, named or positional, 
    this struct exposes two different initializers and two attributes, 
    specifically `namedParams` and `orderedParams`.
    The two attributes are optional and can't both hold values at the same time.
*/
 public struct JRPCRequest{

    /// the ID of the request object
    public let id: String
    /// the remote method to call on the JSONRPC server
    public let method: String
    /// the list of ordered parameters for the remote method
    public let orderedParams: Array<JSONEncodable>?
    /// the dictionary of named parameters for the remote method
    public let namedParams: Dictionary<String,JSONEncodable>?
    
    
    /**
     Initializes a new JRPCRequest object, using named parameters as
     parameters passing method.
     
     - Parameters:
        - id: the id of the JSONRPC request
        - method: the remote method to call
        - namedParams: the dictionary of named parameters for the remote method
     
     - Returns: a new JRPCRequest object with named parameters.
     */
    public init(id:String, method: String, namedParams: Dictionary<String,JSONEncodable>) {
        assert(!id.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        assert(!method.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        
        self.id = id
        self.method = method
        self.namedParams = namedParams
        self.orderedParams = nil
    }
    
    /**
     Initializes a new JRPCRequest object, using ordered parameters as
     parameters passing method.
     
     - Parameters:
     - id: the id of the JSONRPC request
     - method: the remote method to call
     - orderedParams: the list of ordered parameters for the remote method
     
     - Returns: a new JRPCRequest object with ordered parameters.
     */
    public init(id:String, method: String, orderedParams: Array<JSONEncodable>){
        assert(!id.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        assert(!method.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        
        self.id = id
        self.method = method
        self.orderedParams = orderedParams
        self.namedParams = nil
    }
    
    /// Returns a JSON representation of the JRPCRequest, returns nil if the JSON encoding 
    /// fails.
    public func toJSON() -> String?{
        
        var jsonData: Data
        var params: Any
        
        if let ordered = self.orderedParams{
            params = ordered
        } else {
            params = self.namedParams!
        }
        
        
        let raw = ["jsonrpc":"2.0", "id": self.id, "method": self.method, "params":  params]
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
public struct JRPCResponseError{
    
    /// the error code of the JSONRPC error object
    public let code: Int
    /// the error message
    public let message: String
    /// a payload attached to the error
    public let data: Any?
}

/* A JSON RPC 2.0 response object
 for further informations refer to http://www.jsonrpc.org/specification#response_object

 As the specification states, when a response has errors the id and the result fields are null
 and the error field contains informations about the error.
 */
public struct JRPCResponse{
    /// the ID of the JSONRPC response
    public let id: String?
    /// the result of the remote method
    public let result: Any?
    /// the error
    public let error: JRPCResponseError?
}
