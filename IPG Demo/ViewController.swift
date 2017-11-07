//
//  ViewController.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
//

import UIKit
import IPG

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
  
  let tokenServiceUrl = "https://payment.ipgholdings.net/service/token/create"
  let capabilityServiceUrl = "url"
  let serviceAuthKey = "ZnHvGDpYJhkQ"
  let merchantServer: MerchantServer = MerchantServer("https://api-a2integ12-ipgpay.ipggroup.com/sdk/ipg-mobiledemo-server/index.php")
  let textFieldShouldReturnDelegate = TextFieldShouldReturnDelegate()
  let textFieldNumberDelegate = TextFieldNumberDelegate()
  
  var cartList: [Product] = [Product]()
  
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
  @IBOutlet weak var orderPurchaseDate: UILabel!
  
  /// for payment input
  @IBOutlet weak var paymentExpYearText: UITextField!
  @IBOutlet weak var paymentExpMonthText: UITextField!
  @IBOutlet weak var paymentCVVText: UITextField!
  @IBOutlet weak var paymentCardholderNameText: UITextField!
  @IBOutlet weak var paymentCardNumberText: UITextField!
  
  /// for customer details
  @IBOutlet weak var paymentEmailText: UITextField!
  @IBOutlet weak var lastNameText: UITextField!
  @IBOutlet weak var firstNameText: UITextField!
  @IBOutlet weak var resetFormBtn: UIButton!
  
  @IBOutlet weak var cartTableViewHeight: NSLayoutConstraint!
  
  @IBAction func addProductAction(_ sender: Any) {
    
    var validateMessage = "";
    if self.addNameText.text == nil || self.addNameText.text == "" {
      validateMessage += "Product name should not be empty!\n"
    }
    if self.addQtyText.text == nil || self.addQtyText.text == "" {
      validateMessage += "Quantity should not be empty!\n"
    } else if let qtyStr = self.addQtyText.text {
      let qty = Int(qtyStr)!
      if qty > 999 {
        validateMessage += "Quantity max value is 999!\n"
      }
    }
    if self.addPriceText.text == nil || self.addPriceText.text == "" {
      validateMessage += "Price should not be empty!\n"
    } else if let priceStr = self.addPriceText.text {
      let price = Double(priceStr)!
      if price > 9999.99 {
        validateMessage += "Price max value is 9999.99!\n"
      }
    }
    
    if validateMessage != "" {
      let alertController = UIAlertController(title: "Validate Info", message: validateMessage, preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    } else {
      addProduct(productName: self.addNameText.text!, quantity: Int(self.addQtyText.text!)!, price: Double(self.addPriceText.text!)!)
    }
  }
  
  @IBAction func resetFormAction(_ sender: Any) {
    let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to reset?", preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
    alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
      self.addQtyText.text = ""
      self.addPriceText.text = ""
      self.addNameText.text = ""
      self.cartList.removeAll()
      self.totalLabel.text = String(format: "Total: USD %.2f", 0.00)
      self.cartTableView.reloadData()
      
      self.paymentExpYearText.text = ""
      self.paymentExpMonthText.text = ""
      self.paymentCVVText.text = ""
      self.paymentCardholderNameText.text = ""
      self.paymentCardNumberText.text = ""
      
      self.paymentEmailText.text = ""
      self.lastNameText.text = ""
      self.firstNameText.text = ""
      
      self.purchaseResultStackView.isHidden = true
      self.errorStackView.isHidden = true
    }))
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func purchaseAction(_ sender: Any) {
    let regex = Regex()
    //validate input
    var validateMessage = "";
    if self.paymentCardNumberText.text == nil || self.paymentCardNumberText.text == "" {
      validateMessage += "Card number should not be empty!\n"
    }
    if self.paymentCardholderNameText.text == nil || self.paymentCardholderNameText.text == "" {
      validateMessage += "Cardholder name should not be empty!\n"
    }
    if self.paymentExpMonthText.text == nil || self.paymentExpMonthText.text == "" {
      validateMessage += "Expiry month should not be empty!\n"
    } else if let expMonth = self.paymentExpMonthText.text {
      if !regex.test(for: "^(0[1-9]|1[012])$", in: expMonth) {
        validateMessage += "Expiry month is invalid!\n"
      }
    }
    if self.paymentExpYearText.text == nil || self.paymentExpYearText.text == "" {
      validateMessage += "Expiry year should not be empty!\n"
    } else if let expYear = self.paymentExpYearText.text {
      if !regex.test(for: "^[0-9]{4}$", in: expYear) {
        validateMessage += "Expiry year is invalid!\n"
      }
    }
    if self.paymentCVVText.text == nil || self.paymentCVVText.text == "" {
      validateMessage += "CVV should not be empty!\n"
    }
    if self.paymentEmailText.text == nil || self.paymentEmailText.text == "" {
      validateMessage += "Email should not be empty!\n"
    } else if !isValidEmail(text: self.paymentEmailText.text!) {
      validateMessage += "Email is invalid!\n"
    }
    
    if validateMessage != "" {
      let alertController = UIAlertController(title: "Validate Info", message: validateMessage, preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertController, animated: true, completion: nil)
      return
    }
    
    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: UIAlertControllerStyle.alert)
    self.present(alert, animated: true, completion: nil)
    
    let month = paymentExpMonthText.text!
    let year = paymentExpYearText.text!
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
            self.orderPurchaseDate.text = detail.orderDatetime
            self.orderChargeAccount.text = "USD $" + detail.orderTotal!
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
    self.totalLabel.text = String(format: "Total: USD %.2f", total)
    
    /// init control
    
    /// for cart list display and add
    self.cartTableView.dataSource = self
    self.addQtyText.delegate = self.textFieldNumberDelegate
    self.addQtyText.keyboardType = .numberPad
    self.addPriceText.delegate = self
    self.addPriceText.keyboardType = .decimalPad
    self.addNameText.delegate = self.textFieldShouldReturnDelegate
    
    /// for payment input
    self.paymentCardNumberText.delegate = self.textFieldShouldReturnDelegate
    self.paymentCardNumberText.keyboardType = .numberPad
    self.paymentCardholderNameText.delegate = self.textFieldShouldReturnDelegate
    self.paymentExpMonthText.delegate = self.textFieldShouldReturnDelegate
    self.paymentExpMonthText.keyboardType = .numberPad
    self.paymentExpYearText.delegate = self.textFieldShouldReturnDelegate
    self.paymentExpYearText.keyboardType = .numberPad
    self.paymentCVVText.delegate = self.textFieldShouldReturnDelegate
    self.paymentCVVText.keyboardType = .numberPad
    self.paymentEmailText.delegate = self.textFieldShouldReturnDelegate
    self.paymentEmailText.keyboardType = .emailAddress
    
    self.purchaseResultStackView.isHidden = true
    self.errorStackView.isHidden = true
    
    self.hideKeyboardWhenTappedAround()
    
    let attributes : [String: Any] = [
      NSFontAttributeName : UIFont.systemFont(ofSize: 13),
      NSForegroundColorAttributeName : UIColor.black,
      NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
    let attributeString = NSMutableAttributedString(string: "Reset Form", attributes: attributes)
    self.resetFormBtn.setAttributedTitle(attributeString, for: .normal)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.cartTableView.reloadData()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let height = min(self.view.bounds.size.height, cartTableView.contentSize.height)
    self.cartTableViewHeight.constant = height
    self.view.layoutIfNeeded()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.cartList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.cartTableView.dequeueReusableCell(withIdentifier: "prodCell")! as! ProductTableViewCell
    let dest = self.cartList[indexPath.row] as Product
    cell.prodLabel.text = dest.name
    cell.priceLabel.text = String(format: "%.2f", dest.price)
    cell.qtyLabel.text = String(dest.qty)
    return cell
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    switch string {
    case "0","1","2","3","4","5","6","7","8","9":
      return true
    case ".":
      let str = self.addPriceText.text!
      var decimalCount = 0
      for character in str.characters {
        if character == "." {
          decimalCount += 1
        }
      }
      
      if decimalCount == 1 || (decimalCount == 0 && str == ""){
        return false
      } else {
        return true
      }
    default:
      if string.characters.count == 0 {
        return true
      }
      return false
    }
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
    self.totalLabel.text = String(format: "Total: USD %.2f", total)
  }
  
  func isValidEmail(text: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: text)
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

