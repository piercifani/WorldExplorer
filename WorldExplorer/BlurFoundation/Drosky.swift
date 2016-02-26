//
//  Created by Pierluigi Cifani on 03/06/15.
//  Copyright (c) 2015 Blur Software SL. All rights reserved.
//

import Foundation
import Alamofire

/*
Welcome to Drosky, your one and only way of talking to Rest APIs.

Inspired by Moya (https://github.com/AshFurrow/Moya)

*/

// Mark: HTTP method and parameter encoding

public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, OPTIONS, HEAD, PATCH, TRACE, CONNECT
}

public enum HTTPParameterEncoding {
    case URL
    case JSON
    case PropertyList(NSPropertyListFormat, NSPropertyListWriteOptions)
    case Custom((URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?))
}

extension HTTPParameterEncoding {
    func alamofireParameterEncoding() -> Alamofire.ParameterEncoding {
        switch self {
        case .URL:
            return .URL
        case .JSON:
            return .JSON
        case .PropertyList(let format, let options):
            return .PropertyList(format, options)
        case .Custom(let closure):
            return .Custom(closure)
        }
    }
}

// MARK: DroskyResponse

public struct DroskyResponse {
    let statusCode: Int
    let httpHeaderFields: [String: String]
    let data: NSData
}

extension DroskyResponse {
    func dataAsJSON() -> [String: AnyObject]? {
        let json: [String: AnyObject]?

        do {
            json = try NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject]
        } catch {
            json = nil
        }

        return json
    }
}

extension DroskyResponse: CustomStringConvertible {
    public var description: String {
        return "StatusCode: " + String(statusCode) + "\nHeaders: " +  httpHeaderFields.description
    }
}

// MARK: - Drosky

public final class Drosky {
    
    private let networkManager: Alamofire.Manager
    private let queue = queueForSubmodule("drosky")
    
    public init (configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()) {
            networkManager = Alamofire.Manager(configuration: configuration)
    }
    
    public func performRequest(forEndpoint endpoint: Endpoint) -> Deferred<Result<DroskyResponse>> {
        return generateRequest(endpoint)
                ≈> performNSURLRequest
    }
    
    public func performNSURLRequest(request: NSURLRequest) -> Deferred<Result<DroskyResponse>> {
        return sendRequest(request)
                ≈> validateDroskyResponse
    }
    
    // Internal
    private func generateRequest(endpoint: Endpoint) -> Deferred<Result<NSURLRequest>> {
        let deferred = Deferred<Result<NSURLRequest>>()
        dispatch_async(queue) { [weak self] in
            guard let welf = self else { return }
            
            let requestResult = welf.generateHTTPRequest(endpoint)
            deferred.fill(requestResult)
        }
        return deferred
    }
    
    private func generateHTTPRequest(endpoint: Endpoint) -> Result<NSURLRequest> {
        guard let URL = NSURL(string: endpoint.path) else {
            return Result<NSURLRequest>(DroskyError.MalformedURLError)
        }

        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.httpHeaderFields
        
        let requestTuple = endpoint.parameterEncoding.alamofireParameterEncoding().encode(request, parameters: endpoint.parameters)
        
        if let error = requestTuple.1 {
            return Result<NSURLRequest>(error)
        } else {
            return Result<NSURLRequest>(requestTuple.0)
        }
    }

    private func sendRequest(request: NSURLRequest) -> Deferred<Result<DroskyResponse>> {
        let deferred = Deferred<Result<DroskyResponse>>()
        let dataSerializer = Alamofire.Request.dataResponseSerializer()
        
        networkManager.request(request)
            .response(queue: queue,
                responseSerializer: dataSerializer) { (response) in
                    switch response.result {
                    case .Failure(let error):
                        // TODO: Maybe parse the error data here?
                        deferred.fill(Result<DroskyResponse>(error))
                    case .Success(let data):
                        #if DEBUG
                            if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                                print(string as String)
                            }
                        #endif
                        if let urlResponse = response.response, let responseHeaders = urlResponse.allHeaderFields as? [String: String] {
                            let response = DroskyResponse(statusCode: urlResponse.statusCode, httpHeaderFields: responseHeaders, data: data)
                            deferred.fill(Result<DroskyResponse>(response))
                        }
                        else {
                            deferred.fill(Result<DroskyResponse>(DroskyError.UnknownError))
                        }
                    }
        }
        
        return deferred
    }
    
    private func validateDroskyResponse(response: DroskyResponse) -> Deferred<Result<DroskyResponse>> {
        
        let deferred = Deferred<Result<DroskyResponse>>()
        
        dispatch_async(queue) {
            switch response.statusCode {
            case 400:
                let error = DroskyError.BadRequest
                deferred.fill(Result<DroskyResponse>(error))
            case 401:
                let error = DroskyError.Unauthorized
                deferred.fill(Result<DroskyResponse>(error))
            case 403:
                let error =  DroskyError.Forbidden
                deferred.fill(Result<DroskyResponse>(error))
            case 404:
                let error = DroskyError.ResourceNotFound
                deferred.fill(Result<DroskyResponse>(error))
            case 405...499:
                let error = DroskyError.UnknownError
                deferred.fill(Result<DroskyResponse>(error))
            case 500:
                let error = DroskyError.ServerUnavailable
                deferred.fill(Result<DroskyResponse>(error))
            default:
                deferred.fill(Result<DroskyResponse>(response))
            }
        }
        
        return deferred
    }
}

//MARK: Drosky Errors

enum DroskyError: ErrorType {
    case UnknownError
    case UnknownResponse
    case Unauthorized
    case ServerUnavailable
    case ResourceNotFound
    case MalformedURLError
    case BadRequest
    case Forbidden
}

