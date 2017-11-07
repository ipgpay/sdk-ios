//
//  PaymentMethod.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
//

import Foundation

public enum Method {
  case OTT
  case ApplePay
  case AndroidPay
}

public enum Type {
  case Amex
  case MasterCard
  case Visa
  case UnionPay
}

public struct Currency {
  public var code: String = ""
  public var payments: [Payment] = [Payment]()
}

public struct Payment {
  public var method: String = ""
  public var types: [String] = [String]()
}

