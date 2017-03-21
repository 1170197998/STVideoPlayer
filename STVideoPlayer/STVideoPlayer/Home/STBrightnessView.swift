//
//  STBrightnessView.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/28.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//

import UIKit

class STBrightnessView: UIView {
    
    ///  播放状态是否锁定屏幕发那方向
    var isLockScreen: Bool = false
    /// 是否允许横屏
    var isAllowLandScape: Bool = false
    
    static let shared = STBrightnessView()
    
    private var backImage: UIImageView?
    private var title: UILabel?
    private var longView: UIView?
    private var tipArray: Array<Any>?
    private var orientationDidChange: Bool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLayer(notify:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc private func updateLayer(notify: Notification) {
        orientationDidChange = true
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
