//
//  NSObjectExtension.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/7/29.
//  Copyright © 2019 JEROME. All rights reserved.
//

import Foundation

extension NSObject {
  static var className: String {
    return String(describing: self)
  }

  var className: String {
    return String(describing: type(of: self))
  }
}
