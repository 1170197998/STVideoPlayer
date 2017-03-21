//
//  AppDelegate.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/24.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//

import UIKit
//func DebugLog<T>(messsage : T, file : String = #file, funcName : String = #function, lineNum : Int = #line) {
//    #if DEBUG
//        let fileName = (file as NSString).lastPathComponent
//        print("\(fileName):(\(lineNum))-\(messsage)")
//    #endif
//}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let tabbarVC = TabBarViewController()
        window?.rootViewController = tabbarVC
        window?.makeKeyAndVisible()
        
        return true
    }
}

