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
    
    func testThatErrorIsReturnedWhenInitializingRequestWithoutID(){
        
        do {
            _ = try JRPCRequest.init(id: " ", method: "", params: nil)
            XCTFail("error should have been catched")
        } catch let err as JRPCRequestError {
            if err != JRPCRequestError.missingID{
                XCTFail("catched error is not expected missingID error")
            }
        } catch{
            XCTFail("catched unexpected exception")
        }
    }
    
    func testThatErrorIsReturnedWhenInitializingRequestWithoutMethod(){
        
        do {
            _ = try JRPCRequest.init(id: "mockID", method: "", params: nil)
            XCTFail("error should have been catched")
        } catch let err as JRPCRequestError {
            if err != JRPCRequestError.missingMethod{
                XCTFail("catched error is not expected missingMethod error")
            }
        } catch{
            XCTFail("catched unexpected exception")
        }
    }
    
    func testThatErrorIsReturnedWhenParamsAreNotValid(){
        
        let wrongParam = URL.init(string: "https://google.com")
        
        do {
            _ = try JRPCRequest.init(id: "mockID", method: "mockMethod", params: wrongParam)
            XCTFail("error should have been catched")
        } catch let err as JRPCRequestError {
            if err != JRPCRequestError.badParameters{
                XCTFail("catched error is not expected badParameters error")
            }
        } catch{
            XCTFail("catched unexpected exception")
        }
    }
    
    func testThatJRPCRequestIsInitializedCorrectly(){
        let sut = try! JRPCRequest.init(id: "1", method: "mock.Method", params: ["1","2","3"])
        XCTAssertTrue( sut.id == "1" )
    }
    
    func testThatJRPCRequestIsEncodedToJsonWithOrderedParameters(){
        
        let sut = try! JRPCRequest.init(id: "1", method: "mock.Method", params: ["1","2","3"])
        let json = try! sut.toJson()
        let raw = try! JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,Any>
        
        XCTAssertTrue(raw["id"] as! String == "1")
        XCTAssertTrue(raw["method"] as! String == "mock.Method")
        XCTAssertTrue(raw["jsonrpc"] as! String == "2.0")
        XCTAssertTrue(raw["params"] as! Array<String> == ["1","2","3"])
        
    }
    
    func testThatJRPCRequestIsEncodedToJsonWithNamedParameters(){
        
        let sut = try! JRPCRequest.init(id: "1", method: "mock.Method", params: ["first":"1","second": "2","third": 3])
        let json = try! sut.toJson()
        let raw = try! JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String,Any>
        
        XCTAssertTrue(raw["params"] is Dictionary<String,Any>)
        
        let params = raw["params"] as! Dictionary<String,Any>
        
        XCTAssertTrue(params["first"] as! String == "1")
        XCTAssertTrue(params["second"] as! String == "2")
        XCTAssertTrue(params["third"] as! Int == 3)
        
    }
    
    
}
