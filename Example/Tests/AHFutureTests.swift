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
    
    
    func test_flatMap_called_on_sucess() {
        var f1ScopeCount = 0
        var f2ScopeCount = 0
        let f1 =  AHFuture<Int, TestError> { (completion) in
            f1ScopeCount += 1
            completion(.right(value: 1))
        }
        
        let f2 =  AHFuture<String, TestError> { (completion) in
            f2ScopeCount += 1
            completion(.right(value: String(1)))
            self.exp.fulfill()
        }
        
        f1.flatMap { (Int) -> AHFuture<String, TestError> in
            return f2
        }.execute()
        
        wait(for: [exp], timeout: 10)
        XCTAssertEqual(f1ScopeCount, 1)
        XCTAssertEqual(f2ScopeCount, 1)
    }
    
    
    func test_flatMap_with_retry_called_on_sucess() {
        var f1ScopeCount = 0
        var f2ScopeCount = 0
        let f1 =  AHFuture<Int, TestError> { (completion) in
            f1ScopeCount += 1
            completion(.right(value: 1))
        }
        
        let f2 =  AHFuture<String, TestError> { (completion) in
            f2ScopeCount += 1
            if f2ScopeCount < 3 {
                completion(.wrong(value: TestError.empty))
            } else {
                completion(.right(value: String(1)))
                self.exp.fulfill()
            }
            
        }
        
        f1.flatMap { (Int) -> AHFuture<String, TestError> in
            return f2
        }.retry(attempt: 3)
         .execute()
        
        wait(for: [exp], timeout: 10)
        XCTAssertEqual(f1ScopeCount, 3)
        XCTAssertEqual(f2ScopeCount, 3)
    }
    
    
    func test_filter_continues() {
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            completion(.right(value: 1))
        }.filter(predicate: { $0 == 1 })
            .map(transform: String.init)
            .onSuccess { (str) in
                XCTAssertEqual(str, "1")
                self.exp.fulfill()
                
        }.execute()
        
        wait(for: [exp], timeout: 5)
    }
    
    func test_filter_doesnt_continue() {
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            completion(.right(value: 1))
        }.filter(predicate: { $0 == 0 })
         .map(transform: String.init)
         .onSuccess { (str) in
                XCTFail()
            
        }.execute()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 2)) {
             self.exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    
    func test_filter_map_to_error() {
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            completion(.right(value: 1))
        }.filter(predicate: {$0 == 0}, error: .empty)
         .map(transform: String.init)
         .onSuccess { (str) in XCTFail() }
         .onFailure(callback: { (_) in self.exp.fulfill() })
         .execute()
    
        
        wait(for: [exp], timeout: 5)
    }
    
    
    func test_filter_with_erro_map_returns_success() {
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            completion(.right(value: 1))
         }.filter(predicate: {$0 == 1}, error: .empty)
            .map(transform: String.init)
            .onSuccess { (str) in self.exp.fulfill()  }
            .onFailure(callback: { (_) in XCTFail() })
            .execute()
        
        wait(for: [exp], timeout: 5)
    }
    
    func test_retry_success_after_attempts() {
        
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            if scopeCount > 5 {
                return completion(.right(value: 1))
            } else {
                return completion(.wrong(value: .empty))
            }
        }.retry(attempt: 5)
         .onSuccess { (str) in self.exp.fulfill()  }
         .onFailure(callback: { (_) in XCTFail() })
         .execute()
        
        wait(for: [exp], timeout: 5)
        XCTAssertEqual(scopeCount, 6)
        
    }
    
    
    func test_retry_fails_after_not_enough_attempts() {
        
        var scopeCount = 0
        AHFuture<Int, TestError> { (completion) in
            scopeCount += 1
            if scopeCount > 10 {
                return completion(.right(value: 1))
            } else {
                return completion(.wrong(value: .empty))
            }
         }.retry(attempt: 5)
          .onSuccess { (str) in XCTFail() }
          .onFailure(callback: { (_) in self.exp.fulfill()  })
          .execute()
        
        wait(for: [exp], timeout: 5)
        XCTAssertEqual(scopeCount, 6)
        
    }
    
    
    func test_recover_calls_on_success_for_successFalue() {
         AHFuture<Int, TestError> { (completion) in
            
            completion(.right(value: 1))
         }
          .map(transform: String.init)
          .recover(transform: {_ in String("RECOVERED")})
          .onSuccess { (str) in
            
                XCTAssertEqual(str, "1")
                self.exp.fulfill()
                
         }.execute()
        
        wait(for: [exp], timeout: 5)
    }
    
    func test_recover_calls_on_success_for_errorFalue() {
        AHFuture<Int, TestError> { (completion) in
            completion(.wrong(value: TestError.empty))
        }
        .map(transform: String.init)
        .recover(transform: {_ in String("RECOVERED")})
        .onSuccess { (str) in
                
                XCTAssertEqual(str, "RECOVERED")
                self.exp.fulfill()
                
        }
        .execute()
        
        wait(for: [exp], timeout: 5)
    }
}
