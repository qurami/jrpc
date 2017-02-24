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

public protocol JSONEncodable{}

extension String: JSONEncodable{}
extension Int: JSONEncodable{}
extension Double: JSONEncodable{}
extension Bool: JSONEncodable{}




public struct JRPCRequest{

    public let id: String
    public let method: String
    public let orderedParams: Array<JSONEncodable>?
    public let namedParams: Dictionary<String,JSONEncodable>?
    
    
    public init(id:String, method: String, namedParams: Dictionary<String,JSONEncodable>) {
        assert(!id.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        assert(!method.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        
        self.id = id
        self.method = method
        self.namedParams = namedParams
        self.orderedParams = nil
    }
    
    public init(id:String, method: String, orderedParams: Array<JSONEncodable>){
        assert(!id.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        assert(!method.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)
        
        self.id = id
        self.method = method
        self.orderedParams = orderedParams
        self.namedParams = nil
    }
    
    public func toJson() -> String?{
        
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

public struct JRPCResponseError{
    public let code: Int
    public let message: String
    public let data: Any?
}

public struct JRPCResponse{
    public let id: String?
    public let result: Any?
    public let error: JRPCResponseError?
    
}
