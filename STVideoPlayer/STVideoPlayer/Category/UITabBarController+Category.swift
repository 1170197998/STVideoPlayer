//
//  UITabBarController+Category.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 11/03/2017.
//  Copyright © 2017 ShaoFeng. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    /// 是否支持自动转屏
    open override  var shouldAutorotate: Bool {
        if (selectedIndex != NSNotFound) {
            let vc: UIViewController = ((self.viewControllers?[self.selectedIndex]) ?? nil)!
            if (vc.isKind(of: UINavigationController.self)) {
                let nav: UINavigationController = vc as! UINavigationController
                return (nav.topViewController?.shouldAutorotate)!
            } else {
                return (vc.shouldAutorotate)
            }
        }
        return false
    }
    
    /// 支持哪些屏幕方向
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if (selectedIndex != NSNotFound) {
            let vc: UIViewController = ((self.viewControllers?[self.selectedIndex]) ?? nil)!
            if (vc.isKind(of: UINavigationController.self)) {
                let nav: UINavigationController = vc as! UINavigationController
                return (nav.topViewController?.supportedInterfaceOrientations)!
            } else {
                return (vc.supportedInterfaceOrientations)
            }
        }
        return []
    }
    /// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if (selectedIndex != NSNotFound) {
            let vc: UIViewController = ((self.viewControllers?[self.selectedIndex]) ?? nil)!
            if (vc.isKind(of: UINavigationController.self)) {
                let nav: UINavigationController = vc as! UINavigationController
                return (nav.topViewController?.preferredInterfaceOrientationForPresentation)!
            } else {
                return (vc.preferredInterfaceOrientationForPresentation)
            }
        }
        return UIInterfaceOrientation(rawValue: 0)!
    }

}
