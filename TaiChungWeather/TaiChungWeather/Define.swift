//
//  Define.swift
//  groupsync
//
//  Created by JEROME on 2017/10/4.
//  Copyright © 2017年 JEROME. All rights reserved.
//

import UIKit

enum Constant {
  // NSPersistentContainer
  static let perisistentContainerName = "WeekWeather" // .xcdatamodeld file name.
  
  static let weatherEntityName = "WeekWeather"
  static let dailyQuoteEntityName = "DailyQuote"
  
  // Entity Key
  static let timeKey = "time"
  static let contentKey = "content"
  static let authorKey = "author"
  static let articleKey = "article"
  
  
}

enum Localization: String {
  case dailyQuote
  case day
  case night
  case today
}

enum ImageName: String {
  case background
}

enum Color {
  static let tiffanyBlue = UIColor(redInt: 165, greenInt: 218, blueInt: 219)
  static let lightTiffanyBlue = UIColor(redInt: 242, greenInt: 251, blueInt: 251)
  static let orange = UIColor(redInt: 247, greenInt: 201, blueInt: 3)
}
