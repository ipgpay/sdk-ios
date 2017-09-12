//
//  OneTimeTokenGeneratorTests.swift
//  IPG
//
//  Created by AirS CC on 06/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import XCTest
@testable import IPG

class OneTimeTokenGeneratorTests: XCTestCase {
  
  let ott = OneTimeTokenGenerator("testkey","http://private-ed273e-ipg.apiary-mock.com/tokensuccess")
  
  let ottError = OneTimeTokenGenerator("testkey","http://private-ed273e-ipg.apiary-mock.com/tokenerror")
  
  let ottNotFound = OneTimeTokenGenerator("testkey","http://private-ed273e-ipg.apiary-mock.com/token404")
  
  let ottEmpty = OneTimeTokenGenerator("testkey","http://private-ed273e-ipg.apiary-mock.com/tokenempty")
  
  let optionsSuccess = Options(ccPan: "4012888888881881", ccCvv: "318", ccExpyear: "29", ccExpmonth: "09")
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func containError(_ errors: [OttErrorProtocol]?, _ code: Int, _ message: String = "") -> Bool {
    if let myErrors = errors {
      return myErrors.contains(where: { (item) -> Bool in
        if message.isEmpty {
          return item.errorCode == code
        } else {
          return item.errorCode == code && item.errorMessage == message
        }
        
      })
    } else {
      return false
    }
  }
  
  func testisValidExpiryDate() {
    XCTAssert(ott.isValidExpiryDate("37","11") == true)
    XCTAssert(ott.isValidExpiryDate("99","01") == true)
    
    XCTAssert(ott.isValidExpiryDate("9999","12") == false)
    XCTAssert(ott.isValidExpiryDate("2017","08") == false)
    XCTAssert(ott.isValidExpiryDate("ab","c") == false)
    XCTAssert(ott.isValidExpiryDate("abcde","8") == false)
    XCTAssert(ott.isValidExpiryDate("","") == false)
    XCTAssert(ott.isValidExpiryDate("17","8") == false)
  }
  
  func testisValidLuhn() {
    XCTAssert(ott.isValidLuhn("378734493671000")  == true)  //american express
    XCTAssert(ott.isValidLuhn("6011000990139424")  == true) //discover
    XCTAssert(ott.isValidLuhn("3566002020360505")  == true) //jcb
    XCTAssert(ott.isValidLuhn("5105105105105100")  == true) //mastercard
    XCTAssert(ott.isValidLuhn("4012888888881881")  == true) //visa
  }
  
  func testgetPayload_Success() {
    let tempExpectation = expectation(description: "testgetPayload_Success")
    
    ott.getPayload(optionsSuccess) { payload in
      XCTAssert(payload.payload?.range(of: "1test token") != nil)
      XCTAssert(payload.error == nil)
      XCTAssert(payload.ccPanBin == "401288")
      XCTAssert(payload.ccPanLast4 == "1881")
      tempExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 5)
  }
  
  func testgetPayload_Error_commsNoResponse() {
    let tempExpectation = expectation(description: "testgetPayload_Error_commsNoResponse")
    
    ottEmpty.getPayload(optionsSuccess) { payload in
      XCTAssert(payload.payload == nil)
      XCTAssert(payload.ccPanBin == nil)
      XCTAssert(payload.ccPanLast4 == nil)
      XCTAssert(payload.error != nil)

      let exist = self.containError(payload.error, ErrorCode.commsNoResponse.rawValue)
      XCTAssert(exist)

      tempExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 5)
  }
  
  func testgetPayload_Error_commsServerUnreachable () {
    let tempExpectation = expectation(description: "testgetPayload_Error_commsServerUnreachable")
    
    ottNotFound.getPayload(optionsSuccess) { payload in
      XCTAssert(payload.payload == nil)
      XCTAssert(payload.ccPanBin == nil)
      XCTAssert(payload.ccPanLast4 == nil)
      XCTAssert(payload.error != nil)
      
      let exist = self.containError(payload.error, ErrorCode.commsServerUnreachable.rawValue)
      XCTAssert(exist)
      
      tempExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 10)
  }
  
  func testgetPayload_Error() {
    let tempExpectation = expectation(description: "testgetPayload_Error")
    
    ottError.getPayload(optionsSuccess) { payload in
      XCTAssert(payload.payload == nil)
      XCTAssert(payload.ccPanBin == nil)
      XCTAssert(payload.ccPanLast4 == nil)
      XCTAssert(payload.error != nil)
      
      XCTAssert(self.containError(payload.error, 1, "message 1"))
      XCTAssert(self.containError(payload.error, 2, "message 2"))
      XCTAssert(self.containError(payload.error, 3, "message 3"))
      XCTAssert(self.containError(payload.error, 4, "message 4"))
      
      tempExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 5)
  }
  
  
}
