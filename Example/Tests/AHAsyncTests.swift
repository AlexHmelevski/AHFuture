//
//  AHAsyncTests.swift
//  AHFuture
//
//  Created by Alex Hmelevski on 2017-05-03.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import AHFuture



class AHAsyncTests: XCTestCase {
    var exp: XCTestExpectation!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        exp = expectation(description: "AHSyncOP")
    }
    
    func test_runs_callbacks() {
        var count = 0
        
        let asyncOp = AHAsync<Int> { (completion) in
            completion(1)
        }
        
        asyncOp.onComplete(callback: { count += $0 })
               .onComplete(callback: { count += $0 })
               .onComplete(callback: { (c) in
                count += c
                self.exp.fulfill()
                
               }).execute()
        
        
        wait(for: [exp], timeout: 10)
        XCTAssertEqual(count, 3)
        
    }
    
}
