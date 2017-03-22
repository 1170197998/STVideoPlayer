//
//  STPlayerControlView.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/28.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//  控制层

var bundle = "STVideoPlayer.bundle/"
import UIKit
class STPlayerControlView: UIView {
    
    /// 占位图
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    //顶部视图
    /// 标题
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "标题哈哈"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    /// 返回按钮
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_back_full")), for: .normal)
        button.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        return button
    }()
    /// 缓存按钮
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_download")), for: .normal)
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_not_download")), for: .disabled)
        button.addTarget(self, action: #selector(downloadButtonClick), for: .touchUpInside)
        return button
    }()
    /// 顶部View
    private let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named:  bundle.appending("ZFPlayer_top_shadow.png"))
        return imageView
    }()
    //------------------------------------------------------------------
    /// 底部View
    private let bottomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: bundle.appending("ZFPlayer_bottom_shadow"))
        return imageView
    }()
    /// 开始播放按钮
    private let startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_play")), for: .normal)
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_pause")), for: .disabled)
        button.addTarget(self, action: #selector(playerButtonClick), for: .touchUpInside)
        return button
    }()
    /// 当前播放时长
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "3.10"
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        return label
    }()
    /// 滑竿
    private let videoSlider: ASValueTrackingSlider = {
        let slider = ASValueTrackingSlider()
        return slider
    }()
    /// 视频总时长
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "13.10"
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        return label
    }()
    /// 全屏按钮
    private let fullScreenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_fullscreen")), for: .normal)
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_shrinkscreen")), for: .disabled)
        button.addTarget(self, action: #selector(fullScreenButtonClick), for: .touchUpInside)
        return button
    }()
    /// 控制层消失的时候下方显示的进度条
    private let bottomProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.tintColor = UIColor.white
        progressView.trackTintColor = UIColor.lightGray
        return progressView
    }()

    
    /// 缓冲进度条
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.tintColor = UIColor.white
        progressView.trackTintColor = UIColor.lightGray
        return progressView
    }()
    
    /// 锁定屏幕方向按钮
    private let lockButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_unlock-nor")), for: .normal)
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_lock-nor")), for: .disabled)
        button.addTarget(self, action: #selector(lockScreenButtonClick), for: .touchUpInside)
        return button
    }()
    /// 系统菊花
    private let activity: MMMaterialDesignSpinner = {
        let activity = MMMaterialDesignSpinner()
        activity.lineWidth = 1
        activity.duration = 1
        activity.tintColor = UIColor.white
        return activity
    }()

    /// 重播按钮
    private let repeatButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_repeat_video")), for: .normal)
        button.addTarget(self, action: #selector(repeatButtonClick), for: .touchUpInside)
        return button
    }()
    /// 播放按钮
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: bundle.appending("ZFPlayer_play_btn")), for: .normal)
        button.addTarget(self, action: #selector(centerPlayButtonClick), for: .touchUpInside)
        return button
    }()
    /// 加载失败按钮
    private let failButton: UIButton = {
        let button = UIButton()
        button.setTitle("加载失败, 点击重试", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        button.addTarget(self, action: #selector(failButtonClick), for: .touchUpInside)
        return button
    }()
    /// 快进快退View
    private let fastView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.8)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
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
    /// 关闭按钮
    private let closeButton: UIButton = {
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

    /// 当前选中的分辨率按钮
    weak private var resolutionCurrentButton: UIButton? = {
        let button = UIButton()
        return button
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
        topImageView.addSubview(titleLabel)
        topImageView.addSubview(downloadButton)
        topImageView.addSubview(resolutionButton)

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
        bottomImageView.addSubview(videoSlider)
        bottomImageView.addSubview(totalTimeLabel)
        bottomImageView.addSubview(fullScreenButton)
        
        addSubview(fastView)
        fastView.addSubview(fastImageView)
        fastView.addSubview(fastTimeLabel)
        fastView.addSubview(fastProgressView)
        
        addSubview(closeButton)
        addSubview(bottomImageView)
        
        makeSubViewsConstraints()
    }
    
    private func makeSubViewsConstraints() {
        
        topImageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(snp.top)
            make.height.equalTo(50)
        }
        backButton.snp.makeConstraints({ (make) in
            make.leading.equalTo(10)
            make.top.equalTo(7)
            make.width.height.equalTo(30)
        })
        titleLabel.snp.makeConstraints({ (make) in
            make.leading.equalTo((backButton.snp.trailing)).offset(5)
            make.centerY.equalTo((backButton.snp.centerY))
            make.trailing.equalTo((resolutionButton.snp.leading)).offset(-10)
        })
        downloadButton.snp.makeConstraints({ (make) in
            make.width.equalTo(40)
            make.height.equalTo(49)
            make.trailing.equalTo(-10)
            make.centerY.equalTo((backButton.snp.centerY))
        })
        //-----------------------------------------
        bottomImageView.snp.makeConstraints({ (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(50)
        })
        startButton.snp.makeConstraints { (make) in
            make.leading.equalTo(bottomImageView.snp.leading).offset(5)
            make.bottom.equalTo(-5)
            make.width.equalTo(30)
        }
        currentTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(startButton.snp.trailing).offset(3)
            make.centerY.equalTo(startButton.snp.centerY)
            make.width.equalTo(43)
        }
        fullScreenButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.trailing.equalTo(-5)
            make.centerY.equalTo(startButton.snp.centerY)
        }
        totalTimeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(fullScreenButton.snp.leading).offset(3)
            make.centerY.equalTo(startButton.snp.centerY)
            make.width.equalTo(43)
        }
        videoSlider.snp.makeConstraints { (make) in
            make.leading.equalTo(currentTimeLabel.snp.trailing).offset(3)
            make.trailing.equalTo(totalTimeLabel.snp.leading).offset(-3)
            make.centerY.equalTo(startButton.snp.centerY)
        }
        lockButton.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalTo(snp.centerY)
            make.width.height.equalTo(32)
        }
        //中心区域的视图----------------------------
        repeatButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.height.equalTo(50)
        }
        activity.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.height.equalTo(45)
        }
        failButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(130)
            make.height.equalTo(35)
        }
        fastView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(130)
            make.height.equalTo(80)
        }

        placeholderImageView.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        })
        
        closeButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.snp.trailing).offset(7)
            make.top.equalTo(self.snp.top).offset(-7)
            make.width.height.equalTo(20)
        }
        resolutionButton.snp.makeConstraints({ (make) in
            make.width.equalTo(40)
            make.height.equalTo(25)
            make.trailing.equalTo((downloadButton.snp.leading)).offset(-10)
            make.centerY.equalTo((backButton.snp.centerY))
        })
    }
    
    /// 返回按钮
    @objc private func backButtonClick() {
        
    }
    
    /// 锁定全屏按钮
    @objc private func lockScreenButtonClick() {
        
    }
    
    /// 下载按钮
    @objc private func downloadButtonClick() {
        
    }
    /// 播放按钮
    @objc private func playerButtonClick() {
        
    }
    /// 全屏播放按钮
    @objc private func fullScreenButtonClick() {
        
    }
    /// 重新播放按钮
    @objc private func repeatButtonClick() {
        
    }
    /// 中心区域播放按钮
    @objc private func centerPlayButtonClick() {
        
    }
    /// 播放失败按钮
    @objc private func failButtonClick() {
        
    }

    
    
    
    
    
    
    
    
    
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
    
    
}


extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
