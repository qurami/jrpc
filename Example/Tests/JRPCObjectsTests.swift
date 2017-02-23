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
        let sut = JRPCRequest.init()
    }
    
}
