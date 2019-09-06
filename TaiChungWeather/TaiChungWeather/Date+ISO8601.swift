/*
 Date+ISO8601.swift

 Copyright © 2017 SoftArts Inc. All rights reserved.

 * Description: Convert between ISO8601 DateTime and Date.

 * Creation Date: 2017/6/18
 * Author: Kent Liu
 * Language: Swift 3/4
 * OS: iOS/watchOS/macOS
 * Source: n/a
 * Reference: n/a
 * Note:
 Apple Provide NSISO8601DateFormater since iOS10.
 https://developer.apple.com/documentation/foundation/nsiso8601dateformatter

 */

import Foundation

extension Date {
  static func dateFromISO8601String(dateTimeString: String, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
    // Example of dateTimeString: 2016-06-14T09:27:51.177Z
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format // iso 8601

    return dateFormatter.date(from: dateTimeString)
  }

  func ISO8601String() -> String {
    // Example of dateTimeString: 2016-06-14T09:27:51.177Z
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // iso 8601
    // Fix the issue when output string in correct timezone.
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    return dateFormatter.string(from: self)
  }
}
