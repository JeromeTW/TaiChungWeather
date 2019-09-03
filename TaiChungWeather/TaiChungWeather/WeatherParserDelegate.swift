//
//  WeatherParserDelegate.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/9/1.
//  Copyright © 2019 jerome. All rights reserved.
//

import Foundation

struct WeatherItem {
  var description: String
  var pubDate: Date
}

class WeatherParserDelegate: NSObject, XMLParserDelegate {
  //保存最终解析的结果
  var weatherItems: [WeatherItem] = []
  
  //当前元素名
  var currentElement = ""
  
  //当前 WeatherItem
  var weatherItem: WeatherItem!
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    if elementName == "item" {
      weatherItem = WeatherItem(description: "", pubDate: Date())
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if currentElement == "description" {
      weatherItem.description = string
    } else if currentElement == "pubdate" {
      weatherItem.pubDate = Date.dateFromString(dateTimeString: string)!
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "item" {
      weatherItems.append(weatherItem)
    }
  }
}
