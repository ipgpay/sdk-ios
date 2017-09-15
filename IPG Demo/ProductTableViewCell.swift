//
//  ProductTableViewCell.swift
//  IPG
//
//  Created by AirS CC on 14/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
  
  @IBOutlet weak var descriptionLabel: UILabel!
  //MARK: Properties
  
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var prodLabel: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
}
