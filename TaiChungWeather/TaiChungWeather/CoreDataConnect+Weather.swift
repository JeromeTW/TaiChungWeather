//
//  CoreDataConnect+Weather.swift
//  TaiChungWeather
//
//  Created by JEROME on 2018/2/5.
//  Copyright © 2018年 jerome. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataConnect {
  public func retrieveWeekWeatherResults(predicate:NSPredicate?, sort:[[String:Bool]]?, limit:Int?) -> [WeekWeather]? {
    guard let results = retrieve(Constant.weatherEntityName, predicate: predicate, sort: sort, limit: limit) as? [WeekWeather] else {
      return nil
    }
    return results
  }
  
  public func retrieveDailyQuoteResults(predicate:NSPredicate?, sort:[[String:Bool]]?, limit:Int?) -> [DailyQuote]? {
    guard let results = retrieve(Constant.dailyQuoteEntityName, predicate: predicate, sort: sort, limit: limit) as? [DailyQuote] else {
      return nil
    }
    return results
  }
}
