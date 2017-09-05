//
//  ViewController.swift
//  Demo
//
//  Created by AirS CC on 04/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import UIKit
import IPG

class ViewController: UIViewController {

  
  @IBOutlet weak var _label: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let ott = OneTimeTokenGenerator()
    
    let result = ott.isValidExpiryDate(expYear: "17", expMonth: "09")
    
    if result {
     debugPrint("date is valid")
    }
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

