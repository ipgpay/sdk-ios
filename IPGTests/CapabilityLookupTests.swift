//
//  CapabilityLookupTests.swift
//  IPG
//
//  Created by AirS CC on 12/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import XCTest
@testable import IPG

class CapabilityLookupTests: XCTestCase {
  let cl = CapabilityLookup("key", "http://private-ed273e-ipg.apiary-mock.com/capability/")
  let clNotFound = CapabilityLookup("key", "http://private-ed273e-ipg.apiary-mock.com/capability/notfound")
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testgetCapabilities_Success() {
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
    waitForExpectations(timeout: 5)
  }
  
  func testgetCapabilities_NotFound() {
    let tempExpectation = expectation(description: "testgetCapabilities_NotFound")
    clNotFound.getCapabilities { currencies in
      
      XCTAssert(currencies.count == 0)
      
      tempExpectation.fulfill()
    }
    waitForExpectations(timeout: 5)
  }
}
