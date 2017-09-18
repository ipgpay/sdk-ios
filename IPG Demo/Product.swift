//
//  Product.swift
//  IPG
//
//  Created by AirS CC on 14/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
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
}
