//
//  AHAsync.swift
//  Pods
//
//  Created by Alex Hmelevski on 2017-04-08.
//
//

import Foundation
import ALEither

class AHAsync<Result>: AHAsyncType {
    
    typealias Res = Result
    
    typealias  Callback = (Result) -> Void
    internal var callbacks = [Callback]()
    
    internal var result: AHAsync.Res?
    internal let scope: (@escaping(Result) -> Void) -> Void
    
    @discardableResult
    func onComplete(onQueue q: DispatchQueue = .main,
                    callback: @escaping (Result) -> Void) -> Self {
        let main: Callback = { res in
            q.async {
                callback(res)
            }
        }
        
        callbacks.append(main)
        return self
    }
    
    internal required init(scope: @escaping (@escaping(Result) -> Void) -> Void) {
        self.scope = scope
    }
    
    open func execute(onQueue q: DispatchQueue = .main) {
        result.do(on: q,  work:  runCallbacks)
              .doIfNone(work: runScope)
    }
    
    private func runScope() {
        scope {res in
            self.runCallbacks(withResult: res)
        }
    }
    
    private func runCallbacks(withResult res: Res) {
        self.callbacks.forEach({$0(res)})
        self.callbacks.removeAll()
    }
    
}
