//
//  Created by Pierluigi Cifani on 03/06/15.
//  Copyright (c) 2015 Blur Software SL. All rights reserved.
//

import Foundation

//MARK: Public

infix operator ≈> { associativity left precedence 160 }

public func ≈> <T, U>(lhs: Deferred<Result<T>>, rhs: T -> Deferred<Result<U>>) -> Deferred<Result<U>> {
    let deferred = lhs.bind{ resultToDeferred($0, f: rhs) }
    return deferred
}

public func ≈> <T, U>(lhs: Deferred<T>, rhs: T -> Deferred<Result<U>>) -> Deferred<Result<U>> {
    let deferred = lhs.bind{ rhs($0) }
    return deferred
}

public func ≈> <T, U>(lhs: Deferred<Result<T>>, rhs: T -> Deferred<U>) -> Deferred<Result<U>> {
    let deferred = lhs.bind{ resultToDeferred($0, f: rhs) }
    return deferred
}

//MARK: Private

private func resultToDeferred<T,U>(result: Result<T>, f: T -> Deferred<Result<U>>) -> Deferred<Result<U>> {
    switch result {
    case let .Success(value):
        return f(value)
    case let .Failure(error):
        return Deferred(value: .Failure(error))
    }
}

private func resultToDeferred<T,U>(result: Result<T>, f: T -> Deferred<U>) -> Deferred<Result<U>> {
    switch result {
    case let .Success(value):
        return f(value).bind({Deferred<Result<U>>(value: Result($0))})
    case let .Failure(error):
        return Deferred(value: .Failure(error))
    }
}
