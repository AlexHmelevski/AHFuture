//
//  AHAsyncTests.swift
//  AHFuture
//
//  Created by Alex Hmelevski on 2017-05-03.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import AHFuture

extension DispatchQueue {
    static var currentQueueName: String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }
}

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
    
    func test_executes_on_the_same_threads() {
        var count = 0
        let q = DispatchQueue(label: "Test")
        let asyncOp = AHAsync<Int> { (completion) in
            XCTAssertEqual(DispatchQueue.currentQueueName, "Test")
            completion(1)
        }
        
        asyncOp.onComplete { (c) in
            XCTAssertEqual(DispatchQueue.currentQueueName, "Test")
            count += c
            self.exp.fulfill()
        }.observe(on: q)
         .run(on: q)
         .execute()
        wait(for: [exp], timeout: 10)
        XCTAssertEqual(count, 1)
        
    }
    
    
    func test_executes_on_main_observes_on_global() {
        var count = 0
        let q = DispatchQueue(label: "Test")
        let asyncOp = AHAsync<Int> { (completion) in
            XCTAssert(Thread.current.isMainThread)
           
            completion(1)
            
        }
        
        asyncOp.onComplete{ (c) in
            XCTAssertEqual(DispatchQueue.currentQueueName, "Test")
            count += c
            self.exp.fulfill()
        }.observe(on: q)
         .execute()
        wait(for: [exp], timeout: 10)
        XCTAssertEqual(count, 1)
        
    }
    
    
    
    func test_executes_on_global_observes_on_main() {
        var count = 0
        let q = DispatchQueue(label: "Test")
        let asyncOp = AHAsync<Int> { (completion) in
            XCTAssertEqual(DispatchQueue.currentQueueName, "Test")
            completion(1)
        }
    
        
        asyncOp.onComplete { (c) in
            XCTAssert(Thread.current.isMainThread)
            
            count += c
            self.exp.fulfill()
            }.run(on: q)
             .execute()
        wait(for: [exp], timeout: 10)
        XCTAssertEqual(count, 1)
        
    }
    
}
