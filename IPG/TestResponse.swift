//
//  TestResponse.swift
//  IPG
//
//  Created by AirS CC on 04/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import ObjectMapper

class TestResponse: Mappable {
  var origin: String?
  var url: String?
  var headers: Headers?
  
  required init?(map: Map){
    
  }
  
  func mapping(map: Map) {
    url <- map["location"]
    origin <- map["origin"]
    headers <- map["headers"]
  }
}


class Headers: Mappable {
  var accept: String?
  var host: String?
  var userAgent: String?
  
  required init?(map: Map){
    
  }
  
  func mapping(map: Map) {
    accept <- map["accept"]
    host <- map["host"]
    userAgent <- map["User-Agent"]
  }
}
