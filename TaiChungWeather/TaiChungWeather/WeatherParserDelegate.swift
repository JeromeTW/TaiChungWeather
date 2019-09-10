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
  // 保存最终解析的结果
  var weatherItems: [WeatherItem] = []

  // 当前元素名
  var currentElement = ""

  // 当前 WeatherItem
  var weatherItem: WeatherItem!

  func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes _: [String: String] = [:]) {
    currentElement = elementName
    if elementName == "item" {
      weatherItem = WeatherItem(description: "", pubDate: Date())
    }
  }

  func parser(_: XMLParser, foundCharacters string: String) {
    guard weatherItem != nil else {
      return
    }
    if currentElement == "pubDate" {
      print("pubdate string:\(string)")
      weatherItem.pubDate = Date.dateFromString(dateTimeString: string)!
    }
  }

  func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
    currentElement = ""
    guard weatherItem != nil else {
      return
    }
    if elementName == "item" {
      weatherItems.append(weatherItem)
      weatherItem = nil
    }
  }

  func parser(_: XMLParser, foundCDATA CDATABlock: Data) {
    guard weatherItem != nil else {
      return
    }
    guard let string = String(data: CDATABlock, encoding: .utf8) else {
      return
    }
    if currentElement == "description" {
      weatherItem.description = string
    }
  }
}
