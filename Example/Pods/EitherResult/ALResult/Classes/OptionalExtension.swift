//
//  OptionalExtension.swift
//  ALResult
//
//  Created by Aldo Temp on 2018-10-25.
//

import Foundation

infix operator »: transformOperator

precedencegroup transformOperator {
    associativity: left
}

public func »<T,U>(input: T, transform: (T) -> U) -> U {
    return transform(input)
}

extension Optional {
    
    /// Conditional function, returns Either with valid value according to predicate block
    /// If predicate false - returns nil
    /// - Parameter predicate: (Wrapped) -> Bool
    /// - Returns: Wrapped?
    
    public func filter(if predicate: (Wrapped) -> Bool) -> Wrapped? {
        switch self {
        case .some(let val): return predicate(val) ? self : nil
        case .none: return self
        }
    }
    
    /// Conditional check for Either returns current state if predicate true or default value
    ///
    /// - Parameters:
    ///   - predicate: (Wrapped) -> Bool
    ///   - default: Wrapped
    /// - Returns: Wrapped?
    
    public func filter(if predicate: (Wrapped) -> Bool, default: Wrapped) -> Wrapped? {
        switch self {
        case .some(let val): return predicate(val) ? self : `default`
        case .none: return self
        }
    }
    
    /// Peform work on a chosen thread(asynchroniously) when a value is available
    ///
    /// - Parameters:
    ///   - queue: Queue where to perform the block
    ///   - work: block of work with value
    /// - Returns: unmodified Wrapped?
    @discardableResult
    public func `do`(_ work:  @escaping (Wrapped) -> Void) -> Wrapped? {
        if case .some(let val) = self {
            work(val)
        }
        return self
    }
    
    /// doNone function allows to perform some work if the result is none,
    ///
    /// - Parameter work: Block of work
    /// - Returns: Wrapped?
    @discardableResult
    public func onNone(_ work: @escaping () -> Void) -> Wrapped? {
        if case .none = self {
            work()
        }
        return self
    }
    
    @discardableResult
    public func debug(message: String? = nil) -> Wrapped? {
        message.do({ debugPrint($0 + " " + "\(String(describing: self))") })
               .onNone({ debugPrint(self ?? "nil") })
        return self
    }
    
}
