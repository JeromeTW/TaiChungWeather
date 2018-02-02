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

public typealias DoneHandler = (_ error: Error?) -> Void

class NetworkController {
  static let shared = NetworkController()  // Singleton
  public var didQueryWeatherHandler: DoneHandler?
  
  private let feedWeatherURLString = "http://www.cwb.gov.tw/rss/forecast/36_08.xml"
  private init() {
    requestWeatherData()
  }
  
  public func requestWeatherData() {
    guard let url = URL(string: feedWeatherURLString) else {
      assertionFailure()
      return
    }
    let urlRequest = URLRequest(url: url)
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: urlRequest, completionHandler: { [unowned self] data, response, error in
      if let error = error {
        self.didQueryWeatherHandler?(error)
      return
      }
      guard let data = data, let string = String(data: data, encoding: .utf8) else {
        // TODO:
        return
      }
      print(string)
      
      self.didQueryWeatherHandler?(nil)
    })
    task.resume()
  }
}
