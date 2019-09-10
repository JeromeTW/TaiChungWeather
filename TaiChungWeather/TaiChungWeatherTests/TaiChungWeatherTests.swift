//
//  TaiChungWeatherTests.swift
//  TaiChungWeatherTests
//
//  Created by JEROME on 2019/9/9.
//  Copyright © 2019 jerome. All rights reserved.
//

import XCTest
@testable import TaiChungWeather

class TaiChungWeatherTests: XCTestCase {
  lazy var testBundle = Bundle(for: TaiChungWeatherTests.self)
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testParseXML() {
    let parser = XMLParser(contentsOf: testBundle.url(forResource: "36_08.xml", withExtension: nil)!)!
    let delegate = WeatherParserDelegate()
    parser.delegate = delegate
    if parser.parse() {
      XCTAssert(delegate.weatherItems.count == 2)
      let item = delegate.weatherItems[1]
      
      guard let date = Date.dateFromString(dateTimeString: "Mon, 09 Sep 2019 08:28:17 GMT") else {
        XCTFail("No Date")
        return
      }
      XCTAssert(item.pubDate == date)
      let targetDescription = "\n\t09/09 晚上 溫度:25 ~ 30 晴時多雲<BR>\n\t09/10 白天 溫度:25 ~ 34 晴時多雲<BR>\n\t09/10 晚上 溫度:26 ~ 30 晴時多雲<BR>\n\t09/11 白天 溫度:26 ~ 34 晴時多雲<BR>\n\t09/11 晚上 溫度:26 ~ 31 晴時多雲<BR>\n\t09/12 白天 溫度:26 ~ 34 晴時多雲<BR>\n\t09/12 晚上 溫度:26 ~ 31 晴時多雲<BR>\n\t09/13 白天 溫度:26 ~ 34 晴時多雲<BR>\n\t09/13 晚上 溫度:26 ~ 31 晴時多雲<BR>\n\t09/14 白天 溫度:26 ~ 34 晴時多雲<BR>\n\t09/14 晚上 溫度:26 ~ 31 晴時多雲<BR>\n\t09/15 白天 溫度:26 ~ 33 晴午後短暫雷陣雨<BR>\n\t09/15 晚上 溫度:26 ~ 30 多雲短暫陣雨<BR>\n\t09/16 白天 溫度:26 ~ 33 晴午後短暫雷陣雨<BR>\n\t"
      XCTAssert(item.description == targetDescription)
      
    } else {
      XCTFail("Parse Failed")
    }
  }
  
  func testNetwork() {
    let promise = expectation(description: "Status code: 200")
    let mockLoader = MockWeatherLoader(dataFromInternetSuccessHandler: {
      print("success")
      promise.fulfill()
    }) {
      print("failed")
      XCTFail("Failed")
    }
    
    mockLoader.load()
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}

class MockWeatherLoader: WeatherLoader {
  func load() {
    let url = URL(string: "https://8bab610e-10b8-4dfb-88ef-5870bfe076f7.mock.pstmn.io")!
    let request = APIRequest(url: url)
    let operation = NetworkRequestOperation(request: request) { [weak self] result in
      guard let self = self else {
        assertionFailure()
        return
      }
      switch result {
      case .success(let response):
        if let data = response.body {
          let parser = XMLParser(data: data)
          let delegate = WeatherParserDelegate()
          parser.delegate = delegate
          DispatchQueue.main.async {
            if parser.parse() {
              guard let operation = self.requestOperationDictionary[url] else {
                return
              }
              // parse
              guard operation.isCancelled == false else {
                return
              }
              let coreDataConnect = CoreDataConnect(context: self.context)
              let item = delegate.weatherItems[1]
              let temp = NSPredicate(format: "time = %@", item.pubDate as CVarArg)
              guard let results = coreDataConnect.retrieveWeekWeatherResults(predicate: temp, sort: nil, limit: 1), results.isEmpty else {
                printLog("The record is already existed.")
                return
              }
              // insert
              let insertResult = coreDataConnect.insert(
                Constant.weatherEntityName, attributeInfo: [
                  Constant.timeKey: item.pubDate as Any,
                  Constant.contentKey: item.description as Any
                ])
              if insertResult {
                printLog("Insert successfully.")
              } else {
                printLog("Insert failed.", level: .error)
              }
            } else {
              printLog("parse failed", level: .error)
            }
            self.dataFromInternetSuccessHandler()
            self.requestOperationDictionary.removeValue(forKey: url)
          }
        }
        
      case .failure:
        printLog("failed", level: .debug)
        DispatchQueue.main.async {
          self.dataFromInternetFailedHandler()
          self.requestOperationDictionary.removeValue(forKey: url)
        }
      }
    }
    requestOperationDictionary[url] = operation
    queue.addOperation(operation)
  }
}
