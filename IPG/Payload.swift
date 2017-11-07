//
//  Payload.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
//

import Foundation

public protocol PayloadProtocol {
  
  var payload: String? { get }
  var ccPanBin: String? { get }
  var ccPanLast4: String? { get }
  var error: [OttErrorProtocol]? { get }
  
}

public struct Payload: PayloadProtocol {
  public var payload: String?
  public var ccPanBin: String?
  public var ccPanLast4: String?
  public var error: [OttErrorProtocol]?
}
