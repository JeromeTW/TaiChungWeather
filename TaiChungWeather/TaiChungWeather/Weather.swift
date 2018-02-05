//
//  Weather.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/2.
//  Copyright © 2018年 jerome. All rights reserved.
//
//  Managed object class for the WeekWeather entity.

import CoreData

enum WeatherTime {
  case day, night
  
  init(string: String) {
    if string == "白天" {
      self = .day
    } else {
      self = .night
    }
  }
  
  func getString() -> String {
    if self == .day {
      return LocStr(.day)
    } else {
      return LocStr(.night)
    }
  }
}

enum WeatherDescription: String {
  case sunny = "☀️" // 晴
  case sunnyWithcloud = "🌤"  // 晴時多雲
  case partlySunny = "⛅️"     // 多雲時晴
  case partlyCloudy = "🌥"    // 多雲、多雲時陰
  case cloudy = "☁️"          // 陰天、陰時多雲
  case sunnyCloudyRainy = "🌦"  // 多雲時陰短陣雨、多雲短陣雨
  case rainy = "🌧"           // 陰時有雨、陰時多雲短陣雨
  case stormy = "⛈"          // 有“暴雨”字
  case snowy = "❄️"           // 有“雪”字
  case unknown = "❓"
  
  init(string: String) {
    if string == "晴" {
      self = .sunny
    } else if string == "晴時多雲" {
      self = .sunnyWithcloud
    } else if string == "多雲時晴" {
      self = .partlySunny
    } else if string == "多雲" || string == "多雲時陰" {
      self = .partlyCloudy
    } else if string == "陰天" || string == "陰時多雲" {
      self = .cloudy
    } else if string == "多雲時陰短陣雨" || string == "多雲短陣雨" {
      self = .sunnyCloudyRainy
    } else if string == "陰時有雨" || string == "陰時多雲短陣雨" {
      self = .rainy
    } else if string.contains("暴雨") {
      self = .stormy
    } else if string.contains("雪") {
      self = .snowy
    } else {
      self = .unknown
    }
  }
}

struct Weather {
  var date: Date
  var weatherTime: WeatherTime
  var highestTemperature: Int
  var lowestTemperature: Int
  var description: WeatherDescription
}

