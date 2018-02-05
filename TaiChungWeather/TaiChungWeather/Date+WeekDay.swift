//
//  Date+WeekDay.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/5.
//  Copyright © 2018年 jerome. All rights reserved.
//

import Foundation

enum WeekDay: Int {
  case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
  
  func getString() -> String {
    switch self {
    case .monday:
      return LocStr(.monday)
    case .tuesday:
      return LocStr(.tuesday)
    case .wednesday:
      return LocStr(.wednesday)
    case .thursday:
      return LocStr(.thursday)
    case .friday:
      return LocStr(.friday)
    case .saturday:
      return LocStr(.saturday)
    case .sunday:
      return LocStr(.sunday)
    }
  }
  
  init(string: String) {
    switch string {
    case "Monday":
      self = .monday
    case "Tuesday":
      self = .tuesday
    case "Wednesday":
      self = .wednesday
    case "Thursday":
      self = .thursday
    case "Friday":
      self = .friday
    case "Saturday":
      self = .saturday
    default:
      self = .sunday
    }
  }
}

extension Date {
  var weekDay: WeekDay {
    let current = description(with: .current)
    // "Monday, November 7, 2016 at 12:00:00 AM Brasilia Summer Time"
    let array = current.components(separatedBy: ",")
    return WeekDay(string: array[0])
  }
}

