//
//  AHFuture.swift
//  Pods
//
//  Created by Alex Hmelevski on 2017-04-08.
//
//

import Foundation
import ALEither

public class AHFuture<Value, E>: AHAsync<ALEither<Value, E>> {
    public required init(scope:  @escaping (@escaping (ALEither<Value, E>) -> Void) -> Void) {
        super.init(scope: scope)
    }
    
    public func onSuccess(callback: @escaping (Value) -> Void) -> Self {
        return onComplete(callback: { $0.do(work: callback) })
    }
    
    public func onFailure(callback: @escaping (E) -> Void) -> Self {
        
        return onComplete(callback: { $0.doIfWrong(work: callback) })
    }
    
    public func map<U>(transform: @escaping (Value) -> U) ->  AHFuture<U,E> {
        return AHFuture<U,E> { completion in
            self.onComplete(callback: { (res) in
                completion(res.map(transform: transform))
            })
            self.execute()
        }
    }
    
    public func flatMap<U>(transform: @escaping (Value) -> AHFuture<U,E>) ->  AHFuture<U,E> {
        return AHFuture<U,E> { completion in
            self.onComplete(callback: { (res) in
                res.map(transform: transform)
                    .do(work: { (future) in
                        future.onComplete(callback: completion)
                        future.execute()
                    })
                    .doIfWrong(work: { completion(.wrong(value: $0))})
            })
            self.execute()
        }
    }
    
    public func filter(predicate: @escaping (Value) -> Bool) -> AHFuture<Value,E> {
        return AHFuture<Value,E> { completion in
            
            self.onComplete(callback: { (res) in
                res.take(if: predicate).do(work: { completion($0) })
            })
            self.execute()
        }
    }
    
    public func filter(predicate: @escaping (Value) -> Bool, error: E) -> AHFuture<Value,E> {
        return AHFuture<Value,E> { completion in
            self.onComplete(callback: { (res) in
                completion(res.takeIf(predicate: predicate, wrong: error))
            })
            self.execute()
        }
    }
    
    public func recover(transform: @escaping (E) -> Value) -> AHFuture<Value,E> {
        return AHFuture{ completion in
            self.onComplete(callback: { (res) in
                
                res.doIfWrong(work: { completion(.right(value: transform($0))) })
                   .do(work: {completion(.right(value: $0))})
            })
            self.execute()
        }
    }
    
    public func transform<T,U>(transform: @escaping (Value) -> T,
                          transformError: @escaping (E)->U) -> AHFuture<T,U> {
        return AHFuture<T,U>{ completion in
            self.onComplete(callback: { (res) in
                res.do(work: { completion(.right(value: transform($0))) })
                   .doIfWrong(work: { completion(.wrong(value: transformError($0))) })
            })
            self.execute()
        }
    }
    
    public func retry(attempt: Int = 1) -> AHFuture<Value,E> {
        return RetryFuture.init(max: attempt, scope: { (completion) in
            
            self.onComplete(callback: { (res) in
                completion(res)
            })
            self.execute()
        })
    }
    
}
