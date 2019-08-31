//
//  NewNetworkController.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/7/7.
//  Copyright © 2019 jerome. All rights reserved.
//

import Foundation

class NewNewNetworkController {
  static let shared = NewNewNetworkController()  // Singleton
  
  private let queue: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "networkQueue"
    queue.maxConcurrentOperationCount = 4
    
    return queue
  }()
  
  private init() {
    
  }
}
