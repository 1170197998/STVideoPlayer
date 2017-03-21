//
//  STPlayerModel.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/25.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//

import UIKit

class STPlayerModel: NSObject {

    /// 视频标题
    var title: String?
    /// 视频URL
    var videoUrl: URL!
    /// 视频封面本地图片
    /// 懒加载用关键字lazy修饰,而不是写get方法
    lazy var placeholderImage: UIImage =  {
        let image = UIImage(named: "ZFPlayer_loading_bgView")
        return image!
    }()

    /* tips:
    OC中懒加载写get方法,但是在这里如果写了get方法,变成了只读属性,外界没法访问
    var _placeholderImage: UIImage?
    var placeholderImage: UIImage? {
        get {
            if (_placeholderImage == nil) {
                _placeholderImage = UIImage(named: "ZFPlayer_loading_bgView")
            }
            return _placeholderImage
        }
    }*/
    /// 视频封面网络图片
    var placeholderImageUrlString: String?
    /// 视频分别率
    var resolutionDict: Dictionary<String, Any>?
    /// 从多少秒开始播放视频
    var seekTime: NSInteger?
    /// cell播放视频指定的tableView
    var tableView: UITableView?
    /// cell所在的indexPath
    var indexPath: NSIndexPath?
    /// 播放器的父视图
    weak var fatherView: UIView?
    
    override init() {
        super.init()
    }
}
