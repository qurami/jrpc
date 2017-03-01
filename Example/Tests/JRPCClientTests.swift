//
//  JRPCClientTests.swift
//  jrpc
//
//  Created by Marco Musella on 27/02/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import jrpc

class JRPCClientTests: XCTestCase {
    
    let mockJRPCRequest = JRPCRequest(id: "1010", method: "mockMethod", namedParams: ["mock":"param"])
   
    let mockJRPCResponse = "{\"jsonrpc\":\"2.0\", \"id\":\"1010\",\"result\":{\"mock\":\"value\"},\"error\": null}"
    
    let mockEndpointURL = URL(string:"http://www.mockendpoint.com")
    
    
    override func setUp() {
        super.setUp()
        stubSuccessfulRequest()
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    
    func stubSuccessfulRequest(){
        
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            if request.url == self.mockEndpointURL && request.httpMethod == "POST" && request.allHTTPHeaderFields?["Content-Type"] == "application/json"{
                if let httpBody = (request as NSURLRequest).ohhttpStubs_HTTPBody(){
                    let json = String(data: httpBody, encoding: String.Encoding.utf8)
                    return json == self.mockJRPCRequest.toJSON()!
                }
            }
            
            return false
        }) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: self.mockJRPCResponse.data(using: String.Encoding.utf8)!, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

    }
    
    
    func testThatRequestSendsHeadersAndBodyWithRightHTTPMethodToPassedEndpoint(){
        
        let sut = JRPCClient()
        let endpointExp = expectation(description: "endpoint test passed")
        
        sut.perform(request: mockJRPCRequest, withURL: self.mockEndpointURL!) { (jrpcresponse, error) in
            if error != nil {
                XCTFail("received unexpected error:\n \(error)")
            }
            endpointExp.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            if error != nil{
                XCTFail(error!.localizedDescription)
            }
        }
    }
    
    func testThatRequestSendsCustomizedHeaders(){
        
        let customHeader = ["custom-field1":"custom-value1","custom-field2":"custom-value2"]
        
        OHHTTPStubs.removeAllStubs()
        OHHTTPStubs.stubRequests(passingTest: { (request) -> Bool in
            let passedHeader = request.allHTTPHeaderFields
            for key in customHeader.keys{
                if passedHeader?[key] != customHeader[key]{
                    return false
                }
            }
            return true
        }) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: self.mockJRPCResponse.data(using: String.Encoding.utf8)!, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let sut = JRPCClient(header: customHeader)
        let endpointExp = expectation(description: "endpoint test passed")
        
        sut.perform(request: mockJRPCRequest, withURL: self.mockEndpointURL!) { (jrpcresponse, error) in
            if error != nil {
                XCTFail("received unexpected error:\n \(error)")
            }
            endpointExp.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            if error != nil{
                XCTFail(error!.localizedDescription)
            }
        }
    }
    
    func testThatExpectedJRPCResponseIsReturned(){
        
        let sut = JRPCClient()
        let responseExp = expectation(description: "expected response received")
        
        sut.perform(request: mockJRPCRequest, withURL: self.mockEndpointURL!) { (jrpcresponse, error) in
            
            if error != nil {
                XCTFail("received unexpected error:\n \(error)")
            }
            
            if let resp = jrpcresponse,
                resp.id != "1010",
                (resp.result as? Dictionary<String,String>)?["mock"] != "value" {
                XCTFail("received response is different than expected: \(resp)")
            }
            
            responseExp.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            if error != nil{
                XCTFail(error!.localizedDescription)
            }
        }
    }
    
    func testThatRequestFailsWhenJsonParsingOfJRPCRequestFails(){
        let erroredReq = ErroredJRPCRequest()
        let sut = JRPCClient()
        let parseExp = expectation(description: "json parsing error received")
        
        sut.perform(request: erroredReq, withURL: self.mockEndpointURL!) { (response, error) in
            
            if let jrpcError = error as? JRPCClientError{
                if jrpcError != JRPCClientError.unableToParseRequest{
                    XCTFail("received jrpc client error is different than expected \(jrpcError)")
                }
            } else{
                XCTFail("received error is different than expected \(error)")
            }
            
            parseExp.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            if error != nil{
                XCTFail(error!.localizedDescription)
            }
        }
    }
    
    func testThatErrorIsReturnedWhenDatataskFails(){
        let errorExp = expectation(description: "datatask error received")
        let sut = JRPCClient()
        
        sut.perform(request: self.mockJRPCRequest, withURL: URL(string:"mockerroreddatatask.com")!, responseHandler: { (response, error) in
            if let err = error as? MockError, err != MockError.mockHTTPError{
              XCTFail("expected error not received")
            }
            errorExp.fulfill()
        })
        
        
        self.waitForExpectations(timeout: 10) { (error) in
            if error != nil{
                XCTFail(error!.localizedDescription)
            }
        }
    }
    
}

enum MockError: Error{
    case mockHTTPError
}

struct ErroredJRPCRequest: JRPCParsable {
    func toJSON() -> String?{
        return nil
    }
}

