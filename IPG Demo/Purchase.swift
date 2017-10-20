//
//  Purchase.swift
//  IPG
//
//  Created by AirS CC on 20/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class OrderDetail: Mappable {
  
  var orderId: String?
  var orderTotal: String?
  var orderDatetime: String?
  var orderStatus: String?
  
  var errors: [OrderError]?
  
  init(_ orderId: String?, _ orderTotal: String?, _ orderDatetime: String?, _ orderStatus: String?, _ errors: [OrderError]?) {
    self.orderId = orderId
    self.orderTotal = orderTotal
    self.orderDatetime = orderDatetime
    self.orderStatus = orderStatus
    self.errors = errors
  }
  
  required init? (map: Map) {
    
  }
  
  func mapping(map: Map) {
    orderId <- map["order_id"]
    orderTotal <- map["order_total"]
    orderDatetime <- map["order_datetime"]
    orderStatus <- map["order_status"]
    
    errors <- map["errors.error"]
    
    if(errors == nil) {
      var tempError: OrderError?
      tempError <- map["errors.error"]
      errors = [OrderError]();
      if let error = tempError {
             errors?.append(error)
      }
    }
  }
}

class OrderError: Mappable {
  
  var code: String?
  var text: String?
  
  init(code: String, text: String) {
    self.code = code
    self.text = text
  }
  
  required init? (map: Map) {
  }
  
  func mapping(map: Map) {
    code <- map["code"]
    text <- map["text"]
  }
}

class MerchantServer {
  var merchantServiceUrl: String
  init(_ merchantServiceUrl: String) {
    self.merchantServiceUrl = merchantServiceUrl
  }
  func purchase(products: [Product], payload: String, name: String, email: String
    , responseHandler: @escaping (OrderDetail) -> Void) {
    var prodDic = [Any]()
    
    for prod in products {
      prodDic.append(prod.toDict())
    }
    
    let parameters: [String: Any] = [
      "payload": payload,
      "name": name,
      "email": email,
      "item": prodDic
    ]
    
    Alamofire.request(self.merchantServiceUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
      .validate()
      .responseObject { (response: DataResponse<OrderDetail>) in
        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
          if !utf8Text.isEmpty {
            debugPrint(utf8Text)
          }
        }
        
        switch response.result {
        case .success:
          debugPrint(response.result.value?.orderId ?? "empty")
          responseHandler(response.result.value!)
          break
        case .failure(let error):
          var errors = [OrderError]()
          if let afError = error as? AFError {
            switch afError {
            case AFError.responseValidationFailed(reason: AFError.ResponseValidationFailureReason.unacceptableStatusCode(404)):
              errors.append(OrderError(code: "404", text: "Can't access merchant server"))
              responseHandler(OrderDetail(nil, nil, nil, nil, errors))
              return
            default:
              break
            }
          }
          errors.append(OrderError(code: "500", text: "Unkown error from merchant server"))
          responseHandler(OrderDetail(nil, nil, nil, nil, errors))
          break
        }
    }
  }
}


