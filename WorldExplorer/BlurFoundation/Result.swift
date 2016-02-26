//
//  Created by Pierluigi Cifani on 03/06/15.
//  Copyright (c) 2015 Blur Software SL. All rights reserved.
//

import Foundation

/**
*   This is based on https://github.com/owensd/SwiftLib
*   Use like this:
*   func failWhenNilAndReturn(name: String?) -> Result<String> {
*       if let n = name {
*           return Result<String>(n)
*       }
*       else {
*           return .Failure(ErrorType())
*       }
*   }
*/

public enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
    
    public init(_ value: T) {
        self = .Success(value)
    }
    
    public init(_ error: ErrorType) {
        self = .Failure(error)
    }
    
    public var failed: Bool {
        switch self {
        case .Failure:
            return true
            
        default:
            return false
        }
    }
    
    public var error: ErrorType? {
        switch self {
        case .Failure(let error):
            return error
            
        default:
            return nil
        }
    }
    
    public var value: T? {
        switch self {
        case .Success(let value):
            return value
            
        default:
            return nil
        }
    }
    
    public func map<U>(f: T -> U) -> Result<U> {
        switch self {
        case .Failure(let error): return .Failure(error)
        case .Success(let value): return .Success(f(value))
        }
    }
    
    public func bind<U>(f: T -> Result<U>) -> Result<U> {
        switch self {
        case .Failure(let error): return .Failure(error)
        case .Success(let value): return f(value)
        }
    }
}
