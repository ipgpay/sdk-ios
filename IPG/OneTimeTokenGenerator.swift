//
//  OneTimeTokenGenerator.swift
//  IPG
//
//  Created by AirS CC on 05/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation

public protocol OneTimeTokenGeneratorProtocol {
  
}

public protocol OptionsProtocol {
  var ccPan: String { get }
  var ccCvv: String { get }
  var ccExpyear: String { get }
  var ccExpmonth: String { get }
  var merchantKey: String { get }
}

public struct Options: OptionsProtocol {
  public var ccPan: String
  public var ccCvv: String
  public var ccExpyear: String
  public var ccExpmonth: String
  public var merchantKey: String
}

public protocol PayloadProtocol {
  
  var payload: String? { get }
  var ccPanBin: String? { get }
  var ccPanLast4: String? { get }
  var error: [Int: String]? { get }
  
}

public struct Payload: PayloadProtocol {
  public var payload: String?
  public var ccPanBin: String?
  public var ccPanLast4: String?
  public var error: [Int: String]?
}

public class OneTimeTokenGenerator: OneTimeTokenGeneratorProtocol {
  
  public init() {
    
  }
  
  func isNormalInteger(_ text: String) -> Bool {
    let regex = Regex()
    return regex.test(for: "^\\+?([0-9]\\d*)$", in: text)
  }
  
  func isValidCVV(_ cvvNum: String) -> Bool {
    let regex = Regex()
    return regex.test(for: "^[0-9]{3,4}$", in: cvvNum)
  }
  
  public func isValidExpiryDate(_ expYear: String, _ expMonth: String) -> Bool {
    let regex = Regex()
    if expYear.isEmpty || !regex.test(for: "^[0-9]{2,4}$", in: expYear) {
      return false
    }
    if expMonth.isEmpty || !regex.test(for: "^([1-9]|0[1-9]|1[012])$", in: expMonth){
      return false
    }
    
    var yearNumber = Int(expYear) ?? 0
    let monthNumber = Int(expMonth) ?? 0
    
    if expYear.characters.count == 2 {
      yearNumber += 2000
    }
    
    let expDate = Date.from(yearNumber, monthNumber, 1)
    let today = Date()
    return today < expDate
  }
  
  public func isValidLuhn(_ input: String) -> Bool {
    var sum = 0
    let numdigits = input.characters.count
    let parity = numdigits % 2
    
    for (index, character) in input.characters.enumerated() {
      var digit = Int(String(character)) ?? 0
      if (index % 2 == parity) {
        digit *= 2
      }
      if digit > 9 {
        digit -= 9
      }
      sum += digit
    }
    return ((sum != 0) && (sum % 10) == 0)
  }
  
  func getEncrypted(_ text: String) throws -> (pad: String, val: String) {
    // Encryption method to encrypt input string
    if !isNormalInteger(text) {
      throw ErrorCode.invalidInput
    }
    var newVal = ""
    var pad = ""
    for character in text.characters {
      let padNum = arc4random_uniform(10)
      pad += String(padNum)
      let digit = Int(String(character)) ?? 0
      newVal += String((digit + Int(padNum)) % 10);
    }
    return (pad: pad, val: newVal)
  }
  
  public func validateData(_ options: OptionsProtocol) -> Int {
    var retCode = 0;
    
    if options.ccPan.isEmpty || !isValidLuhn(options.ccPan) {
      retCode += ErrorCode.invalidCreditCardNumber.rawValue;
    }
    if options.ccCvv.isEmpty || !isValidCVV(options.ccCvv) {
      retCode += ErrorCode.invalidCVV.rawValue;
    }
    if options.ccExpmonth.isEmpty || options.ccExpyear.isEmpty || !isValidExpiryDate(options.ccExpyear, options.ccExpmonth){
      retCode += ErrorCode.invalidExpiryDate.rawValue;
    }
    
    return retCode
  }
  
  public func formatData(_ options: OptionsProtocol) -> OptionsProtocol {
    
    var ccPan = options.ccPan.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: nil)
    ccPan = ccPan.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let ccCvv =  options.ccPan.trimmingCharacters(in: .whitespacesAndNewlines)
    var ccExpyear = options.ccPan.trimmingCharacters(in: .whitespacesAndNewlines)
    var ccExpmonth = options.ccPan.trimmingCharacters(in: .whitespacesAndNewlines)
    let merchantKey = options.ccPan.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if ccExpyear.characters.count == 4 {
      ccExpyear = ccExpyear.substring(from: ccExpyear.index(ccExpyear.startIndex, offsetBy: 2))
    }
    if ccExpmonth.characters.count == 1 {
      ccExpmonth = "0" + ccExpmonth;
    }
    
    return Options(ccPan: ccPan, ccCvv: ccCvv, ccExpyear: ccExpyear, ccExpmonth: ccExpmonth, merchantKey: merchantKey)
  }
  
  func generateErrors(_ retCode: Int) -> [Int: String] {
    var errors = [Int: String]()
    
    if (retCode & ErrorCode.invalidCreditCardNumber.rawValue) == ErrorCode.invalidCreditCardNumber.rawValue {
      errors[ErrorCode.invalidCreditCardNumber.rawValue] = "Credit card number is invalid."
    }
    if (retCode & ErrorCode.invalidCVV.rawValue) == ErrorCode.invalidCVV.rawValue {
      errors[ErrorCode.invalidCVV.rawValue] = "CVV is invalid."
    }
    if (retCode & ErrorCode.invalidExpiryDate.rawValue) == ErrorCode.invalidExpiryDate.rawValue {
      errors[ErrorCode.invalidExpiryDate.rawValue] = "Expiry date is invalid."
    }
    if (retCode & ErrorCode.invalidInput.rawValue) == ErrorCode.invalidInput.rawValue {
      errors[ErrorCode.invalidInput.rawValue] = "Invalid Input (positive number expected)."
    }
    if (retCode & ErrorCode.commsNoResponse.rawValue) == ErrorCode.commsNoResponse.rawValue {
      errors[ErrorCode.commsNoResponse.rawValue] = "Communications failure. Server returned an empty response."
    }
    if (retCode & ErrorCode.commsParseFailure.rawValue) == ErrorCode.commsParseFailure.rawValue {
      errors[ErrorCode.commsParseFailure.rawValue] = "Communications failure. Response from server could not be parsed."
    }
    if (retCode & ErrorCode.commsServerUnreachable.rawValue) == ErrorCode.commsServerUnreachable.rawValue {
      errors[ ErrorCode.commsServerUnreachable.rawValue] = "Communications failure. Failed to establish communications."
    }
    if (retCode & ErrorCode.commsUnexpectedResponse.rawValue) == ErrorCode.commsUnexpectedResponse.rawValue {
      errors[ErrorCode.commsUnexpectedResponse.rawValue]  = "Communications failure. Unexpected response."
    }
    return errors;
  }
  
  public func getPayload(_ options: OptionsProtocol, _ responseHandler: (PayloadProtocol) -> Void) {
    
    let formatOptions = formatData(options)
    let retCode = validateData(formatOptions)
    var response: PayloadProtocol
    
    
    if retCode != 0 {
      let errors = generateErrors(retCode);
      response = Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors)
    }
    else {
      response = Payload(payload: "", ccPanBin: "", ccPanLast4: "", error: nil)
    }
    
    responseHandler(response)
  }
  
}
