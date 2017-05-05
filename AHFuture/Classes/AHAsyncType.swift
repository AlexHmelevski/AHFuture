//
//  AHAsyncType.swift
//  Pods
//
//  Created by Alex Hmelevski on 2017-04-08.
//
//

import Foundation

public protocol AHAsyncType {
    associatedtype Res
    var result: Res? { get }
    init(scope:  @escaping (@escaping(Res) -> Void) -> Void)
    
    func onComplete(callback: @escaping (Res) -> Void) -> Self
}
