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
  var networkController: NetworkController { get }
}

extension NetworkLoader {
  var networkController: NetworkController {
    return NetworkController.shared
  }
}

struct WeatherLoader: CoreDataLoader, NetworkLoader {
//  var didQueryDailyQuoteHandler: (() -> Void)!
//  let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//  private lazy var coreDataConnect = CoreDataConnect(context: myContext)
  lazy var weatherFRC: NSFetchedResultsController<NSFetchRequestResult>! = coreDataConnect.getFRC(Constant.weatherEntityName, predicate: nil, sort: [[Constant.timeKey: false]], limit: 1)
  
  func fetchWeatherFromInternet(completion: @escaping (Result<Data, Error>) -> Void) {
    let operation = NetworkRequestOperation().willSend(WeatherRequest()) { (response) in
      if let e = response.result.error {
        completion(Result.failed(e))
        return
      }
      
      if let value = response.result.value {
        guard let string = String(data: value, encoding: .utf8) else {
          // TODO: Show invalidDecoding Error.
          return
        }
        let parserManager = ParserManager.shared
        let success = parserManager.parseWeatherXML(xmlString: string)
        DLog("success:\(success)")
        if !success {
          // TODO: Show parse Error.
        }
        completion(Result.success(value))
        return
      }
    }
    networkController.add(operation: operation)
  }
}

struct DailyQuoteLoader: CoreDataLoader {
  
}
