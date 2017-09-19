//
//  ViewController.swift
//  IPG Demo
//
//  Created by AirS CC on 12/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import UIKit
import IPG

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
  var cartList: [Product] = [Product]()
  var pickerDataSource = [
    ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"],
    ["2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027"]]
  
  @IBOutlet weak var addQtyText: UITextField!
  @IBOutlet weak var addPriceText: UITextField!
  @IBOutlet weak var addNameText: UITextField!
  
  @IBOutlet weak var payBtn: UIButton!
  @IBOutlet weak var cartTableView: UITableView!
  @IBOutlet weak var totalLabel: UILabel!
  
  @IBOutlet weak var expDatePickerView: UIPickerView!
  
  @IBAction func addProductAction(_ sender: Any) {
    
    var validateMessage = "";
    if self.addNameText.text == nil || self.addNameText.text == "" {
      validateMessage += "Product name should not be empty!\n"
    }
    if self.addQtyText.text == nil || self.addQtyText.text == "" {
      validateMessage += "Quantity should not be empty!\n"
    }
    if self.addPriceText.text == nil || self.addPriceText.text == "" {
      validateMessage += "Price should not be empty!\n"
    }
    
    if validateMessage != "" {
      let alertController = UIAlertController(title: "Validate Info", message: validateMessage, preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    } else {
      addProduct(productName: self.addNameText.text!, quantity: Int(self.addQtyText.text!)!, price: Double(self.addPriceText.text!)!)
    }
  }
  
  @IBAction func purchaseAction(_ sender: Any) {
    debugPrint("purechase!")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.cartList.append(Product(name: "Product 1", qty: 2, price: 1.20))
    self.cartList.append(Product(name: "Product 2", qty: 3, price: 1.60))
    
    self.cartTableView.dataSource = self
    self.addQtyText.delegate = self
    self.addPriceText.delegate = self
    
    let total = self.getTotal()
    self.totalLabel.text = "Total \(total)"
    
    self.expDatePickerView.dataSource = self
    self.expDatePickerView.delegate = self
    
    //    /// replace with prod service url
    //    let tokenServiceUrl = "url"
    //    let capabilityServiceUrl = "url"
    //    let serviceAuthKey = "key"
    //
    //    // sample for one time token generate
    //    let options = Options(ccPan: "4012888888881881", ccCvv: "123", ccExpyear: "22", ccExpmonth: "09")
    //    let ott = OneTimeTokenGenerator(serviceAuthKey, tokenServiceUrl)
    //    ott.getPayload(options) { response in
    //      if let payload = response.payload {
    //        debugPrint("this payload is: \(payload)")
    //      } else if let errors = response.error {
    //        for error in errors {
    //          debugPrint("error : code \(error.errorCode ?? 0), message \(error.errorMessage ?? "").")
    //        }
    //      }
    //    }
    //
    //
    //    // sample for capability look up
    //    let lookup = CapabilityLookup(serviceAuthKey, capabilityServiceUrl)
    //    lookup.getCapabilities { response in
    //      debugPrint("currency count : \(response.count)")
    //      for currency in response {
    //        debugPrint("currency code : \(currency.code)")
    //      }
    //    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.cartList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.cartTableView.dequeueReusableCell(withIdentifier: "prodCell")! as! ProductTableViewCell
    let dest = self.cartList[indexPath.row] as Product
    cell.prodLabel.text = dest.name
    cell.priceLabel.text = String(dest.price)
    cell.qtyLabel.text = String(dest.qty)
    return cell
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 2
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerDataSource[component].count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerDataSource[component][row]
  }
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    var pickerLabel: UILabel? = (view as? UILabel)
    if pickerLabel == nil {
      pickerLabel = UILabel()
      pickerLabel?.font = UIFont(name: "System 13.0", size: 13)
      pickerLabel?.textAlignment = .center
    }
    pickerLabel?.text = pickerDataSource[component][row]
    //pickerLabel?.textColor = UIColor.blue
    
    return pickerLabel!
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
    let components = string.components(separatedBy: inverseSet)
    let filtered = components.joined(separator: "")
    return string == filtered
  }
  
  func getTotal() -> Double {
    var total = 0.0
    for item in self.cartList {
      total += (Double(item.qty) * item.price)
    }
    return total
  }
  
  func addProduct(productName: String, quantity: Int, price: Double) {
    self.cartList.append(Product(name: productName, qty: quantity, price: price))
    self.cartTableView.reloadData()
    
    let total = self.getTotal()
    self.addNameText.text = ""
    self.addQtyText.text = ""
    self.addPriceText.text = ""
    self.totalLabel.text = "Total \(total)"
  }
  
}

