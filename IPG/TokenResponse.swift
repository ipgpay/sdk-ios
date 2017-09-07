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
  var errors: [ErrorResponse]?
  
  required init? (map: Map) {
    
  }
  
  func mapping(map: Map) {
    token <- map["token"]
    errors <- map["error"]
  }
}

class ErrorResponse: Mappable {
  
  var errorCode: String?
  var errorMessage: String?
  
  required init? (map: Map) {
    
  }
  
  func mapping(map: Map) {
    errorCode <- map["errorCode"]
    errorMessage <- map["errorMessage"]
  }
}

