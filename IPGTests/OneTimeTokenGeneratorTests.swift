//
//  OneTimeTokenGeneratorTests.swift
//  IPG
//
//  Created by AirS CC on 06/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import XCTest
import IPG

class OneTimeTokenGeneratorTests: XCTestCase {
  
  var ott: OneTimeTokenGenerator = OneTimeTokenGenerator("testkey","http://private-ed273e-ipg.apiary-mock.com/token")
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testisValidExpiryDate() {
    XCTAssert(ott.isValidExpiryDate("17","11") == true)
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
  
}
