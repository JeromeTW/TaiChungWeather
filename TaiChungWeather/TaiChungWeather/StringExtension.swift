//
//  StringExtension.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/7/29.
//  Copyright © 2019 JEROME. All rights reserved.
//

import Foundation

extension String {

  func convertToDate(from dateFormat: DateFormat) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat.rawValue

    return dateFormatter.date(from: self)
  }
}
