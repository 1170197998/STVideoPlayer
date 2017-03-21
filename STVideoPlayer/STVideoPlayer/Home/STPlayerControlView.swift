//
//  STPlayerControlView.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/28.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//  控制层

import UIKit
class STPlayerControlView: UIView {
    
    static func playerImage(imageName: String) -> UIImage {
        let bundle = Bundle.main
        let pathss = bundle.path(forResource: imageName, ofType: "png")
        let string = "STVideoPlayer.bundel" as NSString
        let path = string.appendingPathComponent(imageName)
        let string2 = "Frameworks/STVideoPlayer.framework/ZFPlayer.bundle" as NSString
        let path2 = string2.appendingPathComponent(imageName)
        return UIImage(named:path) ?? UIImage(named: path2)!
        
    }
    
    /// 标题
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    /// 开始播放按钮
    private let startButton: UIButton = {
        let button = UIButton()
        return button
    }()
    /// 当前播放时长
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    /// 视频总时长
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    /// 缓冲进度条
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    /// 滑竿
    private let videoSLider: ASValueTrackingSlider = {
        let slider = ASValueTrackingSlider()
        return slider
    }()
    /// 全屏按钮
    private let fullScreenButton: UIButton = {
        let button = UIButton()
        return button
    }()
    /// 锁定屏幕方向按钮
    private let lockButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(lockScreenButtonClick), for: .touchUpInside)
        return button
    }()
    /// 系统菊花
    private let activity: MMMaterialDesignSpinner = {
        let activity = MMMaterialDesignSpinner()
        return activity
    }()
    /// 返回按钮
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: ""), for: .normal)
        button.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        return button
    }()
    /// 关闭按钮
    private let closeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    /// 重播按钮
    private let repeatButton: UIButton = {
        let button = UIButton()
        return button
    }()
    /// 底部View
    private let bottomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "")
        return imageView
    }()
    /// 顶部View
    private let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ZFPlayer_top_shadow") //STPlayerControlView.playerImage(imageName: "ZFPlayer_top_shadow")
        return imageView
    }()
    /// 缓存按钮
    private let downloadButton: UIButton = {
        let button = UIButton()
        return button
    }()
    /// 切换分分别率按钮
    private let resolutionButton: UIButton = {
        let button = UIButton()
        return button
    }()
    /// 分别率View
    private let resolutionView: UIView = {
        let button = UIButton()
        return button
    }()
    /// 播放按钮
    private let playButton: UIButton = {
        let button = UIButton()
        return button
    }()
    /// 加载失败按钮
    private let failButton: UIButton = {
        let button = UIButton()
        return button
    }()
    /// 快进快退View
    private let fastView: UIView = {
        let view = UIView()
        return view
    }()
    /// 快进快退进度
    private let fastProgressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    /// 快进快退时间
    private let fastTimeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    /// 快进快退ImageView
    private let fastImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    /// 当前选中的分辨率按钮
    weak private var resolutionCurrentButton: UIButton? = {
        let button = UIButton()
        return button
    }()
    /// 占位图
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    /// 控制层消失的时候下方显示的进度条
    private let bottomProgressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    /// 分辨率名称
    private let resolutionArray = Array<Any>()
    /// 播放模型
    private let playerModel: STPlayerModel = {
        let model = STPlayerModel()
        return model
    }()
    /// 显示控制层
    private let showing = false
    /// 小屏幕播放
    private let shrink = false
    /// 在cell上播放
    private let cellVideo = false
    /// 是否拖拽slider控制播放速度
    private let drgged = false
    /// 是否结束播放
    private let playEnd = false
    /// 是否全屏播放
    private let fullScreen = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(placeholderImageView)
        addSubview(topImageView)
        addSubview(bottomImageView)
        
        // 顶部视图
        topImageView.addSubview(backButton)
        topImageView.addSubview(downloadButton)
        
        // 大屏视图
        addSubview(lockButton)
        addSubview(activity)
        addSubview(repeatButton)
        addSubview(playButton)
        addSubview(failButton)
        
        // 底部视图
        bottomImageView.addSubview(startButton)
        bottomImageView.addSubview(currentTimeLabel)
        bottomImageView.addSubview(progressView)
        bottomImageView.addSubview(videoSLider)
        bottomImageView.addSubview(totalTimeLabel)
        bottomImageView.addSubview(fullScreenButton)
        
        addSubview(fastView)
        fastView.addSubview(fastImageView)
        fastView.addSubview(fastTimeLabel)
        fastView.addSubview(fastProgressView)
        
        topImageView.addSubview(resolutionButton)
        topImageView.addSubview(titleLabel)
        
        addSubview(closeButton)
        addSubview(bottomImageView)
        
        makeSubViewsConstraints()
    }
    
    private func makeSubViewsConstraints() {
        
        placeholderImageView.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        })
        
        closeButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.snp.trailing).offset(7)
            make.top.equalTo(self.snp.top).offset(-7)
            make.width.height.equalTo(20)
        }
        
        topImageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(snp.top)
            make.height.equalTo(50)
        }
        backButton.snp.makeConstraints({ (make) in
            make.leading.equalTo((topImageView.snp.leading)).offset(10)
            make.top.equalTo((topImageView.snp.top)).offset(7)
            make.width.height.equalTo(30)
        })
        downloadButton.snp.makeConstraints({ (make) in
            make.width.equalTo(40)
            make.height.equalTo(49)
            make.trailing.equalTo((topImageView.snp.trailing)).offset(-10)
            make.centerY.equalTo((backButton.snp.centerY))
        })
        resolutionButton.snp.makeConstraints({ (make) in
            make.width.equalTo(40)
            make.height.equalTo(25)
            make.trailing.equalTo((downloadButton.snp.leading)).offset(-10)
            make.centerY.equalTo((backButton.snp.centerY))
        })
        titleLabel.snp.makeConstraints({ (make) in
            make.leading.equalTo((backButton.snp.trailing)).offset(5)
            make.centerY.equalTo((backButton.snp.centerY))
            make.trailing.equalTo((resolutionButton.snp.leading)).offset(-10)
        })
        bottomImageView.snp.makeConstraints({ (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(50)
        })
        startButton.snp.makeConstraints { (make) in
            make.leading.equalTo(bottomImageView.snp.leading).offset(5)
            make.bottom.equalTo(bottomImageView.snp.bottom).offset(-5)
            make.width.equalTo(30)
        }
        currentTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(startButton.snp.trailing).offset(-3)
            make.centerY.equalTo(startButton.snp.centerY)
            make.width.equalTo(43)
        }
        fullScreenButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.trailing.equalTo(bottomImageView.snp.trailing).offset(-5)
            make.centerY.equalTo(startButton.snp.centerY)
        }
    }
    
    
    @objc private func backButtonClick() {
        
    }
    
    
    @objc private func lockScreenButtonClick() {
        
    }
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    
    
}
