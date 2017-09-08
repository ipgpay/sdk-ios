//
//  Options.swift
//  IPG
//
//  Created by AirS CC on 08/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation

public protocol OptionsProtocol {
  var ccPan: String { get }
  var ccCvv: String { get }
  var ccExpyear: String { get }
  var ccExpmonth: String { get }
}

public struct Options: OptionsProtocol {
  
  public init(ccPan: String, ccCvv: String, ccExpyear: String, ccExpmonth: String) {
    self.ccPan = ccPan
    self.ccCvv = ccCvv
    self.ccExpyear = ccExpyear
    self.ccExpmonth = ccExpmonth
  }
  
  public var ccPan: String
  public var ccCvv: String
  public var ccExpyear: String
  public var ccExpmonth: String
}
