//
//  ConnectionManager.swift
//
//  Created by Arjan on 03/03/16.
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
    case standard
    case json
}

private class ConnectionManager {
    fileprivate static let sharedConnectionManager = ConnectionManager()
    fileprivate init() {} // prevents others from using the default '()' initializer for this class.
    fileprivate let concurrentConnectionQueue: DispatchQueue = {
        guard let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String else {
            fatalError("no appname")
        }
        return DispatchQueue(label: "nl.\(appName).concurrentConnectionQueue", attributes: DispatchQueue.Attributes.concurrent)
    }()
    
    fileprivate static func urlSessionForType(_ type: PostType) -> URLSession {
        switch type {
        case .json: return ephemeralJSONURLSession
        default: return ephemeralURLSession
        }
    }
    
    // MARK: NSURLSessions
    fileprivate static let ephemeralURLSession: URLSession = { // stackoverflow.com/questions/35793445/
        let configuration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration)
    }()
    fileprivate static let ephemeralJSONURLSession: URLSession = { // stackoverflow.com/questions/35793445/
        let configuration = URLSessionConfiguration.ephemeral
        if configuration.httpAdditionalHeaders == nil { configuration.httpAdditionalHeaders = ["Content-Type" : "application/json"] }
        else { configuration.httpAdditionalHeaders!["Content-Type"] = ["application/json"] }
        return URLSession(configuration: configuration)
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
    fileprivate func postData(_ data: Data, toURLString urlString: String, usingSession session: URLSession, withCompletionHandler completionHandler: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error?, _ request: NSMutableURLRequest?) -> Void)) {
        // Start the long-running task and return immediately.
        concurrentConnectionQueue.async(flags: .barrier, execute: {
            //logthis("now posting data to \(urlString)")
        var bgTask: UIBackgroundTaskIdentifier?
        
        let application = UIApplication.shared
        bgTask = application.beginBackgroundTask(withName: "\(Bundle.main.bundleIdentifier).PostData", expirationHandler: { () -> Void in
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            application.endBackgroundTask(bgTask!)
            bgTask = UIBackgroundTaskInvalid
        })
        
        
            let url = URL(string: urlString)!
            let request = NSMutableURLRequest(url: url)
            
            // iOS 8.3 has a bug where the http headers of the configuration are not used. Set them also on the request.
            if let headers = session.configuration.httpAdditionalHeaders {
                for (key, value) in headers {
                    request.addValue(value as! String, forHTTPHeaderField: key as! String)
                }
            }
            request.httpMethod = "POST"
            request.httpBody = data
            request.timeoutInterval = 60
            
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                completionHandler(data, response, error, request)
                
                application.endBackgroundTask(bgTask!)
                bgTask = UIBackgroundTaskInvalid;
            })
            task.resume()
        }) 
        
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
//            let url = NSURL(string: urlString)!
//            let request = NSMutableURLRequest(URL: url)
//            
//            // iOS 8.3 has a bug where the http headers of the configuration are not used. Set them also on the request.
//            if let headers = session.configuration.HTTPAdditionalHeaders {
//                for (key, value) in headers {
//                    request.addValue(value as! String, forHTTPHeaderField: key as! String)
//                }
//            }
//            request.HTTPMethod = "POST"
//            request.HTTPBody = data
//            request.timeoutInterval = 120
//            
//            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
//                completionHandler(data: data, response: response, error: error, request: request)
//                
//                application.endBackgroundTask(bgTask!)
//                bgTask = UIBackgroundTaskInvalid;
//            })
//            task.resume()
//        }
    }
    
    fileprivate func getDatawithURLString(_ urlString: String, usingSession session: URLSession, withCompletionHandler completionHandler: @escaping ((_ responseData: Data?, _ response: URLResponse?, _ error: Error?) -> Void)) {
        concurrentConnectionQueue.async(flags: .barrier, execute: {
            //logthis("now getting data")
        var bgTask: UIBackgroundTaskIdentifier?
        
        let application = UIApplication.shared
        bgTask = application.beginBackgroundTask(withName: "\(Bundle.main.bundleIdentifier).GetData", expirationHandler: { () -> Void in
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            application.endBackgroundTask(bgTask!)
            bgTask = UIBackgroundTaskInvalid
        })
        
        // Start the long-running task and return immediately.
        
            let url = URL(string: urlString)!
            let request = NSMutableURLRequest(url: url)
            
            request.httpMethod = "GET"
            request.timeoutInterval = 60
            
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                //var errorns = error as! NSError
                //print(errorns)
                completionHandler(data, response, error)

                application.endBackgroundTask(bgTask!)
                bgTask = UIBackgroundTaskInvalid;
            })
            task.resume()
        }) 
        
