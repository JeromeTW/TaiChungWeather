//
//  AsynchronousOperation.swift
//  MorningPic
//
//  Created by 呂正偉 on 2016/6/30.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import Foundation
import MobileCoreServices

/// Asynchronous Operation base class
///
/// This class performs all of the necessary KVN of `isFinished` and
/// `isExecuting` for a concurrent `NSOperation` subclass. So, to developer
/// a concurrent NSOperation subclass, you instead subclass this class which:
///
/// - must override `main()` with the tasks that initiate the asynchronous task;
///
/// - must call `completeOperation()` function when the asynchronous task is done;
///
/// - optionally, periodically check `self.cancelled` status, performing any clean-up
///   necessary and then ensuring that `completeOperation()` is called; or
///   override `cancel` method, calling `super.cancel()` and then cleaning-up
///   and ensuring `completeOperation()` is called.

class AsynchronousOperation : Operation {

    override var isAsynchronous: Bool { return true }

    // _executing用來暫存isExecuting的值，用來在get中使用。如果return self.isExecuting的話會無限遞歸。自己呼叫自己。
    fileprivate var _executing: Bool = false
    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                // 用KVN技巧，修改父類別中本來是只讀的屬性
                self.willChangeValue(forKey: "isExecuting")
                _executing = newValue
                self.didChangeValue(forKey: "isExecuting")
            }
        }
    }

    fileprivate var _finished: Bool = false
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                self.willChangeValue(forKey: "isFinished")
                _finished = newValue
                self.didChangeValue(forKey: "isFinished")
            }
        }
    }

    /// Complete the operation
    ///
    /// This will result in the appropriate KVN of isFinished and isExecuting

    func completeOperation() {
        if isExecuting {
            isExecuting = false
            isFinished = true
        }
    }

    override func start() {
        if isCancelled {
            isFinished = true
            return
        }

        isExecuting = true

        main()
    }
}
