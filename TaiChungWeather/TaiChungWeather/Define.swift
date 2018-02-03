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
  static let dailySentenceEntityName = "DailySentence"  // TODO: modeld
  
  // Weather Entity Key
  static let timeKey = "time"
  static let contentKey = "content"
  
  
}

enum Localization: String {
  case ok
}

enum ImageName: String {
  case name
}
