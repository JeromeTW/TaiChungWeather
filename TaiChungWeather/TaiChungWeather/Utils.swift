//
//  Utils.swift
//  groupsync
//
//  Created by JEROME on 2017/10/4.
//  Copyright © 2017年 JEROME. All rights reserved.
//

import UIKit

/// Debug Log.
///
/// - Parameters:
///   - message: log message.
///   - file: log file.
///   - method: log method.
///   - line: log line.
public func DLog<T>(_ message: T,
                    file: String = #file,
                    method: String = #function,
                    line: Int = #line) {
	#if DEBUG
		NSLog("\(file.lastPathComponent)[\(line)], \(method): \(message)")
	#endif
}
