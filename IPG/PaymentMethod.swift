//
//  PaymentMethod.swift
//  IPG
//
//  Created by AirS CC on 11/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
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

