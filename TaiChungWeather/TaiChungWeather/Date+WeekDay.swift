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
      return R.string.localizable.monday()
    case .tuesday:
      return R.string.localizable.tuesday()
    case .wednesday:
      return R.string.localizable.wednesday()
    case .thursday:
      return R.string.localizable.thursday()
    case .friday:
      return R.string.localizable.friday()
    case .saturday:
      return R.string.localizable.saturday()
    case .sunday:
      return R.string.localizable.sunday()
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
