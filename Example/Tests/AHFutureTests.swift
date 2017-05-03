//
//  AHFutureTests.swift
//  AHFuture
//
//  Created by Alex Hmelevski on 2017-05-03.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import AHFuture
import ALEither

enum TestError: Error {
    case empty
}

class AHFutureTests: XCTestCase {
    var exp: XCTestExpectation!
    override func setUp() {
        super.setUp()
        exp = expectation(description: "AHFutureTests")
    }
    

    func test_onSuccess_called() {
        var count = 0
        
        AHFuture<Int, TestError>.init { (completion) in
                completion(.right(value: 1))
        }.onSuccess { _ in count += 1 }
         .onSuccess { _ in count += 1 }
         .onFailure { _ in XCTFail() }
         .onSuccess { (_) in
                count += 1
                self.exp.fulfill()
                
        }.execute()
        
        wait(for: [exp], timeout: 5)
        XCTAssertEqual(count, 3)
    }
    
    func test_onError_called() {
        var count = 0

        AHFuture<Int, TestError> { (completion) in
                completion(.wrong(value: .empty))
        }.onFailure { _ in count += 1 }
         .onFailure { _ in count += 1 }
         .onSuccess { _ in XCTFail() }
         .onFailure { (_) in
                count += 1
                self.exp.fulfill()
                
         }.execute()
        
        wait(for: [exp], timeout: 5)
        XCTAssertEqual(count, 3)
      
    }
    
    
    func test_map_called_on_success() {
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            completion(.right(value: 1))
        }.map(transform: String.init)
         .onSuccess { (str) in
            XCTAssertEqual(str, "1")
            
         }.map(transform: {_ in "secondMap"})
          .onSuccess(callback: { (str) in
                XCTAssertEqual(str, "secondMap")
                self.exp.fulfill()
         })
            
         .execute()
        
        wait(for: [exp], timeout: 5)
        XCTAssertEqual(scopeCount, 1)
    }
    
    
    func test_testIf_continues() {
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            completion(.right(value: 1))
        }.takeIf(predicate: { $0 == 1 })
            .map(transform: String.init)
            .onSuccess { (str) in
                XCTAssertEqual(str, "1")
                self.exp.fulfill()
                
        }.execute()
        
        wait(for: [exp], timeout: 5)
    }
    
    func test_testIf_doesnt_continue() {
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            completion(.right(value: 1))
        }.takeIf(predicate: { $0 == 0 })
         .map(transform: String.init)
         .onSuccess { (str) in
                XCTFail()
            
                
        }.execute()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 2)) {
             self.exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
       
    }
}
