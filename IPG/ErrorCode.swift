//
//  ErrorCode.swift
//  IPG
//
//  Created by AirS CC on 05/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation

enum ErrorCode {
  static let invalidCreditCardNumber = 1
  static let invalidCVV = 2
  static let invalidExpiryDate = 4
  static let invalidInput = 8
  static let commsNoResponse = 16
  static let commsParseFailure = 32
  static let commsServerUnreachable = 64
  static let commsUnexpectedResponse = 128
}

public class OTTError: Error {
  
  init(_ errorCode: ErrorCode, _ errorMessage: String) {
    self.errorCode = errorCode
    self.errorMessage = errorMessage
  }
  
  var errorCode: ErrorCode
  var errorMessage: String
  
}
