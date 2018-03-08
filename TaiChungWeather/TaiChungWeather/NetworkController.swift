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
import WebKit

public typealias DataHandler = (_ data: Data?, _ error: Error?) -> Void
public typealias DoneHandler = (_ error: Error?) -> Void

public enum NetworkError: Error {
  case unknown
  case noData
  case invalidDecoding
  case invalidParse
}

protocol NetworkControllerDelegate: class {
    func completedNetworkRequest(_ requestClassName: String, response: Data?, error: NSError?)
}

class NetworkController: NSObject, WKNavigationDelegate {
  static let shared = NetworkController()  // Singleton
  public var didQueryWeatherHandler: DoneHandler?
  private(set) var isQueryWeatherFinished = false
  public var didQueryDailyQuoteHandler: DoneHandler?
  private(set) var isQueryDailyQuoteFinished = false
  private let parserManager = ParserManager.shared
  
  private let dailyQuoteURLString = "https://tw.appledaily.com/index/dailyquote/"
  
  private var webView: WKWebView! // Use WKWebView to fetch daily quote. Use desktop version to view website.
  
    private var delegates: [NetworkControllerDelegate] = []
  private override init() {
    super.init()
    guard currentReachabilityStatus != .notReachable else {
      return
    }
    requestWeatherData()
    requestDailyQuoteData()
  }
  
    // New Code
    /// Serial NSOperationQueue for downloads
    let queue: OperationQueue = {
        let _queue = OperationQueue()
        _queue.name = "netqueue"
        _queue.maxConcurrentOperationCount = 4
        
        return _queue
    }()
    
    func addDelegate(_ delegate: NetworkControllerDelegate) {
        delegates.append(delegate)
    }
    
    func removeDelegate(_ delegate: NetworkControllerDelegate) {
        delegates = delegates.filter {$0 !== delegate}
    }
    
  private func request(url: URL, completionHandler: DataHandler?) {
    let urlRequest = URLRequest(url: url)
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
      if let error = error {
        completionHandler?(nil, error)
        return
      }
      guard let data = data else {
        completionHandler?(nil, NetworkError.noData)
        return
      }
      completionHandler?(data, nil)
    })
    task.resume()
  }
    public func requestWeatherData() {
        let operation = WeatherNetworkRequest()
        operation.addObserver(self, forKeyPath: "isFinished", options: .new, context: nil)
        queue.addOperation(operation)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let operation = (object as? NetworkRequestOperation)!
        let className = String(describing: type(of: operation))
        
        for delegate in self.delegates {
            DLog(delegate)
            delegate.completedNetworkRequest(className,
                                             response: operation.data as Data?,
                                             error: operation.error)
        }
        
        DLog("queue.operationCount \(queue.operationCount)")
    }
    
  public func requestDailyQuoteData() {
    guard let url = URL(string: dailyQuoteURLString) else {
      assertionFailure()
      return
    }
    isQueryDailyQuoteFinished = false
    let webConfiguration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: webConfiguration)
    webView.navigationDelegate = self
    // Use desktop version.
    webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"

    let myRequest = URLRequest(url: url)
    webView.load(myRequest)
  }
  
  // MARK: - WKNavigationDelegate
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    DLog("didFinish")
    webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                               completionHandler: { [weak self] (html: Any?, error: Error?) in
                                // Charge html content is redirection content or real content.
                                let maxLength = 100
                                if let string = html as? String, string.lengthOfBytes(using: .utf8) > maxLength {
                                  self?.webView = nil
                                  self?.isQueryDailyQuoteFinished = true
                                  guard let success = self?.parserManager.parseDailyQuoteHTML(htmlString: string) else {
                                    return
                                  }
                                  if success {
                                    self?.didQueryDailyQuoteHandler?(nil)
                                  } else {
                                    self?.didQueryDailyQuoteHandler?(NetworkError.invalidParse)
                                  }
                                }
    })
  }
}
