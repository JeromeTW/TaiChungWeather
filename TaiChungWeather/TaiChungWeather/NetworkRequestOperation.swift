//
//  NetworkRequestOperation.swift
//  GP920_iOS
//
//  Created by Howard on 2016/8/15.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

class NetworkRequestOperation: AsynchronousOperation, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

    var data: Data?
    var error: NSError?
    
    var startDate: Date!
    private var task: URLSessionTask!
    private var incomingData = NSMutableData()
    private var session: Foundation.URLSession?
    private var timeoutIntervalForRequest: Double = 60  // default 60 sec
    private var timeoutIntervalForResource: Double = 7 * 24 * 60 * 60   // default 7 day (7 * 24 * 60 * 60)

    init (_ url: URL, method: String, additionalHeaders: [AnyHashable: Any]? = nil, headerFields: [String : String]? = nil, body: Data? = nil) {
        super.init()
      
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        let urlconfig = URLSessionConfiguration.default
        // 新增 timeout, 並realod & Ignoring 本地的cacheData(取得最新的cacheData)
        urlconfig.timeoutIntervalForRequest = timeoutIntervalForRequest
        urlconfig.timeoutIntervalForResource = timeoutIntervalForResource
        urlconfig.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData

        if let headerFields = headerFields {
          for (key, value) in headerFields {
            request.setValue(value, forHTTPHeaderField: key)
          }
        }

        if let additionalHeaders = additionalHeaders {
            urlconfig.httpAdditionalHeaders = additionalHeaders
        }

        if let body = body {
            request.httpBody = body
        }

        session = Foundation.URLSession(
            configuration: urlconfig,
            delegate: self,
            delegateQueue: nil)

        task = session!.dataTask(with: request as URLRequest)
    }

    override func cancel() {
        DLog("task.cancel()\n")
        task.cancel()
        super.cancel()
    }

    override func main() {
        DLog("task.resume()\n")
        task!.resume()
        startDate = Date()
    }

    // MARK: NSURLSessionTaskDelegate methods
    // - URLSession:task:didCompleteWithError:
    // - URLSession:task:didReceiveChallenge:completionHandler:
    // - URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:
    // - URLSession:task:needNewBodyStream:
    // - URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if isCancelled {
            isFinished = true
            task.cancel()
            return
        }

        if let error = self.error {
            failure(error, incomingData as Data)
        } else {
            success(incomingData as Data)
        }

        isFinished = true
        completeOperation()
    }

    // If you are using data or upload tasks,
    // also implement the methods in the NSURLSessionDataDelegate protocol.
    // - URLSession:dataTask:didReceiveResponse:completionHandler:
    // - URLSession:dataTask:didBecomeDownloadTask:
    // - URLSession:dataTask:didBecomeStreamTask:
    // - URLSession:dataTask:didReceiveData:
    // - URLSession:dataTask:willCacheResponse:completionHandler:

    func urlSession(_ session: Foundation.URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (Foundation.URLSession.ResponseDisposition) -> Void) {
        if isCancelled {
            isFinished = true
            task!.cancel()
            return
        }

        // Recieved a new request, clear out the data object
        self.incomingData = NSMutableData()

        DLog("Check the response code and react appropriately")
        DLog(response)

        if let httpResponse = response as? HTTPURLResponse {
            DLog("statusCode \(httpResponse.statusCode)")
            if httpResponse.statusCode / 100 == 2 ||  httpResponse.statusCode == 422 {
                // donothing
            } else {
                if httpResponse.statusCode == 900 {
                    
                } else {
                    error = NSError(domain: "StatusCode",
                                        code: httpResponse.statusCode,
                                        userInfo: [NSLocalizedDescriptionKey: httpResponse])
                }
            }
        }

        completionHandler(.allow)
    }

    func urlSession(_ session: Foundation.URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        if isCancelled {
            isFinished = true
            task!.cancel()
            return
        }

        incomingData.append(data)
    }

    func success(_ data: Data) {
        self.data = data
    }

    func failure(_ error: NSError, _ data: Data) {
        self.error = error
        self.data = data
        // TODO: Handler error
    }
}

struct NetworkNotification {
  var networkRequestOperationClass = ""
  var isSuccess: Bool
  var errorMessage = ""
  var networkInfo: [String: Any]?
}

// MARK: - Static
extension NetworkRequestOperation {
  static let notificationCenter = NotificationCenter.init()
  /* 外面的使用方式
   customNotificationCenter.addObserver(self, selector: #selector(HiJerome),
   name: NSNotification.Name(rawValue: "HiJerome"), object: nil)
   
   customNotificationCenter.post(name: NSNotification.Name(rawValue: "HiJerome"), object: nil, userInfo: nil)
   NOTE: 可能需要自己做 RemoveObserver
   */
  
  func post(networkNotification: NetworkNotification) {
    NetworkRequestOperation.notificationCenter.post(name: NSNotification.Name(rawValue: networkNotification.networkRequestOperationClass), object: networkNotification)
  }
}
