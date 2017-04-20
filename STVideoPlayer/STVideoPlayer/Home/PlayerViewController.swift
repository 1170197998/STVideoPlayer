//
//  PlayerViewController.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/24.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//


import UIKit
class PlayerViewController: UIViewController {

    /// 视频URL
    var videoUrl: URL? = nil
    /// 播放器的父视图
    private var playerFatherView: UIView?
    /// 播放器视图
    private var playerView: STPlayerView?
    /// 离开界面时候是否在播放
    private var isPlaying: Bool?
    /// 写一个playerModel的get方法
    private lazy var playerModel: STPlayerModel = {
        let playerModel = STPlayerModel()
        playerModel.title = "视频标题"
        playerModel.videoUrl = self.videoUrl
        playerModel.placeholderImage = UIImage(named: "loading_bgView1")!
        playerModel.fatherView = self.playerFatherView
        return playerModel
    }()
    private var bottomView: UIView?
    
    // MARK: - life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        navigationController?.isNavigationBarHidden = true
        // pop回来自动播放
        if navigationController?.viewControllers.count == 2 && (playerView != nil) && isPlaying ?? false {
            isPlaying = false
            playerView?.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(.default, animated: false)
        navigationController?.isNavigationBarHidden = false
        // push出下一界面的时候暂停
        if navigationController?.viewControllers.count == 3 && (playerView != nil) && (playerView?.isPauseByUser)! {
            isPlaying = true
            playerView?.pause()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        print(videoUrl ?? "")
        
        /// 播放器父视图
        playerFatherView = UIView()
        self.view.addSubview(playerFatherView!)
        playerFatherView?.snp.makeConstraints({ (make) in
            make.top.equalTo(0)
            make.leading.trailing.equalTo(0)
            make.height.equalTo((playerFatherView?.snp.width)!).multipliedBy(9.0 / 16.0)
        })

        /// 播放器视图
        playerView = STPlayerView()
        playerView?.playerControlView(controlView: nil, playerModel: self.playerModel)
        playerView?.delegate = self
        //打开下载功能,默认没有
        playerView?.hasDownloader = true
        //打开预览视图
        playerView?.hasPreviewImage = true
        //是否自动播放.默认没有
        playerView?.autoPlayTheVideo()
    }
    
    /// 是否支持屏幕旋转 NO
    override var shouldAutorotate: Bool {
        return false
    }
}

// MARK: - PlayerVideDelegate
extension PlayerViewController: PlayerViewDelegate {
    
    func backButtonClick() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func downloadButtonClick(videoUrl: URL) {
        //截取的下载地址，可以自己根据服务器的视频名称来赋值
        let urlString = videoUrl.absoluteString
        let name = (urlString as NSString).lastPathComponent
        ZFDownloadManager.shared().downFileUrl(urlString, filename: name, fileimage: nil)
        //设置最多同时下载个数（默认是3）
        ZFDownloadManager.shared().maxCount = 4
    }
}
