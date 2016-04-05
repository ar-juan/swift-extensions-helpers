//
//  ConnectionManager.swift
//  App
//
//  Created by Arjan on 03/03/16.
//  Copyright © 2016 Auxilium. All rights reserved.
//

import UIKit

//struct Static {
//    static var token: dispatch_once_t = 0
//}


//class SomeClass {
//    lazy var someVar: SomeOtherClass = {
//       return SomeOtherClass()
//    }()
//    
//    lazy var someVarr: SomeOtherClass = {
//        var some: SomeOtherClass? = nil
//        var token: dispatch_once_t = 0
//        dispatch_once(&token) {
//            some = SomeOtherClass()
//        }
//        return some!
//    }()
//    
//    lazy var someVarrr: SomeOtherClass = {
//        struct Static {
//            static let some = SomeOtherClass()
//        }
//        return Static.some
//    }()
//}
//
//class SomeOtherClass {
//    
//}

enum PostType {
    case Standard
    case JSON
}

private class ConnectionManager {
    private static let sharedConnectionManager = ConnectionManager()
    private init() {} // prevents others from using the default '()' initializer for this class.
    
    private static func urlSessionForType(type: PostType) -> NSURLSession {
        switch type {
        case .JSON: return ephemeralJSONURLSession
        default: return ephemeralURLSession
        }
    }
    
    // MARK: NSURLSessions
    private static let ephemeralURLSession: NSURLSession = { // stackoverflow.com/questions/35793445/
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        return NSURLSession(configuration: configuration)
    }()
    private static let ephemeralJSONURLSession: NSURLSession = { // stackoverflow.com/questions/35793445/
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        if configuration.HTTPAdditionalHeaders == nil { configuration.HTTPAdditionalHeaders = ["Content-Type" : "application/json"] }
        else { configuration.HTTPAdditionalHeaders!["Content-Type"] = ["application/json"] }
        return NSURLSession(configuration: configuration)
    }()
    
//    private lazy var ephemeralURLSession: NSURLSession = {
//        var session: NSURLSession? = nil
//        var token: dispatch_once_t = 0
//        dispatch_once(&token) {
//            let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
//            session = NSURLSession(configuration: configuration)
//        }
//        return session!
//    }()
    
//    private lazy var ephemeralJSONURLSession: NSURLSession = {
//        var session: NSURLSession? = nil
//        var token: dispatch_once_t = 0
//        dispatch_once(&token) {
//            let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
//            configuration.HTTPAdditionalHeaders!["Content-Type"] = "application/json"
//            session = NSURLSession(configuration: configuration)
//        }
//        return session!
//    }()
    
    
    // MARK: GET and POST data methods
    private func postData(data: NSData, toURLString urlString: String, usingSession session: NSURLSession, withCompletionHandler completionHandler: ((data: NSData?, response: NSURLResponse?, error: NSError?, request: NSMutableURLRequest?) -> Void)) {
        var bgTask: UIBackgroundTaskIdentifier?
        
        let application = UIApplication.sharedApplication()
        bgTask = application.beginBackgroundTaskWithName("\(NSBundle.mainBundle().bundleIdentifier).PostData", expirationHandler: { () -> Void in
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            application.endBackgroundTask(bgTask!)
            bgTask = UIBackgroundTaskInvalid
        })
        
        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(URL: url)
            
            // iOS 8.3 has a bug where the http headers of the configuration are not used. Set them also on the request.
            if let headers = session.configuration.HTTPAdditionalHeaders {
                for (key, value) in headers {
                    request.addValue(value as! String, forHTTPHeaderField: key as! String)
                }
            }
            request.HTTPMethod = "POST"
            request.HTTPBody = data
            request.timeoutInterval = 120
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                completionHandler(data: data, response: response, error: error, request: request)
                
                application.endBackgroundTask(bgTask!)
                bgTask = UIBackgroundTaskInvalid;
            })
            task.resume()
        }
    }
    
    private func getDatawithURLString(urlString: String, usingSession session: NSURLSession, withCompletionHandler completionHandler: ((responseData: NSData?, response: NSURLResponse?, error: NSError?) -> Void)) {
        var bgTask: UIBackgroundTaskIdentifier?
        
        let application = UIApplication.sharedApplication()
        bgTask = application.beginBackgroundTaskWithName("\(NSBundle.mainBundle().bundleIdentifier).GetData", expirationHandler: { () -> Void in
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            application.endBackgroundTask(bgTask!)
            bgTask = UIBackgroundTaskInvalid
        })
        
        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = "GET"
            request.timeoutInterval = 120
            
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                completionHandler(responseData: data, response: response, error: error)
                
                application.endBackgroundTask(bgTask!)
                bgTask = UIBackgroundTaskInvalid;
            })
            task.resume()
        }
    }
}


class AppConnectionManager {
    static let sharedInstance = AppConnectionManager()
    private let connectionManager = ConnectionManager.sharedConnectionManager
    private init() {}
    private let maxAttempts = 3
    private let maxResponseBodySizeForLog = 200
    private let logMuch: Bool = false
    
