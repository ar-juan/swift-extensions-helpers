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
    func login(JSONPostData JSONPostData: Dictionary<String, AnyObject>, URLString: String, completionHandler: ((success: Bool, responseDict: [String:AnyObject]?) -> Void)?) {
        
        if !NSJSONSerialization.isValidJSONObject(JSONPostData) {
            logthis("no valid JSON")
            completionHandler?(success: false, responseDict: nil)
        }
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(JSONPostData, options: [])
            AppConnectionManager.sharedInstance.postAppData(jsonData,
                toURLString: URLString,
                postType: PostType.JSON,
                onSuccess: { (responseData: NSData?) in
                    guard let data = responseData else {
                        completionHandler?(success: false, responseDict: nil)
                        return
                    }
                    
                    do
                    
                    {
                        guard let json =
                            try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject] else {
                            
                                completionHandler?(success: false, responseDict: nil)
                                return
                        }
                        
                        //logthis("json: \(json)")
                        completionHandler?(success: true, responseDict: json)
                    }
                        
                    catch let error as NSError
                    
                    {
                        logthis(error.localizedDescription)
                        completionHandler?(success: false, responseDict: nil)
                    }
                    
                }, onError: { (statusCode: Int) in
                    completionHandler?(success: false, responseDict: nil)
                    
                }, attemptNumber: 1)
        } catch {
            logthis("error creating JSON")
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
