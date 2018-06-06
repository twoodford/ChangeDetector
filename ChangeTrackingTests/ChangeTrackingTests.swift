//
//  ChangeTrackingTests.swift
//  ChangeTrackingTests
//
//  Created by Tim on 6/5/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import XCTest

class ChangeTrackingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let x = TrackedURL(trackURL: URL(string: "/Users/Shared")!)
        let dat = NSMutableData(length: 256)!
        let z1 = NSKeyedArchiver(forWritingWith: dat)
        x.encode(with: z1)
        let z2 = NSKeyedUnarchiver(forReadingWith: dat as Data)
        let y = TrackedURL(coder: z2)!
        print(y.urlStr)
        print(y.url)
        print(y.id)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
