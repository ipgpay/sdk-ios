//
//  TextFieldNumberDelegate.swift
// @copyright Copyright (c) 2017 IPG Group Limited
// All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE.txt file for details.
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

