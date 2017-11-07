//
//  Regex.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
//

import Foundation

public class Regex {
  public init() {
    
  }
  public func test(for pattern: String, in text: String) -> Bool {
    do {
      let regex = try NSRegularExpression(pattern: pattern)
      let nsString = text as NSString
      let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
      return results.count > 0
    }
    catch let error {
      debugPrint("invalid regex: \(error.localizedDescription)")
      return false
    }
  }
}
