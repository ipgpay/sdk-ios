//
//  ProductTableViewCell.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
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
