//
//  AppDelegate.swift
//  Movie
//
//  Created by Luu Tien Thanh on 2/15/17.
//  Copyright © 2017 Luu Tien Thanh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Set up the Now Playing View Controller
        let nowPlayingNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationCtrl") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MoviesViewController
        nowPlayingViewController.endpoint = "now_playing"
        nowPlayingViewController.tabBarItem.title = "Now Playing"
        nowPlayingViewController.tabBarItem.image = UIImage(named: "now_playing")
        
        // Set up the Top Rated View Controller
        let topRatedNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationCtrl") as! UINavigationController
        let topRatedViewController = topRatedNavigationController.topViewController as! MoviesViewController
        topRatedViewController.endpoint = "top_rated"
        topRatedViewController.tabBarItem.title = "Top Rated"
        topRatedViewController.tabBarItem.image = UIImage(named: "top_rated")
        
        // Set up the Tab Bar Controller to have two tabs
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController]
        
        // Custom Colors
        let primaryColor = UIColor(red: 136/255, green: 160/255, blue: 31/255, alpha: 1)
        let darkColor = UIColor(red: 30/255, green: 34/255, blue: 36/255, alpha: 1)
        let lightColor = UIColor(red: 72/255, green: 76/255, blue: 82/255, alpha: 1)
        
        // Customize Tab Bar Colors
        tabBarController.tabBar.barStyle = UIBarStyle.black
        tabBarController.tabBar.barTintColor = darkColor
        tabBarController.tabBar.tintColor = primaryColor
        
        // Make the Tab Bar Controller the root view controller
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

