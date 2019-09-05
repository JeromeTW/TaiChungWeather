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
  // OperationQueue 搭配 AsynchronousOperation.swift， 既可以使用 Queue 的一些好功能如 maxConcurrentOperationCount，又可以自行控制 Operation 的結束時機。這邊就可以定義當 Response 資料回來後才算是 Operation 的結束。
  // 如果直接沒有繼承 AsynchronousOperation, 直接將 Operation 加到 Queue 中，那麼發送完 Request 後就會是 Operation 的結束時機。
  lazy var queue: OperationQueue = {
    
    var queue = OperationQueue()
    queue.name = "Download Weather queue"
    queue.maxConcurrentOperationCount = 1
    return queue
    
  }()
  
  var dataFromInternetSuccessHandler: (() -> Void)!
  var dataFromInternetFailedHandler: (() -> Void)!
  init(dataFromInternetSuccessHandler: @escaping () -> Void, dataFromInternetFailedHandler: @escaping () -> Void) {
    self.dataFromInternetSuccessHandler = dataFromInternetSuccessHandler
    self.dataFromInternetFailedHandler = dataFromInternetFailedHandler
  }
  
  func isWeatherDataEmpty() -> Bool {
    if coreDataConnect.getCount(Constant.weatherEntityName, predicate: nil) == 0 {
      return true
    } else {
      return false
    }
  }
  
  func fetchWeatherFromInternet() {
    let url = URL(string: "http://www.cwb.gov.tw/rss/forecast/36_08.xml")!
    let request = APIRequest(url: url)
    let operation = NetworkRequestOperation(anAPIRequest: request) { [weak self] result in
      guard let self = self else {
        assertionFailure()
        return
      }
      switch result {
      case .success(let response):
        if let data = response.body {
          let parser = XMLParser(data: data)
          let delegate = WeatherParserDelegate()
          parser.delegate = delegate
          DispatchQueue.main.async {
            if parser.parse() {
              guard let operation = self.requestOperationDictionary[url] else {
                return
              }
              // parse
              guard operation.isCancelled == false else {
                return
              }
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
              DLog("parse failed")
            }
            self.dataFromInternetSuccessHandler()
            self.requestOperationDictionary.removeValue(forKey: url)
          }
        }
        
      case .failure:
        print("failed")
        DispatchQueue.main.async {
          self.dataFromInternetFailedHandler()
          self.requestOperationDictionary.removeValue(forKey: url)
        }
      }
    }
    requestOperationDictionary[url] = operation
    queue.addOperation(operation)
  }
}
