/*
 UIViewController+Alerts.swift
 
 Copyright © 2017 SoftArts Inc. All rights reserved.
 
 * Description: Show alert in UIViewController.
 
 * Creation Date: 2017/7/13
 * Author: Jerome Hsieh
 * Language: Swift 3/4
 * OS: iOS/watchOS/macOS
 * Source: n/a
 * Reference: n/a
 * Note: n/a
 
 */

import UIKit

extension UIViewController {
  typealias AlterSimpleHandler = () -> Void
  typealias TextFieldHandler = ([UITextField]) -> Void
  typealias ActionHandler = ((UIAlertAction) -> Void)?
  
  struct TextFieldData {
    var text: String?
    var placeholder: String?
  }
  
  
  /* Usage example:
   let actions = [
   UIAlertAction(title: "titleString", style: .destructive, handler: { _ in
   // do something.
   }), UIAlertAction(title: "common_cancel", style: .default)
   ]
   self.showAlertWithActions("titleString", message: "message", actions: actions)
   */
  /// Show alert view controller with actions.
  ///
  /// - Parameters:
  ///   - title: alert title.
  ///   - message: alert message.
  ///   - textColor: text color.
  ///   - actions: action array.
  func showAlertWithActions(_ title: String?, message: String?, textColor: UIColor? = nil, actions: [UIAlertAction]) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
      
      for action in actions {
        alert.addAction(action)
      }
      
      if let textColor = textColor {
        alert.view.tintColor = textColor
        self.present(alert, animated: true) {
          alert.view.tintColor = textColor
        }
      } else {
        self.present(alert, animated: true)
      }
    }
  }
  
  func showOKAlert(_ title: String?, message: String?, okTitle: String, textColor: UIColor? = nil) {
    showAlertWithActions(title, message: message, actions: [UIAlertAction(title: okTitle, style: .default)])
  }
  
  /* Usage example:
   let inputTextFieldsData = [TextFieldData(text: nil, placeholder: nil, isSecureTextEntry: true)]
   showAlertVCWithTextFields("titleString", message: "message", textFieldsData: inputTextFieldsData, okTitle: "common_backup", cancelTitle: "common_cancel", cancelHandler: nil) { textFields in
   guard let fileName = textFields.first?.text else {
   return
   }
   }
   */
  /// Show alert view controller with textfields.
  ///
  /// - Parameters:
  ///   - title: alert title.
  ///   - message: alert message.
  ///   - textColor: text color.
  ///   - textFieldsData: textFieldsData array.
  ///   - okTitle: ok button title.
  ///   - cancelTitle: cancel button title.
  ///   - cancelHandler: ok button handler.
  ///   - okHandler: cancel button handler.
  func showAlertVCWithTextFields(_ title: String?, message: String?, textColor: UIColor? = nil, textFieldsData: [TextFieldData], okTitle: String, cancelTitle: String, cancelHandler: AlterSimpleHandler?, okHandler: TextFieldHandler?) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
      
      var textfields = [UITextField]()
      for textFieldData in textFieldsData {
        alert.addTextField { (textField) -> Void in
          textField.text = textFieldData.text
          textField.placeholder = textFieldData.placeholder
          textField.clearButtonMode = .whileEditing
          textfields.append(textField)
        }
      }
      
      let ok = UIAlertAction(title: okTitle, style: .default) { _ in
        okHandler?(textfields)
      }
      
      let cancel = UIAlertAction(title: cancelTitle, style: .default) { _ in
        cancelHandler?()
      }
      
      alert.addAction(ok)
      alert.addAction(cancel)
      
      if let textColor = textColor {
        alert.view.tintColor = textColor
        self.present(alert, animated: true) {
          alert.view.tintColor = textColor
        }
      } else {
        self.present(alert, animated: true)
      }
    }
  }
}