//        // Start the long-running task and return immediately.
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
//            let url = NSURL(string: urlString)!
//            let request = NSMutableURLRequest(URL: url)
//            
//            request.HTTPMethod = "GET"
//            request.timeoutInterval = 120
//            
//            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
//                completionHandler(responseData: data, response: response, error: error)
//                
//                application.endBackgroundTask(bgTask!)
//                bgTask = UIBackgroundTaskInvalid;
//            })
//            task.resume()
//        }
    }
}


class AppConnectionManager {
    static let sharedInstance = AppConnectionManager()
    fileprivate let connectionManager = ConnectionManager.sharedConnectionManager
    fileprivate init() {}
    fileprivate let maxAttempts = 3
    fileprivate let maxResponseBodySizeForLog = 200
    fileprivate let logMuch: Bool = false
    
    func logResult(_ result: String, forUrlString urlString: String, session: URLSession, responseData: Data?, httpResponse: HTTPURLResponse, request: URLRequest?, error: Error?) {
        logResult(result, forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: request, error: error as? NSError)
    }
    func logResult(_ result: String, forUrlString urlString: String, session: URLSession, responseData: Data?, httpResponse: HTTPURLResponse, request: URLRequest?, error: NSError?) {
        
        if self.logMuch {
            let NSURLSessionHeaders = session.configuration.httpAdditionalHeaders
            let responseBodyString = (responseData != nil ? String(data: responseData!, encoding: String.Encoding.utf8) : "repsonseData = nil")!
            let requestBodyString = request?.httpBody != nil ? String(data: request!.httpBody!, encoding: String.Encoding.utf8) : "requstData = nil"
            let shortResponseBodyString = responseBodyString.substring(to: responseBodyString.characters.index(responseBodyString.startIndex, offsetBy: self.maxResponseBodySizeForLog, limitedBy: responseBodyString.endIndex)!)
            
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
    
    
    
    func getAppDatawithURLString(_ urlString: String, onSuccess successHandler: ((_ responseData: Data?, _ httpResponse: HTTPURLResponse?) -> Void)?, onError errorHandler: ((_ statusCode: Int) -> Void)?, attemptNumber attempt: Int) {
        if attempt > maxAttempts {
            logthis("Max attempt reached")
            errorHandler?(0)
            return
        }
        // Implement... if then else etc
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let session = ConnectionManager.ephemeralURLSession // connectionManager.ephemeralURLSession
        connectionManager.getDatawithURLString(urlString, usingSession: session) { (responseData: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else {
                logthis("response is nil")
                errorHandler?(0)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            //let urlError = error as! NSURLError
            let statusCode = httpResponse.statusCode
            if statusCode/100 == 2 {
                successHandler?(responseData, httpResponse)
                //self.logResult("get successful", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: nil, error:  error)
            } else {
                var failureText: String = "-"
                self.logResult("get error", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: nil, error: error)
                if statusCode/100 == 5 {
                    failureText = "Server error for url: \(urlString)\r\n Trying again now."
                    self.getAppDatawithURLString(urlString, onSuccess: successHandler, onError: errorHandler, attemptNumber: attempt+1)
                } else if statusCode == 400 {
                    failureText = "Bad request"
                    errorHandler?(statusCode)
                } else if statusCode == 401 {
                    failureText = "Unauthorized"
                    errorHandler?(statusCode)
                } else if statusCode == 403 {
                    failureText = "Forbidden"
                    errorHandler?(statusCode)
                } else if error != nil {
                    if (error as? NSError)?.code == URLError.timedOut.rawValue {
                        self.logResult("time out", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: nil, error: error)
                    } else {
                        self.logResult("get error", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: nil, error: error)
                    }
                    //failureText = "Error: \(error?.code) - \(error?.domain)\r\nDescription: \(error?.localizedDescription) \r\nFailure reason: \(error?.localizedFailureReason) \r\nUserinfo: \(error?.userInfo)"
                    errorHandler?(statusCode)
                } else {
                    failureText = "No error but anyways something wrong in getting data"
                    errorHandler?(statusCode)
                }
                logthis("Extra information: \r\n\(failureText)")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func postAppData(_ postData: Data, toURLString urlString: String, postType type: PostType, onSuccess successHandler:((_ responseData: Data?) -> Void)?, onError errorHandler: ((_ statusCode: Int) -> Void)?, attemptNumber attempt: Int) {
        if attempt > maxAttempts {
            logthis("Max attempt reached")
            errorHandler?(0)
            return
        }
        // if no application token, get token etc
        // same for session token
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let session = ConnectionManager.urlSessionForType(.json)
        ConnectionManager.sharedConnectionManager.postData(postData, toURLString: urlString, usingSession: session) { (responseData: Data?, response: URLResponse?, error: Error?, request: NSMutableURLRequest?) -> Void in
            guard let httpResponse = response as? HTTPURLResponse else {
                logthis("response is nil")
                errorHandler?(0)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            if statusCode / 100 == 2 {
                successHandler?(responseData)
                //self.logResult("post successful", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: request, error: error)
            } else {
                var failureText: String = "-"
                
                if statusCode / 100 == 5 {
                    failureText = "Server unavailable for url: \(urlString)\r\n Trying again now."
                    self.postAppData(postData, toURLString: urlString, postType: type, onSuccess: successHandler, onError: errorHandler, attemptNumber: attempt+1)
                } else if statusCode == 400 {
                    failureText = "Bad request"
                    errorHandler?(statusCode)
                } else if statusCode == 401 {
                    failureText = "Unauthorized"
                    errorHandler?(statusCode)
                } else if statusCode == 403 {
                    failureText = "Forbidden"
                    errorHandler?(statusCode)
                } else {
                    if error == nil { failureText = "No error but anyways something wrong in posting data" }
                    errorHandler?(statusCode)
                }
                self.logResult("posting error", forUrlString: urlString, session: session, responseData: responseData, httpResponse: httpResponse, request: request as URLRequest?, error: (error as? NSError))
                logthis("extra information: \(failureText)")
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    /**
     Checks if
     - `JSONPostData` is valid JSON,
     - Tries to parse it into JSON,
     - Expects JSON response from web server.
     - Tries to parse JSON response into a property list
     
     and calls the `completionHandler` early if it encounters errors.
     - parameter JSONPostData: some valid JSON which will be sent to the web server
     - parameter URLString
     - parameter completionHandler: `success` is false when
     - `JSONPostData` is invalid JSON,
     - web server returns nothing valuable,
     - response is no valid JSON.
     
     In case of a valid JSON response, `completionHandler(success:true, responseDict:json)` is called.
     */
    func postJSONAppData(_ JSONPostData: Dictionary<String, AnyObject>, URLString: String, completionHandler: ((_ success: Bool, _ responseDict: [String:AnyObject]?, _ statusCode: Int?) -> Void)?, attempt: Int) {
        if attempt > maxAttempts {
            logthis("Max attempt reached")
            completionHandler?(false, nil, nil)
            return
        }
        if !JSONSerialization.isValidJSONObject(JSONPostData) {
            logthis("no valid JSON")
            completionHandler?(false, nil, nil)
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: JSONPostData, options: [])
            AppConnectionManager.sharedInstance.postAppData(jsonData,
                                                            toURLString: URLString,
                                                            postType: PostType.json,
                                                            onSuccess: { (responseData: Data?) in
                                                                guard let data = responseData else {
                                                                    completionHandler?(false, nil, nil)
                                                                    return
                                                                }
                                                                
                                                                do
                                                                    
                                                                {
                                                                    guard let json =
                                                                        try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] else {
                                                                            
                                                                            completionHandler?(false, nil, nil)
                                                                            return
                                                                    }
                                                                    
                                                                    completionHandler?(true, json, nil)
                                                                }
                                                                    
                                                                catch let error as NSError
                                                                
                                                                {
                                                                    logthis(error.localizedDescription)
                                                                    completionHandler?(false, nil, nil)
                                                                }
                                                                
                }, onError: { (statusCode: Int) in
                    completionHandler?(false, nil, statusCode)
                }, attemptNumber: 1)
        } catch {
            logthis("error creating JSON")
        }
    }
    
}
