//
//  LoginManager.swift
//
//  Created by Arjan on 04/04/16.
//

import UIKit

/**
 
    In the AppDelegate, listen for expired tokens e.g.
     NSNotificationCenter.defaultCenter().addObserverForName(UserDefaults.TokenExpiredNotificationName, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
     LoginManager.sharedLoginManager.showLoginViewController(presentingViewController: self.window?.rootViewController)
     }
 
 */

// LoginManager is a singleton, so there will be only one delegate
protocol LoginManagerDelegate {
    func currentlyShowingLoginScreen() -> Bool
    func dismissYourself()
}


/**
 This is a manager that whos goal is 
 - to manage visibility and dismissal of a login view controller
 - to validate and post JSONable data to a URL as a login method
 
 It expects
 - a certain View Controller to be the login view controller,
 with storyboard identifier `loginVCStoryboardIdentifier`. Call 
 `showLoginViewController(presentingVC:UIViewController?)`
 - this login view controller to be its `delegate`, so it can
 know if the login vc is on screen, and in order to be able to dismiss it when
 a successful login has taken place.
 */
class LoginManager {
    static let sharedLoginManager = LoginManager() // Singleton pattern
    private init() {} // prevents others from using the default '()' initializer for this class.
    var delegate: LoginManagerDelegate?
    let loginVCStoryboardIdentifier = "Login VC"
    
    // MARK: Queues
    /** 
     This queue is used to stack the login code + completionhandlers that are part of the `login(JSONPostData:_,URLString:,_completionHandler:_)` method. When a second call to login arrives, we stack the request after the current one, to prevent race conditions by
     - calling login()
     - calling login() again from another point in the app
     - getting a token
     - saving the token
     - starting a e.g. getProducts request with the token
     - meanwhile second login() call comes back with a new token (old becomes invalid)
     - the getProducts request returns: unauthorized, invalid token
     - loop
     */
    private let concurrentLoginQueue: dispatch_queue_t = {
        guard let appName = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as? String else {
            fatalError("no appname")
        }
        return dispatch_queue_create("nl.\(appName).LoginManager.concurrentLoginQueue", DISPATCH_QUEUE_CONCURRENT)
    }()
    
//    /**
//     This queue is used to make sure the calls to `currentlyLoggingIn` are synchronous
//     */
//    private let concurrentGetterSetterQueue: dispatch_queue_t = {
//        guard let appName = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as? String else {
//            fatalError("no appname")
//        }
//        return dispatch_queue_create("nl.\(appName).LoginManager.concurrentGetterSetterQueue", DISPATCH_QUEUE_CONCURRENT)
//    }()
//    
//    
//    // Make sure everything is thread safe, even when `currentlyLoggingIn` is not private anymore
//    private var currentlyLoggingIn: Bool = false
//    func setCurrentlyLoggingIn(currentlyLoggingIn: Bool) {
//        dispatch_barrier_async(concurrentGetterSetterQueue, <#T##block: dispatch_block_t##dispatch_block_t##() -> Void#>)
//    }
//    func getCurrentlyLoggingIn(currentlyLoggingIn: Bool) {
//        
//    }
    
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
    func login(JSONPostData JSONPostData: Dictionary<String, AnyObject>, URLString: String, completionHandler: ((success: Bool, responseDict: [String:AnyObject]?, statusCode: Int) -> Void)?) {
        dispatch_barrier_async(concurrentLoginQueue) {
            if !NSJSONSerialization.isValidJSONObject(JSONPostData) {
                logthis("no valid JSON")
                completionHandler?(success: false, responseDict: nil, statusCode: 0)
            }
            
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(JSONPostData, options: [])
                AppConnectionManager.sharedInstance.postAppData(jsonData,
                                                                toURLString: URLString,
                                                                postType: PostType.JSON,
                                                                onSuccess: { (responseData: NSData?) in
                                                                    guard let data = responseData else {
                                                                        completionHandler?(success: false, responseDict: nil, statusCode: 0)
                                                                        return
                                                                    }
                                                                    
                                                                    do
                                                                        
                                                                    {
                                                                        guard let json =
                                                                            try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject] else {
                                                                                
                                                                                completionHandler?(success: false, responseDict: nil, statusCode: 0)
                                                                                return
                                                                        }
                                                                        
                                                                        logthis("json: \(json)")
                                                                        completionHandler?(success: true, responseDict: json, statusCode: 0)
                                                                    }
                                                                        
                                                                    catch let error as NSError
                                                                        
                                                                    {
                                                                        logthis(error.localizedDescription)
                                                                        completionHandler?(success: false, responseDict: nil, statusCode: 0)
                                                                    }
                                                                    
                    }, onError: { (statusCode: Int) in
                        completionHandler?(success: false, responseDict: nil, statusCode: statusCode)
                        
                    }, attemptNumber: 1)
            } catch {
                logthis("error creating JSON")
            }
        }
    }
    
    
    func showLoginViewController(presentingViewController presentingVC: UIViewController?) {
        /*
         If delegate == nil, then there is 
         * a login VC on screen, but it did not set itself as delegate (== wrong!)
         * no login VC on screen
         
         If delegate is not nil, then we can automatically assume it's showing on screen, but for clarity
         we ask him if he's currently on screen.
        */
        if delegate == nil || (delegate != nil && !delegate!.currentlyShowingLoginScreen()) {

            let lvc = presentingVC?.storyboard!.instantiateViewControllerWithIdentifier(loginVCStoryboardIdentifier)
            if lvc != nil { presentingVC!.presentViewController(lvc!, animated: true, completion: nil) }
        }
    }
}
