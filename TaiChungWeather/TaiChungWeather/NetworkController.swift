//
//  NetworkController.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/2.
//  Copyright © 2018年 jerome. All rights reserved.
//
//  Source: https://academy.realm.io/posts/slug-marcus-zarra-exploring-mvcn-swift/?w=1

import Foundation
import CoreData

public typealias DataHandler = (_ data: Data?, _ error: Error?) -> Void
public typealias DoneHandler = (_ error: Error?) -> Void

public enum NetworkError: Error {
  case unknown
  case noData
  case invalidDecoding
  case invalidParse
}

class NetworkController {
  static let shared = NetworkController()  // Singleton
  public var didQueryWeatherHandler: DoneHandler?
  public var didQueryDailyQuoteHandler: DoneHandler?
  private let parserManager = ParserManager.shared
  
  private let feedWeatherURLString = "http://www.cwb.gov.tw/rss/forecast/36_08.xml"
  private let dailyQuoteURLString = "https://tw.appledaily.com/index/dailyquote/"
  
  private init() {
    requestWeatherData()
    requestDailyQuoteData()
  }
  
  private func request(url: URL, completionHandler: DataHandler?) {
    let urlRequest = URLRequest(url: url)
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
      if let error = error {
        completionHandler?(nil, error)
        return
      }
      guard let data = data else {
        completionHandler?(nil, NetworkError.noData)
        return
      }
      completionHandler?(data, nil)
    })
    task.resume()
  }
  
  public func requestWeatherData() {
    guard let url = URL(string: feedWeatherURLString) else {
      assertionFailure()
      return
    }
    request(url: url) { data, error in
      guard error == nil else {
        self.didQueryWeatherHandler?(error)
        return
      }
      guard let data = data else {
        assertionFailure()  // Should not be here.
        return
      }
      guard let string = String(data: data, encoding: .utf8) else {
        self.didQueryWeatherHandler?(NetworkError.invalidDecoding)
        return
      }
      let success = self.parserManager.parseWeatherXML(xmlString: string)
      if success {
        self.didQueryWeatherHandler?(nil)
      } else {
        self.didQueryWeatherHandler?(NetworkError.invalidParse)
      }
    }
  }
  
  public func requestDailyQuoteData() {
    guard let url = URL(string: dailyQuoteURLString) else {
      assertionFailure()
      return
    }
    request(url: url) { data, error in
      guard error == nil else {
        self.didQueryDailyQuoteHandler?(error)
        return
      }
      guard let data = data else {
        assertionFailure()  // Should not be here.
        return
      }
      guard let string = String(data: data, encoding: .utf8) else {
        self.didQueryDailyQuoteHandler?(NetworkError.invalidDecoding)
        return
      }
      let success = self.parserManager.parseWeatherXML(xmlString: string)
      if success {
        self.didQueryDailyQuoteHandler?(nil)
      } else {
        self.didQueryDailyQuoteHandler?(NetworkError.invalidParse)
      }
    }
  }
}
