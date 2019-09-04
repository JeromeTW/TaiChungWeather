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
//  var networkController: NetworkController { get }
}

extension NetworkLoader {
//  var networkController: NetworkController {
//    return NetworkController.shared
//  }
}

class WeatherLoader: CoreDataLoader, NetworkLoader {
  lazy var weatherFRC: NSFetchedResultsController<NSFetchRequestResult>! = coreDataConnect.getFRC(Constant.weatherEntityName, predicate: nil, sort: [[Constant.timeKey: false]], limit: 1)
    lazy var downloadsInProgress = [URL : Operation]()
    lazy var downloadQueue: OperationQueue = {
      
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
          }
        }
        
      case .failure:
        print("failed")
        DispatchQueue.main.async {
          self?.completionHandler()
        }
      }
      DispatchQueue.main.async {
        
      }
    }
//    let operation = NetworkRequestOperation().willSend(WeatherRequest()) { (response) in
//      if let e = response.result.error {
//        completion(Result.failed(e))
//        return
//      }
//
//      if let value = response.result.value {
//        guard let string = String(data: value, encoding: .utf8) else {
//          // TODO: Show invalidDecoding Error.
//          return
//        }
//        let parserManager = ParserManager.shared
//        let success = parserManager.parseWeatherXML(xmlString: string)
//        DLog("success:\(success)")
//        if !success {
//          // TODO: Show parse Error.
//        }
//        completion(Result.success(value))
//        return
//      }
//    }
    downloadsInProgress[url] = operation
    downloadQueue.addOperation(operation)
  }
}

struct DailyQuoteLoader: CoreDataLoader {
  
}
