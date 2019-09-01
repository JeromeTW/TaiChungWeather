//
//  ParserManager.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/3.
//  Copyright © 2018年 jerome. All rights reserved.
//

import Foundation
import Ji

class ParserManager {
  static let shared = ParserManager()  // Singleton
//  public var didQueryWeatherHandler: DoneHandler?
  
  private let feedWeatherURLString = "http://www.cwb.gov.tw/rss/forecast/36_08.xml"
  
  private init() {
  }
  
  enum XMLKey: String {
    case item, pubDate, description
  }
  
  
  /// Parse weather XML string.
  ///
  /// - Parameter xmlString: XML string.
  /// - Returns: Return true means success.
  public func parseWeatherXML(xmlString: String) -> Bool {
    /*
     The path to pubdate and week weather description:
       <rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">  // Root Node
       <channel version="2.0">
       <item>
       [1]
       <pubdate> AND <description>[0]
     */
    
    guard let jiDoc = Ji(xmlString: xmlString), let targetItemNode = jiDoc.rootNode?.firstChild?.xPath(XMLKey.item.rawValue)[1] else {
      return false
    }
    guard let pubDateString = targetItemNode.xPath(XMLKey.pubDate.rawValue).first?.content, let weekWeatherString = targetItemNode.xPath(XMLKey.description.rawValue).first?.content else {
      return false
    }
    
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let coreDataConnect = CoreDataConnect(context: myContext)
    
    guard let date = Date.dateFromString(dateTimeString: pubDateString) else {
      assertionFailure()
      return false
    }
    
    let temp = NSPredicate(format: "time = %@", date as CVarArg)
    guard let results = coreDataConnect.retrieveWeekWeatherResults(predicate: temp, sort: nil, limit: 1), results.isEmpty else {
      DLog("The record is already existed.")
      return true
    }
    
    // insert
    let insertResult = coreDataConnect.insert(
      Constant.weatherEntityName, attributeInfo: [
        Constant.timeKey : date as Any,
        Constant.contentKey : weekWeatherString as Any
      ])
    if insertResult {
      DLog("Insert successfully.")
      return true
    } else {
      DLog("Insert failed.")
      return false
    }
  }
  
  /// Parse daily quote HTML string.
  ///
  /// - Parameter htmlString: HTML string.
  /// - Returns: Return true means success.
  public func parseDailyQuoteHTML(htmlString: String) -> Bool {
    // XPath: //*[@id="maincontent"]/div[2]/article
    let xpathString = "//*[@id=\"maincontent\"]/div[2]/article"
    guard let jiDoc = Ji(htmlString: htmlString) else {
      return false
    }
      
    guard let targetNode = jiDoc.xPath(xpathString)?.first else {
      return false
    }
    
    guard let dailyQuoteString = targetNode.xPath("p").first?.content, var authorAndDateString = targetNode.xPath("h1").first?.content, let dateString = targetNode.xPath("h1/time").first?.content else {
      return false
    }
    // Remove the last date string in "誠致教育基金會創辦人 方新舟20180204".
    let numberOfCharactersToRemove = 8
    let range = authorAndDateString.index(authorAndDateString.endIndex, offsetBy: -numberOfCharactersToRemove)..<authorAndDateString.endIndex
    authorAndDateString.removeSubrange(range)
    
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let coreDataConnect = CoreDataConnect(context: myContext)
    let dateFormatString = "yyyyMMdd"
    // NOTE: It will covert to local timezone automatically. dateString is +08 timezone date.
    guard let date = Date.dateFromISO8601String(dateTimeString: dateString, format: dateFormatString) else {
      assertionFailure()
      return false
    }
    
    let temp = NSPredicate(format: "time = %@", date as CVarArg)
    guard let results = coreDataConnect.retrieveDailyQuoteResults(predicate: temp, sort: nil, limit: 1), results.isEmpty else {
      DLog("The record is already existed.")
      return true
    }
    
    // insert
    let insertResult = coreDataConnect.insert(
      Constant.dailyQuoteEntityName, attributeInfo: [
        Constant.timeKey : date as Any,
        Constant.articleKey : dailyQuoteString as Any,
        Constant.authorKey : authorAndDateString as Any
      ])
    if insertResult {
      DLog("Insert successfully.")
      return true
    } else {
      DLog("Insert failed.")
      return false
    }
  }
}

