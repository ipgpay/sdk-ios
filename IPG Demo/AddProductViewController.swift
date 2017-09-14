//
//  AddProductViewController.swift
//  IPG
//
//  Created by AirS CC on 14/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import UIKit

class AddProuctViewController: UIViewController, UITextFieldDelegate {
  
  var delegate: AddProductDelegate!
  var isFirst = true
  var rangePoint: NSRange!
  
  @IBOutlet weak var quantityStepper: UIStepper!
  @IBOutlet weak var quantityLabel: UILabel!
  @IBOutlet weak var priceText: UITextField!
  @IBOutlet weak var prodNameText: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.quantityLabel.text = "1"
    self.priceText.delegate = self
  }
  
  @IBAction func saveChanges(_ sender: Any) {

    if self.prodNameText.text == nil || self.prodNameText.text == "" {
      let alertController = UIAlertController(title: "Validate Info", message: "Product name should not be empty!", preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    } else {
      self.delegate?.addProduct(productName: self.prodNameText.text!, quantity: Int(self.quantityStepper.value), price: Int(self.priceText.text!)!)
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func quantityChange(_ sender: Any) {
    self.quantityLabel.text = String(Int(quantityStepper.value))
  }
  
  @IBAction func close(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
    let components = string.components(separatedBy: inverseSet)
    let filtered = components.joined(separator: "")
    return string == filtered
  }
  
}
