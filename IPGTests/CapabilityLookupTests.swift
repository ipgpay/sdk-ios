//
//  CapabilityLookupTests.swift
//  IPG
//
//  Created by AirS CC on 12/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import IPG

class CapabilityLookupTests: XCTestCase {
  let testHost = "cl.test.ipg"
  let cl = CapabilityLookup("testkey", "http://cl.test.ipg")
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testgetCapabilities_Success() {
    let tempStub = stub(condition: isHost(self.testHost) && isMethodGET()) { _ in
      let stubPath = OHPathForFile("successresponse.xml", type(of: self))
      return fixture(filePath: stubPath!, headers: ["Content-Type":"text/xml"])
    }
    
    let tempExpectation = expectation(description: "testgetCapabilities")
    cl.getCapabilities { currencies in
      
      XCTAssert(currencies.count == 2)
      XCTAssert(currencies[0].code == "AUD" && currencies[1].code == "USD")
      XCTAssert(currencies[0].payments.count == 2)
      XCTAssert(currencies[0].payments[0].method == "OTT" && currencies[0].payments[1].method == "ApplePay")
      XCTAssert(currencies[1].payments.count == 3)
      XCTAssert(currencies[1].payments[0].method == "OTT"
        && currencies[1].payments[1].method == "ApplePay" && currencies[1].payments[2].method == "SomeOtherMethod")
      
      tempExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
    
    OHHTTPStubs.removeStub(tempStub)
  }
  
  func testgetCapabilities_NotFound() {
    let tempStub = stub(condition: isHost(self.testHost) && isMethodGET()) { _ in
      let obj = [""]
      return OHHTTPStubsResponse(jsonObject: obj, statusCode: 404, headers: ["Content-Type":"text/xml"])
    }
    
    let tempExpectation = expectation(description: "testgetCapabilities_NotFound")
    cl.getCapabilities { currencies in
      
      XCTAssert(currencies.count == 0)
      
      tempExpectation.fulfill()
    }
    waitForExpectations(timeout: 5)
    
    OHHTTPStubs.removeStub(tempStub)
  }
}
