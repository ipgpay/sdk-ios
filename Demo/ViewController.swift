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
    
    let ott: OneTimeTokenGenerator = OneTimeTokenGenerator("testkey","http://private-ed273e-ipg.apiary-mock.com/token")
    
    let options = Options(ccPan: "4012888888881881", ccCvv: "318", ccExpyear: "19", ccExpmonth: "09")
    
    ott.getPayload(options) { payload in
      let str = "111"
      debugPrint(str)
    }
 
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

