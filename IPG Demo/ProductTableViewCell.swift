//
//  ProductTableViewCell.swift
//  IPG
//
//  Created by AirS CC on 14/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
  //MARK: Properties
  
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var prodLabel: UILabel!
  @IBOutlet weak var qtyLabel: UILabel!
  override func awakeFromNib() {
    
    super.awakeFromNib()
    // Initialization code
  }
}
