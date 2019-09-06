//
//  DailyQuoteLoader.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/9/5.
//  Copyright © 2019 jerome. All rights reserved.
//

import Foundation
import CoreData
import WebKit

class DailyQuoteLoader: NSObject, CoreDataLoader {
  lazy var loaderFRC: NSFetchedResultsController<NSFetchRequestResult>! = coreDataConnect.getFRC(Constant.dailyQuoteEntityName, predicate: nil, sort: [[Constant.timeKey: false]], limit: 1)
  // 不能用 loaderFRC.fetchedObjects 因為
  // The value of the property is nil if performFetch() hasn’t been called.
  lazy var coredataRequest: NSFetchRequest<DailyQuote>? = {
    let request: NSFetchRequest<DailyQuote> = DailyQuote.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(DailyQuote.time), ascending: false)]
    request.fetchLimit = 1
    guard let result = try? context.fetch(request) else {
      return nil
    }
    return request
  }()
  
  private var webView: WKWebView! // Use WKWebView to fetch daily quote. Use desktop version to view website.
  var dataFromInternetSuccessHandler: (() -> Void)!
  var dataFromInternetFailedHandler: (() -> Void)!
  
  public var dailyQuote: DailyQuote?
  
  init(dataFromInternetSuccessHandler: @escaping () -> Void, dataFromInternetFailedHandler: @escaping () -> Void) {
    super.init()
    self.dataFromInternetSuccessHandler = dataFromInternetSuccessHandler
    self.dataFromInternetFailedHandler = dataFromInternetFailedHandler
    dailyQuote = loaderFRC.fetchedObjects?.first as? DailyQuote
  }
  
  func isDailyQuoteDataEmpty() -> Bool {
    if coreDataConnect.getCount(Constant.dailyQuoteEntityName, predicate: nil) == 0 {
      return true
    } else {
      return false
    }
  }
  
  func fetchFromInternet() {
    let url = URL(string: "https://tw.appledaily.com/index/dailyquote/")!
    let webConfiguration = WKWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: webConfiguration)
    webView.navigationDelegate = self
    // Use desktop version.
    webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
    
    let myRequest = URLRequest(url: url)
    webView.load(myRequest)
  }
}

extension DailyQuoteLoader: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    DLog("didFinish")
    webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                               completionHandler: { [weak self] (html: Any?, error: Error?) in
                                guard let strongSelf = self else {
                                  assertionFailure()
                                  return
                                }
                                // Charge html content is redirection content or real content.
                                let maxLength = 100
                                if let string = html as? String, string.lengthOfBytes(using: .utf8) > maxLength {
                                  strongSelf.webView = nil
                                  let success = ParserManager.shared.parseDailyQuoteHTML(htmlString: string)
                                  if success {
                                    
                                    guard let request = strongSelf.coredataRequest, let result = try? strongSelf.context.fetch(request), let tempDailyQuote = result.first else {
                                      assertionFailure()
                                      return
                                    }
                                    strongSelf.dailyQuote = tempDailyQuote

                                    strongSelf.dataFromInternetSuccessHandler()
                                  } else {
                                    strongSelf.dataFromInternetFailedHandler()
                                  }
                                } else {
                                  strongSelf.dataFromInternetFailedHandler()
                                }
    })
  }
}
