//
//  WeatherNetworkRequest.swift
//  TaiChungWeather
//
//  Created by Jerome.Hsieh on 2018/3/8.
//  Copyright © 2018年 jerome. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MobileCoreServices

class WeatherNetworkRequest: NetworkRequestOperation {
    private let feedWeatherURLString = "http://www.cwb.gov.tw/rss/forecast/36_08.xml"
    override init() {
        super.init()
        guard let url = URL(string: feedWeatherURLString) else {
            assertionFailure()
            return
        }
        initSession(url, method: "GET", headerFields: [:])
    }
    
    override func success(_ data: Data) {
        super.success(data)
    }
    
    override func failure(_ error: NSError, _ data: Data) {
        super.failure(error, data)
    }
}
