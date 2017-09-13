//
//  ViewController.swift
//  IPG Demo
//
//  Created by AirS CC on 12/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import UIKit
import IPG

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// replace with prod service url
    let tokenServiceUrl = "url"
    let capabilityServiceUrl = "url"
    let serviceAuthKey = "key"
    
    // sample for one time token generate
    let options = Options(ccPan: "4012888888881881", ccCvv: "123", ccExpyear: "22", ccExpmonth: "09")
    let ott = OneTimeTokenGenerator(serviceAuthKey, tokenServiceUrl)
    ott.getPayload(options) { response in
      if let payload = response.payload {
        debugPrint("this payload is: \(payload)")
      } else if let errors = response.error {
        for error in errors {
          debugPrint("error : code \(error.errorCode ?? 0), message \(error.errorMessage ?? "").")
        }
      }
    }
    
    
    // sample for capability look up
    let lookup = CapabilityLookup(serviceAuthKey, capabilityServiceUrl)
    lookup.getCapabilities { response in
      debugPrint("currency count : \(response.count)")
      for currency in response {
        debugPrint("currency code : \(currency.code)")
      }
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

