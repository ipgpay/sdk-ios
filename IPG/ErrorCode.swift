//
//  ErrorCode.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.//

import Foundation

enum ErrorCode: Int , Error {
  case invalidCreditCardNumber = 1
  case invalidCVV = 2
  case invalidExpiryDate = 4
  case invalidInput = 8
  case commsNoResponse = 16
  case commsParseFailure = 32
  case commsServerUnreachable = 64
  case commsUnexpectedResponse = 128
}

/// One time token error protocol.
public protocol OttErrorProtocol {
  var errorCode: Int? { get set }
  var errorMessage: String? { get set }
}
