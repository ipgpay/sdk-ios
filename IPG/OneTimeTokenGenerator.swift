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
  
  func getPayload(_ options: OptionsProtocol, _ responseHandler: @escaping (PayloadProtocol) -> Void)
  
}

struct PaddedData {
  var cc_cvv: String
  var cc_expmonth: String
  var cc_expyear: String
  var cc_pan_remainder: String
  
  var pad: String
  var cc_pan_bin: String
  var cc_pan_last4: String
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
  
  func isValidExpiryDate(_ expYear: String, _ expMonth: String) -> Bool {
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
  
  func isValidLuhn(_ input: String) -> Bool {
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
  
  func validateData(_ options: OptionsProtocol) -> Int {
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
  
  func formatData(_ options: OptionsProtocol) -> OptionsProtocol {
    
    let ccPan = options.ccPan.trimmingCharacters(in: .whitespacesAndNewlines)
    let ccCvv =  options.ccCvv.trimmingCharacters(in: .whitespacesAndNewlines)
    let ccExpyear = options.ccExpyear.trimmingCharacters(in: .whitespacesAndNewlines)
    let ccExpmonth = options.ccExpmonth.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return Options(ccPan: ccPan, ccCvv: ccCvv, ccExpyear: ccExpyear, ccExpmonth: ccExpmonth)
  }
  
  func generateErrors(_ retCode: Int) -> [OttErrorProtocol] {
    var errors = [OttErrorProtocol]()
    
    if (retCode & ErrorCode.invalidCreditCardNumber.rawValue) == ErrorCode.invalidCreditCardNumber.rawValue {
      errors.append(OttError(ErrorCode.invalidCreditCardNumber.rawValue, "Credit card number is invalid."))
    }
    if (retCode & ErrorCode.invalidCVV.rawValue) == ErrorCode.invalidCVV.rawValue {
      errors.append(OttError(ErrorCode.invalidCVV.rawValue, "CVV is invalid."))
    }
    if (retCode & ErrorCode.invalidExpiryDate.rawValue) == ErrorCode.invalidExpiryDate.rawValue {
      errors.append(OttError(ErrorCode.invalidExpiryDate.rawValue,"Expiry date is invalid."))
    }
    if (retCode & ErrorCode.invalidInput.rawValue) == ErrorCode.invalidInput.rawValue {
      errors.append(OttError(ErrorCode.invalidInput.rawValue, "Invalid Input (positive number expected)."))
    }
    if (retCode & ErrorCode.commsNoResponse.rawValue) == ErrorCode.commsNoResponse.rawValue {
      errors.append(OttError(ErrorCode.commsNoResponse.rawValue, "Communications failure. Server returned an empty response."))
    }
    if (retCode & ErrorCode.commsParseFailure.rawValue) == ErrorCode.commsParseFailure.rawValue {
      errors.append(OttError(ErrorCode.commsParseFailure.rawValue, "Communications failure. Response from server could not be parsed."))
    }
    if (retCode & ErrorCode.commsServerUnreachable.rawValue) == ErrorCode.commsServerUnreachable.rawValue {
      errors.append(OttError(ErrorCode.commsServerUnreachable.rawValue, "Communications failure. Failed to establish communications."))
    }
    if (retCode & ErrorCode.commsUnexpectedResponse.rawValue) == ErrorCode.commsUnexpectedResponse.rawValue {
      errors.append(OttError(ErrorCode.commsUnexpectedResponse.rawValue, "Communications failure. Unexpected response."))
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
    
    Alamofire.request(self.tokenServiceUrl, method: .post, parameters: parameters, headers: headers)
      .validate()
      .responseObject { (response: DataResponse<TokenResponse>) in
        
        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
          if utf8Text.isEmpty {
            let errors = self.generateErrors(ErrorCode.commsNoResponse.rawValue)
            responseHandler(Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors))
            return
          }
        }
        
        switch response.result {
        case .success:
          if let token = response.result.value?.token {
            responseHandler(Payload(payload: "1" + token + paddedData.pad, ccPanBin: paddedData.cc_pan_bin, ccPanLast4: paddedData.cc_pan_last4, error: nil))
            return
          }
          
          if let errors = response.result.value?.errors {
            responseHandler(Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors))
            return
          }
          
          break
        case .failure(let error):
          if let afError = error as? AFError {
            switch afError {
            case AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.unacceptableStatusCode(404)):
              let errors = self.generateErrors(ErrorCode.commsServerUnreachable.rawValue)
              responseHandler(Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors))
              return
            default:
              break
            }
          }
          
          let errors = self.generateErrors(ErrorCode.commsParseFailure.rawValue)
          responseHandler(Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors))
          break
        }
        
        let errors = self.generateErrors(ErrorCode.commsUnexpectedResponse.rawValue)
        responseHandler(Payload(payload: nil, ccPanBin: nil, ccPanLast4: nil, error: errors))
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
