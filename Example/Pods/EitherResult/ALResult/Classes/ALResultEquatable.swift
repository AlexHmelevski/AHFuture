//
//  ALResult_Equatable.swift
//  ALResult
//
//  Created by Piyush Sharma on 2019-03-20.
//

import Foundation

extension ALResult: Equatable where R: Equatable {
    public static func == (lhs: ALResult<R>, rhs: ALResult<R>) -> Bool {
        switch (lhs, rhs) {
        case let (.right(valL), .right(valR)): return valL == valR
        case let (.wrong(errorL), .wrong(errorR)): return errorL.localizedDescription == errorR.localizedDescription
        default: return false
        }
    }
    
    public static func != (lhs: ALResult<R>, rhs: ALResult<R>) -> Bool {
        switch (lhs, rhs) {
        case let (.right(valL), .right(valR)): return valL != valR
        case let (.wrong(errorL), .wrong(errorR)): return errorL.localizedDescription != errorR.localizedDescription
        default: return false
        }
    }
}
