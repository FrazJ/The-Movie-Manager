//
//  TMDBConvenience.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension TMDBClient {
    
    /* Function */
    func authenticateWithViewController(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* Chain the completetion handlers for each request so that they run one after the other*/
        getRequestToken() { (success, requestToken, errorString) in
            
            /* If you successfully got the request token, login with the Token */
            if success {
                self.loginWithToken(requestToken, hostViewController: hostViewController) {(success, errorString) in
                    
                    /* If you successfully logged in, get the session ID */
                    if success {
                        self.getSessionID(requestToken) { (success, sessionID, errorString) in
                            
                            /* If you successfully got the session ID, set the session ID property and get the user ID  */
                            if success {
                                
                                /* Set the session ID property */
                                self.sessionId = sessionID
                                
                                self.getUserID() { (success, userID, errorString) in
                                    
                                    /* If you successfully got thre user ID, set the user ID property */
                                    if success {
                                        
                                        if let userID = userID {
                                            
                                            /* Set the user ID property */
                                            self.userID = userID
                                        }
                                    }
                                    
                                    completionHandler(success: success, errorString: errorString)
                                }
                            }
                        }
                    } else {
                        completionHandler(success: success, errorString: errorString)
                    }
                }
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    /* Function to retrive the request token */
    func getRequestToken(completionHandler: (success: Bool, requestToken: String?, errorString: String?) -> Void) {
        
        /* 1. Specify the parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String : AnyObject]()
        
        /* 2. Make the request */
        taskForGETMethod(Methods.AuthenticationTokenNew, parameters: parameters) { (JSONResult, error) in
            
            
            
            /* Was there an error? */
            guard error == nil else {
                completionHandler(success: false, requestToken: nil, errorString: "Login failed (Request Token)")
                return
            }
            
            /* 3. Send the desired values(s) to the completion handler */
            if let requestToken = JSONResult.valueForKey(JSONResponseKeys.RequestToken) as? String {
                completionHandler(success: true, requestToken: requestToken, errorString: nil)
            } else {
                completionHandler(success: false, requestToken: nil, errorString: "Login failed (Request Token)")
            }
            
        }
    }
    
    /* This function opens a TMDBAuthViewController to handle step 2a of the auth flow */
    func loginWithToken(requestToken: String?, hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let authorisationURL = NSURL(string: "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)")
        let request = NSURLRequest(URL: authorisationURL!)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("TMDBAuthViewController") as! TMDBAuthViewController
        webAuthViewController.urlRequest = request
        webAuthViewController.requestToken = requestToken
        webAuthViewController.completionHandler = completionHandler
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        dispatch_async(dispatch_get_main_queue(), {
            hostViewController.presentViewController(webAuthViewController, animated: true, completion: nil)
        })
    }
    
    /* Function to get the session ID */
    func getSessionID(requestToken: String?, completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify the parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [
            ParameterKeys.RequestToken : requestToken!
        ]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.AuthenticationSessionNew, parameters: parameters) {(JSONResult, error) in
            
            guard error == nil else {
                completionHandler(success: false, sessionID: nil, errorString: "Login failed (Session ID)")
                return
            }
            
            /* 3. Send the desired values(s) to the completion handler */
            if let sessionID = JSONResult.valueForKey(JSONResponseKeys.SessionID) as? String {
                completionHandler(success: true, sessionID: sessionID, errorString: nil)
            } else {
                completionHandler(success: false, sessionID: nil, errorString: "Login failed (Session ID)")
            }
        
        }
        
    }
    
    /* Function to get the user ID */
    func getUserID(completionHandler: (success: Bool, userID: Int?, errorString: String?) -> Void) {
        
        /* 1. Specify the parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [
            ParameterKeys.SessionID : self.sessionId!
        ]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.Account, parameters: parameters) {(JSONResult, error) in
            
            guard error == nil else {
                completionHandler(success: false, userID: nil, errorString: "Login failed (User ID)")
                return
            }
            
            /* 3. Send the desired values(s) to the completion handler */
            if let userID = JSONResult.valueForKey(JSONResponseKeys.UserID) as? Int {
                completionHandler(success: true, userID: userID, errorString: nil)
            } else {
                completionHandler(success: false, userID: nil, errorString: "Login failed (User ID)")
            }
        }
        
    }
    
}



























