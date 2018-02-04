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

class NetworkController: NSObject, WKNavigationDelegate {
  static let shared = NetworkController()  // Singleton
  public var didQueryWeatherHandler: DoneHandler?
  public var didQueryDailyQuoteHandler: DoneHandler?
  private let parserManager = ParserManager.shared
  
  private let feedWeatherURLString = "http://www.cwb.gov.tw/rss/forecast/36_08.xml"
  private let dailyQuoteURLString = "https://tw.appledaily.com/index/dailyquote/"
  
  private var webView: WKWebView! // Use WKWebView to fetch daily quote. Use desktop version to view website.
  
  private override init() {
    super.init()
    requestWeatherData()
    requestDailyQuoteData()
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
    guard let url = URL(string: feedWeatherURLString) else {
      assertionFailure()
      return
    }
    request(url: url) { data, error in
      guard error == nil else {
        self.didQueryWeatherHandler?(error)
        return
      }
      guard let data = data else {
        assertionFailure()  // Should not be here.
        return
      }
      guard let string = String(data: data, encoding: .utf8) else {
        self.didQueryWeatherHandler?(NetworkError.invalidDecoding)
        return
      }
      let success = self.parserManager.parseWeatherXML(xmlString: string)
      if success {
        self.didQueryWeatherHandler?(nil)
      } else {
        self.didQueryWeatherHandler?(NetworkError.invalidParse)
      }
    }
  }
  
  public func requestDailyQuoteData() {
    guard let url = URL(string: dailyQuoteURLString) else {
      assertionFailure()
      return
    }
    
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
                                if let string = html as? String, string.characters.count > maxLength {
                                  self?.webView = nil
                                  DLog("Real Content")
                                  self?.parserManager.parseDailyQuoteHTML(htmlString: string)
                                }
    })
  }
}
