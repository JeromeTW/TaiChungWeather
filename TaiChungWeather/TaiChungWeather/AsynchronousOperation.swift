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
/// This class performs all of the necessary KVO of `isFinished` and
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

    // _executing用來暫存isExecuting的值，用來在get中使用。如果return self.isExecuting的話會無限遞歸。自己呼叫自己。
    private var innerExecuting: Bool = false
    override var isExecuting: Bool {
        get {
            return innerExecuting
        }
        set {
            if innerExecuting != newValue {
                // 用KVO技巧，修改父類別中本來是只讀的屬性
                self.willChangeValue(forKey: "isExecuting")
                innerExecuting = newValue
                self.didChangeValue(forKey: "isExecuting")
            }
        }
    }

    private var innerFinished: Bool = false
    override var isFinished: Bool {
        get {
            return innerFinished
        }
        set {
            if innerFinished != newValue {
                self.willChangeValue(forKey: "isFinished")
                innerFinished = newValue
                self.didChangeValue(forKey: "isFinished")
            }
        }
    }

    /// Complete the operation
    ///
    /// This will result in the appropriate KVO of isFinished and isExecuting

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
