//
//  NetworkRequestOperation.swift
//  GP920_iOS
//
//  Created by Howard on 2016/8/15.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import Foundation

class NetworkRequestOperation: AsynchronousOperation {
  
  typealias APIClientCompletionHandler = (Result<APIResponse<Data?>, APIError>) -> Void
  var data: Data?
  var error: NSError?
  
  var startDate: Date!
  private var task: URLSessionTask!
  private var incomingData = NSMutableData()
  private var session: URLSession = {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    return URLSession.init(configuration: config)
  }()
  
  init(request: APIRequest, completionHandler: @escaping APIClientCompletionHandler) {
    super.init()
  
    var urlRequest = URLRequest(url: request.url)
    urlRequest.httpMethod = request.method.rawValue
    urlRequest.httpBody = request.body
  
    request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
  
    task = session.dataTask(with: urlRequest) { (data, response, error) in
    if let error = error {
      completionHandler(.failure(.unknown(error: error)))
    }
  
    guard let httpResponse = response as? HTTPURLResponse else {
      completionHandler(.failure(.requestFailed))
    return
    }
      completionHandler(.success(APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data)))
    }
  }
  
  override func cancel() {
    print("task.cancel()\n")
    task.cancel()
    super.cancel()
  }
  
  override func main() {
    print("task.resume()\n")
    task!.resume()
    startDate = Date()
  }
}