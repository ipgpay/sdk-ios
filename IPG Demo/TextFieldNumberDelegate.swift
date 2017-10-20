//
//  TextFieldNumberDelegate.swift
//  IPG
//
//  Created by AirS CC on 28/09/2017.
//  Copyright © 2017 AirS CC. All rights reserved.
//

import Foundation
import UIKit

class TextFieldNumberDelegate: NSObject, UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
    let components = string.components(separatedBy: inverseSet)
    let filtered = components.joined(separator: "")
    return string == filtered
  }
}

