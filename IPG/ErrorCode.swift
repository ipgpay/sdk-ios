//
//  ErrorCode.swift
//  IPG
//
//  Created by AirS CC on 05/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

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
