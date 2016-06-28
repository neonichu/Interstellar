//
//  WarpDriveTests.swift
//  WarpDriveTests
//
//  Created by Jens Ravens on 13/10/15.
//  Copyright © 2015 nerdgeschoss GmbH. All rights reserved.
//

import Foundation
import XCTest
@testable import Interstellar

class DebounceTests: XCTestCase {

    func testDebounceImmediateley() {
        var string: String? = nil
        let s = Signal<String>()
        _ = s.debounce(0).next { string = $0 }
        s.update("Hello")
        XCTAssertEqual(string, "Hello")
    }
    
    func testDebounceImmediatelyIfFirst () {
        var string: String? = nil
        let s = Signal<String>()
        _ = s.debounce(5).next { string = $0 }
        s.update("Hello")
        XCTAssertEqual(string, "Hello")
    }
    
    func testCallStoring() {
        let date = Date()
        let signal = Signal<Int>()
        signal.lastCalled = date
        XCTAssertEqual(signal.lastCalled, date)
    }
    
    func testDebounce() {
        var string: String? = nil
        var called = 0
        let signal = Signal<String>()
        let expectation = self.expectation(withDescription: "Wait for debounce")
        
        _ = signal.debounce(0.5).next { called += 1; string = $0 }
        signal.update("Hello")
        signal.update("World")
        
        _ = Signal(0).delay(1).next { _ in
            XCTAssertEqual(called, 2)
            XCTAssertEqual(string, "World")
            expectation.fulfill()
        }
        
        XCTAssertEqual(called, 1)
        XCTAssertEqual(string, "Hello")
        waitForExpectations(withTimeout: 2, handler: nil)
    }
    
}
