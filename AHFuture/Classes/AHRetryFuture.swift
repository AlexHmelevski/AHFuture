//
//  AHRetryFuture.swift
//  Pods
//
//  Created by Alex Hmelevski on 2017-04-08.
//
//

import Foundation
import ALEither


class RetryFuture<Value, E> : AHFuture<Value,E> {
    private var count: Int = 0
    
    convenience init(max:Int, scope: @escaping (@escaping (ALEither<Value, E>) -> Void) -> Void) {
        self.init(scope: scope)
        count = max
    }
    
    override func execute() {
        result.do(work: processResult)
              .doIfNone(work: self.runScope)
        
    }
    
    private func processResult(res: Res) {
        res.do(work: { self.runCallbacks(withResult: .right(value: $0)) })
           .doIfWrong { (err) in
                self.count > 0 ? self.runScope() : self.runCallbacks(withResult: .wrong(value: err))
        }
    }
    
    private func runCallbacks(withResult res: Res) {
        self.result = res
        self.callbacks.forEach({$0(res)})
        self.callbacks.removeAll()
    }
    
    private func runScope() {
        scope {res in
            
            res.doIfWrong(work: { (err) in
                self.count -= 1
                self.count >= 0 ? self.runScope() : self.runCallbacks(withResult: .wrong(value: err))
            }).do(work: { (val) in
                self.runCallbacks(withResult: .right(value: val))
            })
            
        }
    }
}
