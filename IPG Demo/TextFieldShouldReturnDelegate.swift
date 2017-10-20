//
//  TextFieldShouldReturnDelegate.swift
//  IPG
//
//  Created by AirS CC on 22/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import UIKit

class TextFieldShouldReturnDelegate: NSObject, UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
