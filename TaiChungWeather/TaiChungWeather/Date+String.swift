//
//  Date+String.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/3.
//  Copyright © 2018年 jerome. All rights reserved.
//

import Foundation

extension Date {
  
  enum Month: String {
    case Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
    
    func getInt() -> Int {
      switch self {
      case .Jan:
        return 1
      case .Feb:
        return 2
      case .Mar:
        return 3
      case .Apr:
        return 4
      case .May:
        return 5
      case .Jun:
        return 6
      case .Jul:
        return 7
      case .Aug:
        return 8
      case .Sep:
        return 9
      case .Oct:
        return 10
      case .Nov:
        return 11
      case .Dec:
        return 12
      }
    }
  }
  
  // dateTimeString example: "Fri, 02 Feb 2018 03:18:25 GMT"
  static func dateFromString(dateTimeString: String) -> Date? {
    let array = dateTimeString.components(separatedBy: " ")
    // ["Fri,", "02", "Feb", "2018", "03:18:25", "GMT"]
    guard array.count == 6 else {
      return nil
    }
    let timeArray = array[4].components(separatedBy: ":")
    guard timeArray.count == 3 else {
      return nil
    }
    
    var dateComponents = DateComponents()
    dateComponents.year = Int(array[3])
    if let month = Month(rawValue: array[2]) {
      dateComponents.month = month.getInt()
    }
    dateComponents.day = Int(array[1])
    dateComponents.timeZone = TimeZone(abbreviation: array[5])
    dateComponents.hour = Int(timeArray[0])
    dateComponents.minute = Int(timeArray[1])
    dateComponents.second = Int(timeArray[2])
    
    // Create date from components
    let userCalendar = Calendar.current // user calendar
    return userCalendar.date(from: dateComponents)
  }
}
