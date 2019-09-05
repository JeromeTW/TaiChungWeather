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
  //  private func fetchDataDailyQuote() {
  //    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  //    let coreDataConnect = CoreDataConnect(context: myContext)
  //
  //    if let results = coreDataConnect.retrieveDailyQuoteResults(predicate: nil, sort: [[Constant.timeKey: false]], limit: 1) {
  //      guard results.count == 1 else {
  //        // First time launch the app without history record.
  //        KRProgressHUD.appearance().style = .black
  //        KRProgressHUD.set(deadline: 999999.9)
  //        KRProgressHUD.showInfo(withMessage: R.string.localizable.loading())
  //        return
  //      }
  //      dailyQuote = results[0]
  //    }
  //  }
  func isDailyQuoteDataEmpty() -> Bool {
    if coreDataConnect.getCount(Constant.dailyQuoteEntityName, predicate: nil) == 0 {
      return true
    } else {
      return false
    }
  }
  
  
  
  //  private func queryNewDataFromInternet() {
  //    guard currentReachabilityStatus != .notReachable else {
  ////      weatherListTableView.dg_stopLoading()
  //      // Show alert.
  //      showOKAlert(R.string.localizable.internetNotReachable(), message: nil, okTitle: R.string.localizable.ok())
  //      return
  //    }
  //    guard networkController.isQueryDailyQuoteFinished && networkController.isQueryWeatherFinished else {
  //      return
  //    }
  //    networkController.requestDailyQuoteData()
  //    NetworkController.shared.addDelegate(self)
  //    networkController.requestWeatherData()
  //  }
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
                                guard let self = self else {
                                  assertionFailure()
                                  return
                                }
                                // Charge html content is redirection content or real content.
                                let maxLength = 100
                                if let string = html as? String, string.lengthOfBytes(using: .utf8) > maxLength {
                                  self.webView = nil
                                  let success = ParserManager.shared.parseDailyQuoteHTML(htmlString: string)
                                  if success {
                                    self.dataFromInternetSuccessHandler()
                                  } else {
                                    self.dataFromInternetFailedHandler()
                                  }
                                } else {
                                  self.dataFromInternetFailedHandler()
                                }
    })
  }
}
