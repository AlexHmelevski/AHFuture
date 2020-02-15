//
//  ALResult.swift
//  ALResult
//
//  Created by Alex Hmelevski on 2018-05-23.
//

import Foundation
public enum ALResult<R> {
    
    case right(R)
    case wrong(Error)
    
    public init(_ value: R) {
        self = .right(value)
    }
    
    public init(_ wrong: Error) {
        self = .wrong(wrong)
    }
    
    public init(value: R?, error: Error?) {
        if let e = error {
            self = .wrong(e)
            return
        }
        
        if let v = value {
            self = .right(v)
            return
        }
        self = .wrong(NSError(domain: "ALResult", code: -1, userInfo: ["msg": "Couldn't create monad out of 2 optionals"]))
    }
    
    // MARK: FUNCTIONAL
    
    /// Map function calls transfrom function on value if it Right, if wrong returns
    /// current state
    /// - Parameter transform: function to apply
    /// - Returns: ALEither<U, E>
    public func map<U>(_ transform: (R) throws -> U) -> ALResult<U> {
        do {
            switch self {
            case .right(let val): return .right(try transform(val))
            case .wrong(let err): return .wrong(err)
            }
        } catch {
            return .wrong(error)
        }
    }

    
    /// Conditional check for Either returns current state if predicate true or default value
    ///
    /// - Parameters:
    ///   - predicate: (Right) -> Bool
    ///   - default: Default value
    /// - Returns: ALEither<R, E>
    
    public func filter(_ predicate: (R) throws -> Bool, default: R) -> ALResult<R> {
        do {
            switch self {
            case .right(let val): return try predicate(val) ? self : .right(`default`)
            case .wrong: return self
            }
        } catch {
             return .wrong(error)
        }
    }
    
    /// Conditional check for Either returns current state if predicate true or an error value
    ///
    /// - Parameters:
    ///   - predicate: (Right) -> Bool
    ///   - default: Default error
    /// - Returns: ALEither<R, E>
    public func filter(_ predicate: (R) -> Bool, error: Error) -> ALResult<R> {
        switch self {
        case .right(let val): return predicate(val) ? self : .wrong(error)
        case .wrong: return self
        }
    }
    
    public func flatMap<U>(_ f: (R) throws -> ALResult<U>) -> ALResult<U> {
        do {
            switch self {
            case .right(let val): return try f(val)
            case .wrong(let err): return .wrong(err)
            }
        } catch {
            return .wrong(error)
        }
    }
    
    /// Peform work on a chosen thread(asynchtroniously) when a value is available
    ///
    /// - Parameters:
    ///   - work: block of work with value
    /// - Returns: unmodified ALEither
    @discardableResult
    public func `do`(work: (R) throws -> Void) -> ALResult<R> {
        do {
            if case .right(let val) = self {
               try work(val)
            }
            return self
        } catch {
            return .wrong(error)
        }

    }
    
    /// doIfWrong function allows to perform some work if the result is wrong,
    ///
    /// - Parameter work: Block of work with error
    /// - Returns: ALEither<R, E>
    @discardableResult
    public func onError(_ work: (Error) -> Void) -> ALResult<R> {
        if case .wrong(let err) = self {
            work(err)
        }
        return self
    }
    
    /// onError function allows to perform some work if the result is wrong,
    /// Does additional check for error types
    /// - Parameter work: Block of work with error
    /// - Returns: ALEither<R, E>
    @discardableResult
    public func onError<U>(of type: Error.Type, work: (U) -> Void) -> ALResult<R> {
        if case .wrong(let err) = self {
            if let e = err as? U {
                work(e)
            }
            
        }
        return self
    }
    
    /// onError function allows to perform some work if the result is wrong,
    ///
    /// - Parameter work: Block of work with error
    /// - Returns: ALEither<R, E>
    @discardableResult
    public func onError(if predicate: (Error) -> Bool, work: (Error) -> Void) -> ALResult<R> {
        if case .wrong(let err) = self {
            work(err)
        }
        return self
    }
    
    public func fork(right: ((R) throws ->Void)?, wrong: ((Error) -> Void)?) {
        do {
            switch self {
            case let .right(val): try right?(val)
            case let .wrong(err): wrong?(err)
            }
        } catch {
            wrong?(error)
        }
        
    }
    
    /// Allows to provide default value in case of error
    ///
    /// - Parameter value: Default value
    /// - Returns: ALEither<Right>
    public func drive(value: R) -> ALResult<R> {
        if case .wrong = self {
            return .right(value)
        }
        return self
    }
}
