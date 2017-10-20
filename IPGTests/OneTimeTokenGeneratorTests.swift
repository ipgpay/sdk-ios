//
//  OneTimeTokenGeneratorTests.swift
//  IPG
//
//  Created by AirS CC on 06/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import IPG

class OneTimeTokenGeneratorTests: XCTestCase {
  
  let testHost = "ott.test.ipg"
  let optionsSuccess = Options(ccPan: "4012888888881881", ccCvv: "318", ccExpyear: "29", ccExpmonth: "09")
  let ott = OneTimeTokenGenerator("testkey", "http://ott.test.ipg")
  
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
    let date = Date()
    let calendar = Calendar.current
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date) - 2000
    
    let dateNext = calendar.date(byAdding: .month, value: 1, to: date)!
    let monthNext = calendar.component(.month, from: dateNext)
    let yearNext = calendar.component(.year, from: dateNext) - 2000
    
    XCTAssert(ott.isValidExpiryDate(String(year), String(format: "%02x", month)) == true)
    XCTAssert(ott.isValidExpiryDate("37","11") == true)
    XCTAssert(ott.isValidExpiryDate("99","01") == true)
    
    XCTAssert(ott.isValidExpiryDate(String(yearNext), String(format: "%02x", monthNext)) == false)
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
    
    let tempStub = stub(condition: isHost(self.testHost) && isMethodPOST()) { _ in
      let obj = ["token":"test token"]
      return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: ["Content-Type":"application/json"])
    }
    
    let tempExpectation = expectation(description: "testgetPayload_Success")
    ott.getPayload(optionsSuccess) { payload in
      XCTAssert(payload.payload?.range(of: "1test token") != nil)
      XCTAssert(payload.error == nil)
      XCTAssert(payload.ccPanBin == "401288")
      XCTAssert(payload.ccPanLast4 == "1881")
      tempExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
    
    OHHTTPStubs.removeStub(tempStub)
  }
  
  func testgetPayload_Error_commsNoResponse() {
    let tempStub = stub(condition: isHost(self.testHost) && isMethodPOST()) { _ in
      let stubPath = OHPathForFile("emptyresponse.json", type(of: self))
      return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
    }
    
    let tempExpectation = expectation(description: "testgetPayload_Error_commsNoResponse")
    ott.getPayload(optionsSuccess) { payload in
      XCTAssert(payload.payload == nil)
      XCTAssert(payload.ccPanBin == nil)
      XCTAssert(payload.ccPanLast4 == nil)
      XCTAssert(payload.error != nil)
      
      let exist = self.containError(payload.error, ErrorCode.commsNoResponse.rawValue)
      XCTAssert(exist)
      
      tempExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
    
    OHHTTPStubs.removeStub(tempStub)
  }
  
  func testgetPayload_Error_commsServerUnreachable () {
    let tempStub = stub(condition: isHost(self.testHost) && isMethodPOST()) { _ in
      let obj = [""]
      return OHHTTPStubsResponse(jsonObject: obj, statusCode: 404, headers: nil)
    }
    
    let tempExpectation = expectation(description: "testgetPayload_Error_commsServerUnreachable")
    ott.getPayload(optionsSuccess) { payload in
      XCTAssert(payload.payload == nil)
      XCTAssert(payload.ccPanBin == nil)
      XCTAssert(payload.ccPanLast4 == nil)
      XCTAssert(payload.error != nil)
      
      let exist = self.containError(payload.error, ErrorCode.commsServerUnreachable.rawValue)
      XCTAssert(exist)
      
      tempExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
    
    OHHTTPStubs.removeStub(tempStub)
  }
  
  func testgetPayload_Error() {
    let tempStub = stub(condition: isHost(self.testHost) && isMethodPOST()) { _ in
      let obj = ["error": [["errorCode": "1", "errorMessage": "message 1"],["errorCode": "2", "errorMessage": "message 2"], ["errorCode": "3", "errorMessage": "message 3"], ["errorCode": "4", "errorMessage": "message 4"]]]
      
      return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: ["Content-Type":"application/json"])
    }
    
    let tempExpectation = expectation(description: "testgetPayload_Error")
    ott.getPayload(optionsSuccess) { payload in
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
    waitForExpectations(timeout: 1)
    
    OHHTTPStubs.removeStub(tempStub)
  }
}
