//
//  PrintLog.swift
//  TaiChungWeather
//
//  Created by JEROME on 2019/7/29.
//  Copyright © 2019 JEROME. All rights reserved.
//

import UIKit

func printLog(_ items: Any,
              level: LogLevel = .info,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
  #if DEBUG
  if LogLevelConfigurator.shared.logLevels.contains(level) {
    let currentDateString = Date.currentDateString()
    let fileName = file.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
    let logString = "⭐️ [\(currentDateString)][\(level.description)] \(fileName).\(function):\(line) ~ \(items)"

    print(logString)

    if LogLevelConfigurator.shared.shouldShow {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      let logTextView = appDelegate.logTextView

      if logTextView.contentSize.height < logTextView.frame.size.height {
        logTextView.text += "\n\(logString)"
      } else {
        logTextView.text = logString
      }
    }

    if LogLevelConfigurator.shared.shouldCache {
      do {
        try logString.saveLog()
      } catch {
        printLog(error.localizedDescription, level: .error)
      }
    }
  }
  #endif
}

extension String {
  func saveLog() throws {
    guard let cachesDirectory = FileManager.cachesDirectory else { return }
    let filePath = cachesDirectory.appendingPathComponent("\(Date.currentDateString(dateFormat: .yyyyMMdd)).log")
    
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath.path) { // adding content to file
      let fileHandle = FileHandle(forWritingAtPath: filePath.path)
      let content = "\(self)\n"
      fileHandle?.seekToEndOfFile()
      fileHandle?.write(content.data(using: .utf8) ?? Data())
    } else { // create new file
      do {
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"] as? AnyObject
        let buildNumber = infoDictionary["CFBundleVersion"] as? AnyObject
        let header = "Version: \((version as? String)!)\nBuild Number: \((buildNumber as? String)!)\n"
        let content = header + "\(self)\n"
        try content.write(to: filePath, atomically: false, encoding: .utf8)
      } catch {
        throw error
      }
    }
  }
}

extension FileManager {
  static var cachesDirectory: URL? {
    return `default`.urls(for: .cachesDirectory, in: .userDomainMask).first
  }
}
