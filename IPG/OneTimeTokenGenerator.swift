//
//  OneTimeTokenGenerator.swift
//  IPG
//
//  Created by AirS CC on 05/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

public protocol OneTimeTokenGeneratorProtocol {
  
}

public protocol OptionsProtocol {
  var ccPan: String { get }
  var ccCvv: String { get }
  var ccExpyear: String { get }
  var ccExpmonth: String { get }
}

public struct Options: OptionsProtocol {
  
  public init(ccPan: String, ccCvv: String, ccExpyear: String, ccExpmonth: String) {
    self.ccPan = ccPan
    self.ccCvv = ccCvv
    self.ccExpyear = ccExpyear
    self.ccExpmonth = ccExpmonth
  }
  
  public var ccPan: String
  public var ccCvv: String
  public var ccExpyear: String
  public var ccExpmonth: String
}

public protocol PayloadProtocol {
  
  var payload: String? { get }
  var ccPanBin: String? { get }
  var ccPanLast4: String? { get }
  var error: [Int: String]? { get }
  
}

public struct PaddedData {
  public var cc_cvv: String
  public var cc_expmonth: String
  public var cc_expyear: String
  public var cc_pan_remainder: String
  
  public var pad: String
  public var cc_pan_bin: String
  public var cc_pan_last4: String
}

public struct Payload: PayloadProtocol {
  public var payload: String?
  public var ccPanBin: String?
  public var ccPanLast4: String?
  public var error: [Int: String]?
}

public class OneTimeTokenGenerator: OneTimeTokenGeneratorProtocol {
  
  var authKey: String
  var tokenServiceUrl: String
  
  public init(_ authKey: String, _ tokenServiceUrl: String) {
    self.authKey = authKey
    self.tokenServiceUrl = tokenServiceUrl
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
    if expYear.isEmpty || !regex.test(for: "^[0-9]{2}$", in: expYear) {
      return false
    }
    if expMonth.isEmpty || !regex.test(for: "^(0[1-9]|1[012])$", in: expMonth) {
      return false
    }
    
    let yearNumber = Int(expYear) ?? 0
    let monthNumber = Int(expMonth) ?? 0
    
    let expDate = Date.from(yearNumber + 2000, monthNumber, 1)
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
  
  func getEncrypted(_ input: String) throws -> (pad: String, val: String) {
    if !isNormalInteger(input) {
      throw ErrorCode.invalidInput
    }
    var newVal = ""
    var pad = ""
    
    for character in input.characters {
      let padNum = arc4random_uniform(10)
      pad += String(padNum)
      let digit = Int(String(character)) ?? 0
      newVal += String((digit + Int(padNum)) % 10)
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
    
    let ccPan = options.ccPan.trimmingCharacters(in: .whitespacesAndNewlines)
    let ccCvv =  options.ccCvv.trimmingCharacters(in: .whitespacesAndNewlines)
    let ccExpyear = options.ccExpyear.trimmingCharacters(in: .whitespacesAndNewlines)
    let ccExpmonth = options.ccExpmonth.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return Options(ccPan: ccPan, ccCvv: ccCvv, ccExpyear: ccExpyear, ccExpmonth: ccExpmonth)
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
  
  func getTokeniserServiceResponse(_ paddedData: PaddedData, _ responseHandler: @escaping (PayloadProtocol) -> Void) {
    let headers = [
      "Content-Type": "application/x-www-form-urlencoded"
    ]
    let parameters = [
      "auth_key": self.authKey,
      "cc_pan_bin": paddedData.cc_pan_bin,
      
      "cc_cvv": paddedData.cc_cvv,
      "cc_expmonth": paddedData.cc_expmonth,
      "cc_expyear": paddedData.cc_expyear,
      "cc_pan_remainder": paddedData.cc_pan_remainder
    ]
    
    Alamofire.request(self.tokenServiceUrl, method:.post, parameters: parameters, headers: headers)
      .responseObject { (response: DataResponse<TokenResponse>) in
        debugPrint(response.result.debugDescription)
        if response.result.isSuccess {
          if let resp = response.result.value {
          debugPrint(resp.token ?? "token is nil")
            debugPrint(resp.errors?.count ?? "error is nil")
          }
          debugPrint("request success!")
        } else {
          debugPrint("request failed")
          let errors = self.generateErrors(ErrorCode.commsServerUnreachable.rawValue)
          responseHandler(Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors))
        }
    }
  }
  
  func getPaddedData(ccPan: String, ccCvv: String, ccExpmonth: String, ccExpyear: String) throws -> PaddedData {
    
    let cc_pan_bin = ccPan.substring(to: ccPan.index(ccPan.startIndex, offsetBy: 6))
    let cc_pan_last4 = ccPan.substring(from: ccPan.index(ccPan.startIndex, offsetBy: ccPan.characters.count - 4))
    
    var cc_pan_remainder = ccPan.substring(from: ccPan.index(ccPan.startIndex, offsetBy: 6))
    var pad = ""
    
    let cvvResult = try getEncrypted(ccCvv)
    pad += cvvResult.pad
    let cc_cvv = cvvResult.val
    
    let expmonthResult = try getEncrypted(ccExpmonth)
    pad += expmonthResult.pad
    let cc_expmonth = expmonthResult.val
    
    let expyearResult = try getEncrypted(ccExpyear)
    pad += expyearResult.pad
    let cc_expyear = expyearResult.val
    
    let panRemainderResult = try getEncrypted(cc_pan_remainder)
    pad += panRemainderResult.pad
    cc_pan_remainder = panRemainderResult.val
    
    
    return PaddedData(cc_cvv: cc_cvv, cc_expmonth: cc_expmonth, cc_expyear: cc_expyear, cc_pan_remainder: cc_pan_remainder
      , pad: pad, cc_pan_bin: cc_pan_bin, cc_pan_last4: cc_pan_last4)
  }
  
  public func getPayload(_ options: OptionsProtocol, _ responseHandler: @escaping (PayloadProtocol) -> Void) {
    
    let formatOptions = formatData(options)
    let retCode = validateData(formatOptions)
    var response: PayloadProtocol
    
    if retCode != 0 {
      let errors = generateErrors(retCode)
      response = Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors)
    }
    else {
      let paddedResult: PaddedData?
      
      do {
        paddedResult = try getPaddedData(ccPan: options.ccPan, ccCvv: options.ccCvv, ccExpmonth: options.ccExpmonth, ccExpyear: options.ccExpyear)
      } catch {
        paddedResult = nil
      }
      
      if let result = paddedResult {
        getTokeniserServiceResponse(result, responseHandler)
      } else {
        let errors = generateErrors(ErrorCode.invalidInput.rawValue)
        response = Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors)
        responseHandler(response)
      }
    }
  }
  
}
