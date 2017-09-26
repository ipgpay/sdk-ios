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
  
  let tokenServiceUrl = "https://payment.ipgholdings.net/service/token/create"
  let capabilityServiceUrl = "url"
  let serviceAuthKey = "ZnHvGDpYJhkQ"
  let merchantServer: MerchantServer = MerchantServer("https://api-a2integ12-ipgpay.ipggroup.com/sdk/ipg-mobiledemo-server/index.php")
  let textFieldShouldReturnDelegate = TextFieldShouldReturnDelegate()
  
  var cartList: [Product] = [Product]()
  var pickerDataSource = [
    ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"],
    ["2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027"]]
  
  /// show error
  @IBOutlet weak var errorStackView: UIStackView!
  @IBOutlet weak var errorLabel: UILabel!
  
  /// for cart list display and add
  @IBOutlet weak var addQtyText: UITextField!
 
  @IBOutlet weak var addPriceText: UITextField!
  @IBOutlet weak var addNameText: UITextField!
  @IBOutlet weak var cartTableView: UITableView!
  @IBOutlet weak var totalLabel: UILabel!
  
  /// for pruchase result
  @IBOutlet weak var purchaseResultStackView: UIStackView!
  @IBOutlet weak var orderId: UILabel!
  @IBOutlet weak var orderChargeAccount: UILabel!
  @IBOutlet weak var orderPurchaseFrom: UILabel!
  @IBOutlet weak var orderPurchaseDate: UILabel!
  
  /// for payment input
  @IBOutlet weak var paymentCVVText: UITextField!
  @IBOutlet weak var expDatePickerView: UIPickerView!
  @IBOutlet weak var paymentLastNameText: UITextField!
  @IBOutlet weak var paymentFirstNameText: UITextField!
  @IBOutlet weak var paymentEmailText: UITextField!
  @IBOutlet weak var paymentCardholderNameText: UITextField!
  @IBOutlet weak var paymentCardNumberText: UITextField!
  
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

    //validate input
    var validateMessage = "";
    if self.paymentCardNumberText.text == nil || self.paymentCardNumberText.text == "" {
      validateMessage += "Card number should not be empty!\n"
    }
    if self.paymentCardholderNameText.text == nil || self.paymentCardholderNameText.text == "" {
      validateMessage += "Cardholder name should not be empty!\n"
    }
    if self.paymentCVVText.text == nil || self.paymentCVVText.text == "" {
      validateMessage += "CVV should not be empty!\n"
    }
    
    if self.paymentEmailText.text == nil || self.paymentEmailText.text == "" {
      validateMessage += "Email should not be empty!\n"
    }
    
    if validateMessage != "" {
      let alertController = UIAlertController(title: "Validate Info", message: validateMessage, preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
      return
    }
    
    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: UIAlertControllerStyle.alert)
    self.present(alert, animated: true, completion: nil)
    
    let month = pickerDataSource[0][self.expDatePickerView.selectedRow(inComponent: 0)]
    let year = pickerDataSource[1][self.expDatePickerView.selectedRow(inComponent: 1)]
    let yearLast2 = year.substring(from: year.index(year.startIndex, offsetBy: year.characters.count - 2))
    
    let options = Options(ccPan: self.paymentCardNumberText.text!, ccCvv: self.paymentCVVText.text!, ccExpyear: yearLast2, ccExpmonth: month)
    let ott = OneTimeTokenGenerator(serviceAuthKey, tokenServiceUrl)
    ott.getPayload(options) { response in
      if let payload = response.payload {
        debugPrint("this payload is: \(payload)")
        
        self.merchantServer.purchase(products: self.cartList, payload: payload, name: self.paymentCardholderNameText.text!, email: self.paymentEmailText.text!, responseHandler: { (detail) in
          
          if let orderId = detail.orderId {
            debugPrint(orderId)
            self.orderId.text = orderId
            self.orderPurchaseFrom.text = "SHINE-MGR"
            self.orderPurchaseDate.text = detail.orderDatetime
            self.orderChargeAccount.text = detail.orderTotal
            self.purchaseResultStackView.isHidden = false
            self.errorStackView.isHidden = true
            self.errorLabel.text = ""
            alert.dismiss(animated: true, completion: nil)
          } else{
            alert.dismiss(animated: true, completion: nil)
            var tempMessage = "submit order failed:\n"
            if let errors = detail.errors {
              for error in errors {
                tempMessage += "error: code \(error.code ?? "0"), message: \(error.text ?? "")\n"
              }
            }
            debugPrint(tempMessage)
            self.alert(message: tempMessage)
          }
        })
      } else if let errors = response.error {
        alert.dismiss(animated: true, completion: nil)
        var tempMessage = "Generate payload failed:\n"
        for error in errors {
          tempMessage += "error: code \(error.errorCode ?? 0), message: \(error.errorMessage ?? "")\n"
        }
        debugPrint(tempMessage)
        self.alert(message: tempMessage)
      }
    }
  }
  func alert(message: String) {
    self.purchaseResultStackView.isHidden = true
    self.errorStackView.isHidden = false
    self.errorLabel.text = message
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // init data
    self.cartList.append(Product(name: "Product 1", qty: 2, price: 1.20))
    self.cartList.append(Product(name: "Product 2", qty: 3, price: 1.60))
    let total = self.getTotal()
    self.totalLabel.text = "Total \(total)USD"
    
    //init control
    self.cartTableView.dataSource = self
    self.addQtyText.delegate = self
    self.addPriceText.delegate = self
    self.addNameText.delegate = self.textFieldShouldReturnDelegate
    
    self.paymentCardNumberText.delegate = self.textFieldShouldReturnDelegate
    self.paymentCardholderNameText.delegate = self.textFieldShouldReturnDelegate
    self.paymentCVVText.delegate = self.textFieldShouldReturnDelegate
    self.paymentFirstNameText.delegate = self.textFieldShouldReturnDelegate
    self.paymentLastNameText.delegate = self.textFieldShouldReturnDelegate
    self.paymentEmailText.delegate = self.textFieldShouldReturnDelegate
    
    self.expDatePickerView.dataSource = self
    self.expDatePickerView.delegate = self
    
    self.purchaseResultStackView.isHidden = true
    self.errorStackView.isHidden = true
    
    self.hideKeyboardWhenTappedAround()
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
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
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
    self.totalLabel.text = "Total \(total)USD"
  }
  
}

extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
}

