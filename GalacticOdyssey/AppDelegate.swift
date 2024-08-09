//
//  AppDelegate.swift
//  GalacticOdyssey
//
//  Created by Hamidreza Vakilian on 8/5/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let window = UIWindow()
        self.window = window

        window.rootViewController = UINavigationController(rootViewController: ViewController())

//        window.rootViewController = tabbar
        window.makeKeyAndVisible()

        return true
    }


}

