//
//  test.swift
//  IPG
//
//  Created by AirS CC on 04/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

public class Test{
  
  public init(){
    
  }
  
  public func getNumber() -> Int {
    return 2
  }
  
  public func doIt() {
    Alamofire.request("https://httpbin.org/get", parameters:["foo": "bar"])
      .responseObject { (response: DataResponse<TestResponse>) in
        let tempResp = response.result.value
        debugPrint(tempResp?.origin ?? "null")
        debugPrint(tempResp?.headers?.userAgent ?? "null")
    }
  }
  
  public func getString() -> String {
    return "this is IPG library"
  }
}
