//
//  CapabilityResponseXMLParserDelegate.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
//

import Foundation

/// XML parser delegate for parse response xml
class CapabilityResponseXMLParserDelegate: NSObject, XMLParserDelegate {
  var currencies = [Currency]()
  
  var currentCurrency = Currency()
  var currentPayment = Payment()
  var currentFoundCharacters = ""
  
  public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    if "Currency".caseInsensitiveCompare(elementName) == ComparisonResult.orderedSame {
      if let code = attributeDict["code"] {
        self.currentCurrency.code = code
      }
    }
    
    if "PaymentMethod".caseInsensitiveCompare(elementName) == ComparisonResult.orderedSame {
      if let method = attributeDict["method"] {
        self.currentPayment.method = method
      }
    }
  }
  
  public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if "PaymentType".caseInsensitiveCompare(elementName) == ComparisonResult.orderedSame {
      self.currentPayment.types.append(self.currentFoundCharacters)
    }
    
    if "PaymentMethod".caseInsensitiveCompare(elementName) == ComparisonResult.orderedSame {
      var tempPayment = Payment()
      tempPayment.method = self.currentPayment.method
      tempPayment.types = self.currentPayment.types
      self.currentCurrency.payments.append(tempPayment)
      
      self.currentPayment.method = ""
      self.currentPayment.types.removeAll()
    }
    
    if "Currency".caseInsensitiveCompare(elementName) == ComparisonResult.orderedSame {
      var tempCurrency = Currency()
      tempCurrency.code = self.currentCurrency.code
      tempCurrency.payments = self.currentCurrency.payments
      self.currencies.append(tempCurrency)
      
      self.currentCurrency.code = ""
      self.currentCurrency.payments.removeAll()
    }
    self.currentFoundCharacters = ""
  }
  
  public func parser(_ parser: XMLParser, foundCharacters string: String) {
    self.currentFoundCharacters = string
  }
}