    func logResult(result: String, forUrlString urlString: String, session: NSURLSession, responseData: NSData?, httpResponse: NSHTTPURLResponse, request: NSURLRequest?, error: NSError?) {
        if self.logMuch {
            let NSURLSessionHeaders = session.configuration.HTTPAdditionalHeaders
            let responseBodyString = (responseData != nil ? String(data: responseData!, encoding: NSUTF8StringEncoding) : "repsonseData = nil")!
            let requestBodyString = request?.HTTPBody != nil ? String(data: request!.HTTPBody!, encoding: NSUTF8StringEncoding) : "requstData = nil"
            let shortResponseBodyString = responseBodyString.substringToIndex(responseBodyString.startIndex.advancedBy(self.maxResponseBodySizeForLog, limit: responseBodyString.endIndex))
            
//            let get = "\(result) for url: \(urlString) \r\nsessionHeaders: \(NSURLSessionHeaders) \r\nrequest headers: \(request?.allHTTPHeaderFields) \r\nrequest body: \(requestBodyString) \r\nresponse status code: \(httpResponse.statusCode) \r\nresponse headers: \(httpResponse.allHeaderFields) \r\nresponse body (first \(maxResponseBodySizeForLog) chars): \(shortResponseBodyString)"
            
            var logItems = [
                "\(result) for url \(urlString)", /* e.g. get error for url www.nu.nl */
                "sessionHeaders: \(NSURLSessionHeaders)"]
            
            if request != nil {
                logItems.append("request headers: \(request!.allHTTPHeaderFields)")
                logItems.append("request body: \(requestBodyString)")
            }
            
            logItems += [
                "response status code: \(httpResponse.statusCode)",
                "response headers: \(httpResponse.allHeaderFields)",
                "response body (first \(maxResponseBodySizeForLog) chars): \(shortResponseBodyString)"]
            
            if let error = error {
                logItems += [
                "drror: \(error.code) - \(error.domain)",
                "description: \(error.localizedDescription)",
                "failure reason: \(error.localizedFailureReason)",
                "user info: \(error.userInfo)"]
            }
            
            let debugString = logItems.stringWithLineBreaksFromArray()
            
//            logthis(String(format: "\(result): getting from url :%@\r\nNSURLSessionHeaders: %@\r\nResponse status code %ld\nResponse headers: %@\r\nResponse body (first part): %@", arguments: [urlString, NSURLSessionHeaders ?? "none", httpResponse.statusCode, httpResponse.allHeaderFields, shortResponseBodyString]))
            logthis(debugString)
        } else {
            print("\(result) for URL: \(urlString)")
        }
    }
    
    
    
    func getAppDatawithURLString(urlString: String, onSuccess successHandler: ((responseData: NSData?, httpResponse: NSHTTPURLResponse?) -> Void)?, onError errorHandler: (() -> Void)?, attemptNumber attempt: Int) {
        if attempt >= maxAttempts {
            logthis("Max attempt reached")
            errorHandler?()
            return
        }
        // Implement... if then else etc
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let session = ConnectionManager.ephemeralURLSession // connectionManager.ephemeralURLSession
        connectionManager.getDatawithURLString(urlString, usingSession: session) { (responseData: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            guard let httpResponse = response as? NSHTTPURLResponse else {
                logthis("response is nil")
                errorHandler?()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                return
            }
            
            //let urlError = error as! NSURLError
            let statusCode = httpResponse.statusCode
            if statusCode/100 == 2 {
                successHandler?(responseData: responseData, httpResponse: httpResponse)
                self.logResult("get successful", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: nil, error:  error)
            } else {
                var failureText: String = "-"
                self.logResult("get error", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: nil, error: error)
                if statusCode/100 == 5 {
                    failureText = "Server unavailable for url: \(urlString)\r\n Trying again now."
                    self.getAppDatawithURLString(urlString, onSuccess: successHandler, onError: errorHandler, attemptNumber: attempt+1)
                } else if statusCode == 400 {
                    failureText = "Bad request"
                    errorHandler?()
                } else if error != nil {
                    if error?.code == NSURLError.TimedOut.rawValue {
                        self.logResult("time out", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: nil, error: error)
                    } else {
                        self.logResult("get error", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: nil, error: error)
                    }
                    //failureText = "Error: \(error?.code) - \(error?.domain)\r\nDescription: \(error?.localizedDescription) \r\nFailure reason: \(error?.localizedFailureReason) \r\nUserinfo: \(error?.userInfo)"
                    errorHandler?()
                } else {
                    failureText = "No error but anyways something wrong in getting data"
                    errorHandler?()
                }
                logthis("Extra information: \r\n\(failureText)")
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    func postAppData(postData: NSData, toURLString urlString: String, postType type: PostType, onSuccess successHandler:((responseData: NSData?) -> Void)?, onError errorHandler: (() -> Void)?, attemptNumber attempt: Int) {
        if attempt >= maxAttempts {
            logthis("Max attempt reached")
            errorHandler?()
            return
        }
        // if no application token, get token etc
        // same for session token
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let session = ConnectionManager.urlSessionForType(.JSON)
        ConnectionManager.sharedConnectionManager.postData(postData, toURLString: urlString, usingSession: session) { (responseData: NSData?, response: NSURLResponse?, error: NSError?, request: NSURLRequest?) -> Void in
            guard let httpResponse = response as? NSHTTPURLResponse else {
                logthis("response is nil")
                errorHandler?()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            if statusCode / 100 == 2 {
                successHandler?(responseData: responseData)
                self.logResult("post successful", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: request, error: error)
            } else {
                var failureText: String = "-"
                
                if statusCode / 100 == 5 {
                    failureText = "Server unavailable for url: \(urlString)\r\n Trying again now."
                    self.postAppData(postData, toURLString: urlString, postType: type, onSuccess: successHandler, onError: errorHandler, attemptNumber: attempt+1)
                } else if statusCode == 400 {
                    failureText = "Bad request"
                    errorHandler?()
                } else {
                    if error == nil { failureText = "No error but anyways something wrong in posting data" }
                    errorHandler?()
                }
                self.logResult("posting error", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: request, error: error)
                logthis("extra information: \(failureText)")
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
}