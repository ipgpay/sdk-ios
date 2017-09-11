//
//  CapabilityResponseXmlParse.swift
//  IPG
//
//  Created by AirS CC on 11/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation

class CapabilityResponseXmlParse : NSObject, XMLParserDelegate {
  var currencies = [Currency]()
  
  var currentCurrency = Currency()
  var currentPayment = Payment()
  var currentFoundCharacters = ""
  
  public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    if elementName == "Currency" {
      if let code = attributeDict["code"] {
        self.currentCurrency.code = code
      }
    }
    
    if elementName == "PaymentMethod" {
      if let method = attributeDict["method"] {
        self.currentPayment.method = method
      }
    }
  }
  
  public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
    if elementName == "PaymentType" {
      self.currentPayment.types.append(self.currentFoundCharacters)
    }
    
    if elementName == "PaymentMethod" {
      
      var tempPayment = Payment()
      tempPayment.method = self.currentPayment.method
      tempPayment.types = self.currentPayment.types
      self.currentCurrency.payments.append(tempPayment)
      
      self.currentPayment.method = ""
      self.currentPayment.types.removeAll()
      
    }
    
    if elementName == "Currency" {
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
