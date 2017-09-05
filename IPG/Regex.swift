//
//  Regex.swift
//  IPG
//
//  Created by AirS CC on 05/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation

class Regex {
  func test(for pattern: String, in text: String) -> Bool {
    do {
      let regex = try NSRegularExpression(pattern: pattern)
      let nsString = text as NSString
      let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
      return results.count > 0
    }
    catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return false
    }
  }
}
