//
//  WeatherLoader.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/8/31.
//  Copyright © 2019 jerome. All rights reserved.
//

import UIKit
import CoreData

protocol CoreDataLoader {
  var context: NSManagedObjectContext { get }
  var coreDataConnect: CoreDataConnect { get }
}

extension CoreDataLoader {
  var context: NSManagedObjectContext {
    return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  }
  
  var coreDataConnect: CoreDataConnect {
    return CoreDataConnect(context: context)
  }
  
}

protocol NetworkLoader {
  var requestOperationDictionary: [URL : Operation] { get set }
  var queue: OperationQueue { get }
}

class WeatherLoader: CoreDataLoader, NetworkLoader {
  lazy var weatherFRC: NSFetchedResultsController<NSFetchRequestResult>! = coreDataConnect.getFRC(Constant.weatherEntityName, predicate: nil, sort: [[Constant.timeKey: false]], limit: 1)
  lazy var requestOperationDictionary = [URL : Operation]()
  lazy var queue: OperationQueue = {
    
    var queue = OperationQueue()
    queue.name = "Download Weather queue"
    queue.maxConcurrentOperationCount = 1
    return queue
    
  }()
  
  var completionHandler: (() -> Void)!
  init(completionHandler: @escaping () -> Void) {
    self.completionHandler = completionHandler
  }
  
  func isWeatherDataEmpty() -> Bool {
    if coreDataConnect.getCount(Constant.weatherEntityName, predicate: nil) == 0 {
      return true
    } else {
      return false
    }
  }
  
  func fetchWeatherFromInternet(completion: @escaping (Result<Data, Error>) -> Void) {
    let url = URL(string: "http://www.cwb.gov.tw/rss/forecast/36_08.xml")!
    let request = APIRequest(url: url)
    let operation = NetworkRequestOperation(anAPIRequest: request) { [weak self] result in
      switch result {
      case .success(let response):
        print("success")
        if let data = response.body {
          let parser = XMLParser(data: data)
          let delegate = WeatherParserDelegate()
          parser.delegate = delegate
          DispatchQueue.main.async {
            if parser.parse() {
              print("parse success")
              let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
              let coreDataConnect = CoreDataConnect(context: myContext)
              let item = delegate.weatherItems[1]
              let temp = NSPredicate(format: "time = %@", item.pubDate as CVarArg)
              guard let results = coreDataConnect.retrieveWeekWeatherResults(predicate: temp, sort: nil, limit: 1), results.isEmpty else {
                DLog("The record is already existed.")
                return
              }
              // insert
              let insertResult = coreDataConnect.insert(
                Constant.weatherEntityName, attributeInfo: [
                  Constant.timeKey : item.pubDate as Any,
                  Constant.contentKey : item.description as Any
                ])
              if insertResult {
                DLog("Insert successfully.")
              } else {
                DLog("Insert failed.")
              }
            } else {
              print("parse failed")
            }
            self?.completionHandler()
            self?.requestOperationDictionary.removeValue(forKey: url)
          }
        }
        
      case .failure:
        print("failed")
        DispatchQueue.main.async {
          self?.completionHandler()
          self?.requestOperationDictionary.removeValue(forKey: url)
        }
      }
      DispatchQueue.main.async {
        
      }
    }
    requestOperationDictionary[url] = operation
    queue.addOperation(operation)
  }
}

struct DailyQuoteLoader: CoreDataLoader {
  
}
