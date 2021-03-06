//
//  AppDelegate.swift
//  Freetime
//
//  Created by Ryan Nystrom on 4/30/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var showingLogin = false

    let sessionManager = GithubSessionManager()
    lazy var rootNavigationManager: RootNavigationManager = {
        return RootNavigationManager(
            sessionManager: self.sessionManager,
            rootTabBarController: self.window?.rootViewController as! UITabBarController
        )
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        rootNavigationManager.resetRootViewController(userSession: sessionManager.focusedUserSession)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if sessionManager.focusedUserSession == nil {
            rootNavigationManager.showLogin(animated: false)
        }
    }
    
}
