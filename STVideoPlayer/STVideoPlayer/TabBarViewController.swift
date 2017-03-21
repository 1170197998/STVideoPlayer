//
//  TabBarViewController.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/24.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addController(vc: HomeViewController(), title: "Home", imageName: "tabbar_home")
        addController(vc: ListViewController(), title: "List", imageName: "tabbar_discover")
        addController(vc: ProfileViewController(), title: "Profile", imageName: "tabbar_profile")
    }
    
    fileprivate func addController(vc: UIViewController, title: String,imageName:String) {
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imageName)
        vc.tabBarItem.selectedImage = UIImage(named: imageName + "_selected")
        let nav = UINavigationController(rootViewController: vc)
        addChildViewController(nav)
    }
}
