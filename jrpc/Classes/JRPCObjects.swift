//
//  JRPCObjects.swift
//  Pods
//
//  Created by Marco Musella on 23/02/2017.
//
//

import Foundation

public enum JRPCRequestError: Error{
    case missingID
    case missingMethod
    case badParameters
}

public struct JRPCRequest{
    
    public let id: String
    public let jsonRPC = "2.0"
    public let method: String
    public let params: Any?
    
    public init(id:String, method: String, params: Any?) throws {
        guard !id.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty else{
            throw JRPCRequestError.missingID
        }
        
        guard !method.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty else{
            throw JRPCRequestError.missingMethod
        }
        
        guard JRPCRequest.parametersAreValid(params) else{
            throw JRPCRequestError.badParameters
        }
        
        
        self.id = id
        self.method = method
        self.params = params
    }
    
    public func toJson() throws -> String{
        
        var jsonData: Data
        let raw = ["jsonrpc":"2.0", "id": self.id, "method": self.method, "params": self.params]
        jsonData = try JSONSerialization.data(withJSONObject: raw, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        return String(data: jsonData, encoding: String.Encoding.utf8)!
    }
    
    static func parametersAreValid(_ params: Any?) -> Bool{
        
        switch params {
        case nil:
            return true
        case let p as Array<Any>:
            return true
        case let p as Dictionary<String, Any>:
            return true
        default:
            return false
        }
        

    }
}

struct JRPCResponse{

}
