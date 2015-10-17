//
//  AppDelegate.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    var window: UIWindow?
    
    /* Need these for login */
    var requestToken: String? = nil
    
    /* Configuration for TheMovieDB, we'll take care of this for you =)... */
    var config = TMDBConfig()
    
    // MARK: UIApplicationDelegate
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /* If necessary, update the configuration */
        config.updateIfDaysSinceUpdateExceeds(7)
        
        return true
    }
}

