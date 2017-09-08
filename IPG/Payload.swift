//
//  Payload.swift
//  IPG
//
//  Created by AirS CC on 08/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
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
