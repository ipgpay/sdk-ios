//
//  Product.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
//

import UIKit


class Product {
  var name: String
  var qty: Int
  var price: Double
  
  init(name: String, qty: Int, price: Double) {
    self.name = name
    self.qty = qty
    self.price = price
  }
  
  func toDict() -> [String: String] {
    return ["name": name, "qty": String(qty), "price": String(price)]
  }
}
