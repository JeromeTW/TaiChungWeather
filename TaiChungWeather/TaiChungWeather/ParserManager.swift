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
  public var didQueryWeatherHandler: DoneHandler?
  
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
    
    // insert
    let insertResult = coreDataConnect.insert(
      Constant.weatherEntityName, attributeInfo: [
        Constant.timeKey : pubDateString,
        Constant.contentKey : weekWeatherString
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

