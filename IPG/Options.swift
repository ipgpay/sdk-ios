//
//  Options.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.//

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
