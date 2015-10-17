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
        self.getRequestToken() { (success, requestToken, errorString) in
            
            if success {
                
                self.loginWithToken(requestToken, hostViewController: hostViewController) {(success, errorString) in
                    
                    if success {
                        print("You did it! We have finished authenticating though the website!")
                    } else {
                        completionHandler(success: success, errorString: errorString)
                    }
                }
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func getRequestToken(completionHandler: (success: Bool, requestToken: String?, errorString: String?) -> Void) {
        
        var parameters = [String : AnyObject]()
        
        taskForGETMethod(Methods.AuthenticationTokenNew, parameters: parameters) { (JSONResult, error) in
            
            /* Was there an error? */
            guard error == nil else {
                completionHandler(success: false, requestToken: nil, errorString: "Login failed (Request Token)")
                return
            }
            
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
    
}