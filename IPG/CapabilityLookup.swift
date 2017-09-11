//
//  CapabilityLookup.swift
//  IPG
//
//  Created by AirS CC on 11/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import Alamofire

public class CapabilityLookup {
  var authKey: String
  var capabilityServiceUrl: String
  
  public init(_ authKey: String, _ capabilityServiceUrl: String) {
    self.authKey = authKey
    self.capabilityServiceUrl = capabilityServiceUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
  }
  
  public func getCapabilities(_ responseHandler: @escaping ([Currency]) -> Void) {
    let url = self.capabilityServiceUrl + "/" + self.authKey
    Alamofire.request(url, method: .get, parameters: nil)
      .response { response in
        if let xmlData = response.data {
          let parse = XMLParser(data: xmlData)
          let delegate = CapabilityResponseXmlParse()
          parse.delegate = delegate
          parse.parse()
          let currencies = delegate.currencies
          responseHandler(currencies)
        } else {
          let currencies = [Currency]()
          responseHandler(currencies)
        }
    }
  }
}
