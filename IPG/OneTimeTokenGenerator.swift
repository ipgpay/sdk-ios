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
  
  func isValidCVV(cvvNum: String) -> Bool {
    let regex = Regex()
    
    return regex.test(for: "^[0-9]{3,4}$", in: cvvNum);
  }
  
  public func isValidExpiryDate(expYear: String, expMonth: String) -> Bool {
    let regex = Regex()
    if expYear.isEmpty || !regex.test(for: "^[0-9]{2,4}$", in: expYear) {
      return false
    }
    if expMonth.isEmpty || !regex.test(for: "^([1-9]|0[1-9]|1[012])$", in: expMonth){
      return false
    }
    var dateStr = ""
    if expYear.characters.count == 2 {
      var tmpYear = Int(expYear) ?? 0
      tmpYear += 2000
      dateStr = "\(tmpYear)/\(String(format:"%02d",Int(expMonth) ?? 0))/00"
    } else {
      dateStr = "\(expYear)/\(String(format:"%02d",Int(expMonth) ?? 0))/00"
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    let expDate = formatter.date(from: dateStr)
    
    let nowDate = Date()
    if let realExpDate = expDate {
      return nowDate < realExpDate
    }
    else {
      return false
    }
  }
  
  
  
  func generateErrorCode(_ options: OptionsProtocol) -> Int {
    var retCode = 0;
    
    if options.ccPan == "" {
      retCode += ErrorCode.invalidCreditCardNumber;
    }
    if options.ccCvv == "" {
      retCode += ErrorCode.invalidCVV;
    }
    if options.ccExpmonth.isEmpty || options.ccExpyear.isEmpty {
      retCode += ErrorCode.invalidExpiryDate;
    }
    return retCode;
  }
  
  func generateErrors(_ retCode: Int) -> [Int: String] {
    var errors = [Int: String]()
    
    if (retCode & ErrorCode.invalidCreditCardNumber) == ErrorCode.invalidCreditCardNumber {
      errors[ErrorCode.invalidCreditCardNumber] = "Credit card number is invalid."
    }
    if (retCode & ErrorCode.invalidCVV) == ErrorCode.invalidCVV {
      errors[ErrorCode.invalidCVV] = "CVV is invalid."
    }
    if ((retCode & ErrorCode.invalidExpiryDate) == ErrorCode.invalidExpiryDate) {
      errors[ErrorCode.invalidExpiryDate] = "Expiry date is invalid."
      
    }
    if ((retCode & ErrorCode.invalidInput) == ErrorCode.invalidInput) {
      errors[ErrorCode.invalidInput] = "Invalid Input (positive number expected)."
    }
    if ((retCode & ErrorCode.commsNoResponse) == ErrorCode.commsNoResponse) {
      errors[ErrorCode.commsNoResponse] = "Communications failure. Server returned an empty response."
    }
    if ((retCode & ErrorCode.commsParseFailure) == ErrorCode.commsParseFailure) {
      errors[ErrorCode.commsParseFailure] = "Communications failure. Response from server could not be parsed."
    }
    if ((retCode & ErrorCode.commsServerUnreachable) == ErrorCode.commsServerUnreachable) {
      errors[ ErrorCode.commsServerUnreachable] = "Communications failure. Failed to establish communications."
    }
    if ((retCode & ErrorCode.commsUnexpectedResponse) == ErrorCode.commsUnexpectedResponse) {
      errors[ErrorCode.commsUnexpectedResponse]  = "Communications failure. Unexpected response."
    }
    return errors;
  }
  
  public func getPayload(_ options: OptionsProtocol, _ responseHandler: (PayloadProtocol) -> Void) {
    let retCode = generateErrorCode(options)
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
