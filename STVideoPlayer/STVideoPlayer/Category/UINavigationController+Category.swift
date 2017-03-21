
//
//  UINavigationController+CATEGORY.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 11/03/2017.
//  Copyright © 2017 ShaoFeng. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    /// 是否支持自动转屏
    override open var shouldAutorotate: Bool {
        return (visibleViewController?.shouldAutorotate)!
    }
    
    /// 支持哪些屏幕方向
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (visibleViewController?.supportedInterfaceOrientations)!
    }
    
    /// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return (visibleViewController?.preferredInterfaceOrientationForPresentation)!
    }
}
