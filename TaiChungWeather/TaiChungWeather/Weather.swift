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
}

struct Weather {
  var date: Date
  var weatherTime: WeatherTime
  var highestTemperature: Int
  var lowestTemperature: Int
  var description: String
}

