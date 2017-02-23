//
//  JRPCObjects.swift
//  Pods
//
//  Created by Marco Musella on 23/02/2017.
//
//

import Foundation

enum JRPCRequestError: Error{
    case missingID
    case missingMethod
    case badParameters
}

struct JRPCRequest{
    let id: String
    let jsonRPC = "2.0"
    let method: String
    let params: Any?
    
    init(id:String, method: String, params: Any?) throws {
        guard !id.isEmpty else{
            throw JRPCRequestError.missingID
        }
        guard !method.isEmpty else{
            throw JRPCRequestError.missingMethod
        }
        
        self.id = id
        self.method = method
        self.params = params
    }
}

struct JRPCResponse{

}
