//
//  AHAsync.swift
//  Pods
//
//  Created by Alex Hmelevski on 2017-04-08.
//
//

import Foundation
import ALEither

public class AHAsync<Result>: AHAsyncType {
    
    public typealias Res = Result
    
    typealias  Callback = (Result) -> Void
    internal var callbacks = [Callback]()
    
    public var result: AHAsync.Res?
    public let scope: (@escaping(Result) -> Void) -> Void
    
    private var executionQueue: DispatchQueue = .main
    private var observingQueue: DispatchQueue = .main
    
    @discardableResult
    public func onComplete(callback: @escaping (Result) -> Void) -> Self {
        let main: Callback = { res in
            self.observingQueue.async {
                callback(res)
            }
        }
        
        callbacks.append(main)
        return self
    }
    
    public required init(scope: @escaping (@escaping(Result) -> Void) -> Void) {
        self.scope = scope
    }
    
    open func execute() {
        executionQueue.async {
            self.runScope()
        }
    }
    
    open func observe(on queue: DispatchQueue) -> Self {
        observingQueue = queue
        return self
    }
    
    open func run(on queue: DispatchQueue) -> Self {
        executionQueue = queue
        return self
    }
    
    private func runScope() {
        scope { res in
            self.runCallbacks(withResult: res)
        }
    }
    
    private func runCallbacks(withResult res: Res) {
        self.callbacks.forEach({$0(res)})
        self.callbacks.removeAll()
    }
    
}
