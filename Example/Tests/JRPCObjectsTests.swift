//
//  JRPCObjectsTests.swift
//  jrpc
//
//  Created by Marco Musella on 23/02/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import jrpc

class JRPCObjectsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testThatJRPCRequestIsEncodedToJsonWithOrderedParameters(){
        
        let sut = JRPCRequest.init(id: "1", method: "mock.Method", orderedParams: ["1","2","3"])
        let encoded = sut.toJSON()
        
        if let jsonString = encoded{
            
            if let data = jsonString.data(using: String.Encoding.utf8){
                
                if let raw = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String,Any>{
                    
                    XCTAssertTrue(raw?["id"] as! String == "1")
                    XCTAssertTrue(raw?["method"] as! String == "mock.Method")
                    XCTAssertTrue(raw?["jsonrpc"] as! String == "2.0")
                    XCTAssertTrue(raw?["params"] as! Array<String> == ["1","2","3"])

                    
                } else{
                    XCTFail("unexpected json parsing error")
                }
                
            } else{
                XCTFail("unexpected data parsing error")
            }
            
            
        } else{
            XCTFail("JRPCRequest object not encoded as expected")
        }
    }
    
    func testThatJRPCRequestIsEncodedToJsonWithNamedParameters(){
        
        let sut = JRPCRequest.init(id: "1", method: "mock.Method", namedParams: ["first": "1","second": 2, "third": true])
        
        let encoded = sut.toJSON()
        
        if let jsonString = encoded{
            
            if let data = jsonString.data(using: String.Encoding.utf8){
                
                if let raw = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String,Any>{
                    
                    XCTAssertTrue(raw?["id"] as? String == "1")
                    XCTAssertTrue(raw?["method"] as? String == "mock.Method")
                    XCTAssertTrue(raw?["jsonrpc"] as? String == "2.0")

                    
                    if let params = raw?["params"] as? Dictionary<String,Any>{
                        XCTAssertTrue(params["first"] as? String == "1")
                        XCTAssertTrue(params["second"] as? Int == 2)
                        XCTAssertTrue(params["third"] as? Bool == true)
                    } else{
                        XCTFail("unable to parse params to dictionary")
                    }

                    
                } else{
                    XCTFail("unexpected json parsing error")
                }
                
            } else{
                XCTFail("unexpected data parsing error")
            }
            
            
        } else{
            XCTFail("JRPCRequest object not encoded as expected")
        }
    }
    
    
    
}
