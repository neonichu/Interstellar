// Threading.swift
//
// Copyright (c) 2015 Jens Ravens (http://jensravens.de)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/**
    This error is thrown if the signal doesn't complete within the specified timeout in a wait function.
 */
public struct TimeoutError: ErrorProtocol {
    internal init() {}
}

#if os(Linux)
#else
internal extension TimeInterval {
    var dispatchTime: DispatchTime {
        return DispatchTime.now() + Double(Int64(self * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    }
}
#endif

public extension Signal {
    #if os(Linux)
    #else
    /**
        Wait until the signal updates the next time. This will block the current thread until there 
        is an error or a successfull value. In case of an error, the error will be thrown.
    */
    public func wait(_ timeout: TimeInterval? = nil) throws -> T {
        let group = DispatchGroup()
        var result: Result<T>?
        group.enter()
        _ = subscribe { r in
            result = r
            group.leave()
        }
        let timestamp = timeout.map{ $0.dispatchTime } ?? DispatchTime.distantFuture
        if group.wait(timeout: timestamp) == .TimedOut {
            throw TimeoutError()
        }
        switch result! {
        case let .Success(t): return t
        case let .Error(e): throw e
        }
    }
    #endif
}
