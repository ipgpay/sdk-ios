//
//  ViewController.swift
//  IPG Demo
//
//  Created by AirS CC on 12/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import UIKit
import IPG

protocol AddProductDelegate
{
  func addProduct(productName: String, quantity: Int, price: Double)
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddProductDelegate {
  
  var cartList: [Product] = [Product]()
  
  @IBOutlet weak var payBtn: UIButton!
  @IBOutlet weak var cartTableView: UITableView!
  @IBOutlet weak var totalLabel: UILabel!
  
  @IBAction func addProduct(_ sender: Any) {
    
    let addProductController = self.storyboard?.instantiateViewController(withIdentifier: "AddProuct") as! AddProuctViewController
    addProductController.isModalInPopover = true
    addProductController.delegate = self
    
    self.present(addProductController, animated: false, completion: nil)
    
  }
  
  @IBAction func clearCart(_ sender: Any) {
    self.cartList.removeAll()
    self.cartTableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.cartList.append(Product(name: "TEST ITEM- HQ line 1 (TEST ITEM- HQ line 1)", qty: 0, price: 1.20, description: "Test item for demonstration- HK$1 + 3 % credit card processing fee HK$0.2"))
    self.cartList.append(Product(name: "TEST ITEM- HQ line 2 (TEST ITEM- HQ line 2)", qty: 0, price: 1.60, description: "Test item for demonstration- HK$1 + 3 % credit card processing fee HK$0.2"))
    self.cartTableView.dataSource = self
    self.totalLabel.text = "Total HKD 2.80"
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
    cell.descriptionLabel.text = dest.description
    return cell
  }
  
  func addProduct(productName: String, quantity: Int, price: Double) {
    self.cartList.append(Product(name: productName, qty: quantity, price: price, description: ""))
    self.cartTableView.reloadData()
  }
  
}

