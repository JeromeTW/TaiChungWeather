//
//  WeekWeather+Weather.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/5.
//  Copyright © 2018年 jerome. All rights reserved.
//

import Foundation

extension WeekWeather {
  func covertToWeatherResults() -> [Weather]? {
    guard let content = content else {
      assertionFailure()
      return nil
    }
    let divider = "<BR>"
    let times = content.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "").components(separatedBy: divider)
    var results = [Weather]()
    for (outerIndex, time) in times.enumerated() { //  "02/04 晚上 溫度:9 ~ 11 多雲"
      if outerIndex >= 14 {
        break
      }
      let newString = time.replacingOccurrences(of: "溫度:", with: "").replacingOccurrences(of: " ~", with: "")
      //  "02/04 晚上 9 11 多雲"
      let properties = newString.components(separatedBy: " ")
      guard properties.count == 5 else {
        assertionFailure()
        return nil
      }
      var newWeather = Weather(date: Date(), weatherTime: .day, highestTemperature: 20, lowestTemperature: 15, description: .sunny)
      for (index, property) in properties.enumerated() {
        switch index {
        case 0:
          let year = Date().localTimeString(format: "yyyy")
          let newDateString = year + "/" + property
          guard let date = Date.dateFromISO8601String(dateTimeString: newDateString, format: "yyyy/MM/dd") else {
            assertionFailure()
            return nil
          }
          newWeather.date = date
        case 1:
          newWeather.weatherTime = WeatherTime(string: property)
        case 2:
          guard let lowestTemperature = Int(property) else {
            assertionFailure()
            return nil
          }
          newWeather.lowestTemperature = lowestTemperature
        case 3:
          guard let highestTemperature = Int(property) else {
            assertionFailure()
            return nil
          }
          newWeather.highestTemperature = highestTemperature
        case 4:
          newWeather.description = WeatherDescription(string: property)
        default:
          break
        }
      }
      results.append(newWeather)
    }
    return results
  }
}
