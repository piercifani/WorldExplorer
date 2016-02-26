//
//  Created by Pierluigi Cifani on 04/06/15.
//  Copyright (c) 2015 Wallapop SL. All rights reserved.
//

import Foundation
import Decodable

let parseSubmoduleName = "parse"
let parseQueue = queueForSubmodule(parseSubmoduleName)

//MARK: Response Parsing

func parseEmptyResponse(response : DroskyResponse) -> Deferred<Result<()>> {
    let deferred = Deferred<Result<()>>()
    dispatch_async(parseQueue) {
        deferred.fill(Result())
    }
    return deferred
}

func parseStringResponse(response : DroskyResponse) -> Deferred<Result<String>> {
    let deferred = Deferred<Result<String>>()
    dispatch_async(parseQueue) {
        if let string = NSString(data: response.data, encoding: NSUTF8StringEncoding) as? String {
            deferred.fill(Result(string))
        }
        else {
            deferred.fill(Result(parseDataError(.MalformedResponse)))
        }
    }
    return deferred
}

//MARK: Parsing

public func parseAsyncResponse<T : Decodable>(response: DroskyResponse) -> Deferred<Result<T>> {
    let deferred = Deferred<Result<T>>()
    dispatch_async(parseQueue) {
        deferred.fill(parseData(response.data))
    }
    return deferred
}

public func parseAsyncResponse<T : Decodable>(response: DroskyResponse) -> Deferred<Result<[T]>> {
    let deferred = Deferred<Result<[T]>>()
    dispatch_async(parseQueue) {
        deferred.fill(parseData(response.data))
    }
    return deferred
}

public func parseData<T : Decodable>(data:NSData) -> Result<T> {
    
    guard let j = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) else {
        return Result(parseDataError(.MalformedJSON))
    }
    
    return parseJSON(j)
}

public func parseData<T : Decodable>(data:NSData) -> Result<[T]> {
    
    guard let j = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) else {
        return Result(parseDataError(.MalformedJSON))
    }
    
    return parseJSON(j)
}

public func parseJSON<T : Decodable>(j:AnyObject) -> Result<T> {
    let result : Result<T>
    do {
        let output : T = try T.decode(j)
        result = Result(output)
    } catch let error {
        if let typeMismatch = error as? TypeMismatchError {
            print("*ERROR* decoding, type \(typeMismatch.expectedType) mismatched, expected \(typeMismatch.receivedType) type, on path \(typeMismatch.path)")
            result = Result(parseDataError(.MalformedSchema))
        } else if let missingKey = error as? MissingKeyError {
            print("*ERROR* decoding, key \(missingKey.key) is missing")
            result = Result(parseDataError(.MalformedSchema))
        } else {
            result = Result(parseDataError(.UnknownError))
        }
    }
    
    return result
}

public func parseJSON<T : Decodable>(j:AnyObject) -> Result<[T]> {
    let result : Result<[T]>
    do {
        let output : [T] = try [T].decode(j)
        result = Result(output)
    } catch let error {
        if let typeMismatch = error as? TypeMismatchError {
            print("*ERROR* decoding, type \(typeMismatch.expectedType) mismatched, expected \(typeMismatch.receivedType) type, on path \(typeMismatch.path)")
            result = Result(parseDataError(.MalformedSchema))
        } else if let missingKey = error as? MissingKeyError {
            print("*ERROR* decoding, key \(missingKey.key) is missing")
            result = Result(parseDataError(.MalformedSchema))
        } else {
            result = Result(parseDataError(.UnknownError))
        }
    }
    
    return result
}

//MARK: NSError

public let DataParseErrorDomain = submoduleName(parseSubmoduleName)

public enum DataParseErrorKind : Int {
    case MalformedJSON      = -10
    case MalformedSchema    = -20
    case MalformedResponse  = -30
    case UnknownError       = -40
}

func defaultParseDataError() -> NSError {
    return NSError(domain: DataParseErrorDomain, code: DataParseErrorKind.MalformedJSON.rawValue, userInfo: nil)
}

func parseDataError(code : DataParseErrorKind) -> NSError {
    return NSError(domain: DataParseErrorDomain, code: code.rawValue, userInfo: nil)
}


//MARK: Foundation Types

extension NSDate : Decodable {
    public class func decode(j: AnyObject) throws -> Self {
        
        guard let epochTime = j as? Double else {
            throw TypeMismatchError(expectedType: Double.self, receivedType: j.dynamicType, object: j)
        }
        
        return self.init(timeIntervalSince1970: epochTime)
    }
}
