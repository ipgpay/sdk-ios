//
//  ViewController.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
//

import UIKit
import IPG

class ViewController: UIViewController {
  
  
  @IBOutlet weak var _label: UILabel!
  override func viewDidLoad() {
    
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    
    let cl = CapabilityLookup("key", "http://private-ed273e-ipg.apiary-mock.com/capability/")
    
    cl.getCapabilities { (currencies) in
      for currency in currencies {
        debugPrint(currency.code)
      }
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

