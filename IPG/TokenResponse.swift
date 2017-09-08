//
//  TokenResponse.swift
//  IPG
//
//  Created by AirS CC on 07/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import ObjectMapper

class TokenResponse: Mappable {
  
  var token: String?
  var errors: [OttError]?
  
  required init? (map: Map) {
    
  }
  
  func mapping(map: Map) {
    token <- map["token"]
    errors <- map["error"]
  }
}

class OttError: OttErrorProtocol, Mappable {
  
  var errorCode: Int?
  var errorMessage: String?
  
  required init? (map: Map) {
    
  }
  
  init(_ errorCode: Int, _ errorMessage: String) {
    self.errorCode = errorCode
    self.errorMessage = errorMessage
  }
  
  func mapping(map: Map) {
    
    let transform = TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
      return Int(value!)
    }, toJSON: { (value: Int?) -> String? in
      if let value = value {
        return String(value)
      }
      return nil
    })
    
    errorMessage <- map["errorMessage"]
    errorCode <- map["errorCode"]
    if errorCode == nil {
      errorCode <- (map["errorCode"], transform)
    }
  }
}

