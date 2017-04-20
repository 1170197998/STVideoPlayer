//
//  STPlayerView.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/25.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

let kZFPlayerViewContentOffset = "contentOffset"


// MARK: - 枚举定义
/// PlayerLayer的填充模式
enum PlayerFillMode {
    case Resize             //非均匀模式,两个维度完全填充整个视图区域
    case ResizeAspect       //等比例填充,直到一个维度达到区域边界
    case ResizeAspectFill   //等比例填充,直到充满整个视图区域,其中一个维度的部分会被裁掉
}

/// 播放状态
enum PlayerState {
    case Failed     //播放失败
    case Buffering  //缓冲中
    case Playing    //播放中
    case Stoppped   //停止播放
    case Pause      //暂停播放
}

/// 移动方向
enum PanDirection {
    case HorizontalMoved    //水平
    case VerticalMoved      //垂直
}

// MARK: -
class STPlayerView: UIView {
    
    // MARK: - 公开属性
    /// 是否有下载功能
    var hasDownloader: Bool = false
    /// 是否开启预览图
    var hasPreviewImage: Bool = false
    /// 是否被用户暂停
    var isPauseByUser: Bool = false
    /// 是否静音
    var mute: Bool = false
    /// 当Cell滑屏幕外的时候,是否停止播放
    var stopPlayWhenCellNotVisable: Bool = false
    /// 由全屏回到小屏的时候是否回到中间位置
    var cellPlayerOnCenter: Bool?
    weak var delegate: PlayerViewDelegate? {
        didSet {
            /// 做了一个代理传递的效果http://blog.csdn.net/feng2qing/article/details/51489548?locationNum=1&fps=1, 本界面不需要实现代理方法, 直接传递给上层控制器
            (controlView as! STPlayerControlView).delegate = delegate
        }
    }
    /// 播放器状态
    var playerState: PlayerState?
    /// PlayerLayer的填充模式
    var playerFillMode: PlayerFillMode?

    // MARK: - 私有属性
    /// 播放属性
    fileprivate var player: AVPlayer?
    fileprivate var playerItem: AVPlayerItem? {
        didSet {
            NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    fileprivate var urlAsset: AVURLAsset?
    fileprivate var imageGenerator: AVAssetImageGenerator?
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var timeObserver: AnyObject?
    /// 滑杆
    fileprivate var volumeViewSlider: UISlider?
    /// 播放总时长
    fileprivate var sumTime: CGFloat?
    /// 移动方向
    fileprivate var panDirection: PanDirection?
    /// 播放状态
    fileprivate var state: PlayerState? {
        didSet {
            
        }
    }
    
    /// 是否全屏
    fileprivate var isFullScreen: Bool = false
    /// 是否锁定屏幕方向
    fileprivate var isLocked: Bool = false
    /// 是否在调节音量
    fileprivate var isVolume: Bool = false
    /// 是否被用户暂停
    fileprivate var isPause: Bool = false
    /// 是否播放本地文件
    fileprivate var isLocalVideo: Bool = false
    /// slider上次的值
    fileprivate var sliderLastValue: CGFloat?
    /// 是否再次设置url播放视频
    fileprivate var repeatToPlayer: Bool = false
    /// 播放完毕
    fileprivate var playDidEnd: Bool = false
    /// 进入后台
    fileprivate var didEnterBackground: Bool = false
    /// 是否自动播放
    fileprivate var isAutoPlay: Bool = false
    /// 单击手势
    fileprivate var singleTap: UITapGestureRecognizer?
    /// 双击手势
    fileprivate var doubleTap: UITapGestureRecognizer?
    /// 视频url数组
    fileprivate var videoUrlArray: Array<AnyObject>?
    /// slider预览图
    fileprivate var thumbImage: UIImage?
    /// 亮度
    fileprivate var brightnessView: STBrightnessView?
    
    fileprivate var tableView: UITableView?
    fileprivate var indexPath: NSIndexPath?
    /// ViewController中页面是否消失
    fileprivate var viewDisappear: Bool?
    /// 是否在cell上播放视频
    fileprivate var isCellVideo: Bool = false
    /// 是否缩小视频在底部
    fileprivate var isBottomVideo: Bool = false
    /// 是否切换分别率
    fileprivate var isChangeResolution: Bool?
    /// 是否正在拖拽
    fileprivate var isDragging: Bool? = false
    /// 控制层View
    fileprivate var controlView: UIView?
    fileprivate var playerModel: STPlayerModel! {
        didSet {
            if ((playerModel?.seekTime) != nil) {
                seekTime = playerModel?.seekTime
            }
            //            controlView.playerModel()
            if ((playerModel?.tableView) != nil) && ((playerModel?.indexPath) != nil) && ((playerModel?.videoUrl.absoluteString) != nil) {
                cellVideoWithTableView(tableView: (playerModel?.tableView)!, indexPath: (playerModel?.indexPath)!)
                if ((playerModel?.resolutionDict) != nil) {
                    resolutionDict = playerModel?.resolutionDict
                }
            }
            addPlayerToFatherView(view: (playerModel?.fatherView)!)
            videoUrl = playerModel?.videoUrl
        }
    }
    
    fileprivate var seekTime: NSInteger?
    fileprivate var videoUrl: URL? {
        didSet {
            repeatToPlayer = false
            playDidEnd = false
            addNotifications()
            isPauseByUser = true
            createGesture()
        }
    }
    
    fileprivate var resolutionDict: Dictionary<String, Any>? {
        didSet {
//            controlView?.playerResolutionArray(resolutionArray: resolutionDict?.keys)
//            videoUrlArray = resolutionDict?.values
        }
    }
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        cellPlayerOnCenter = true
        
        backgroundColor = UIColor.gray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        playerLayer?.frame = bounds
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    deinit {
        //移除通知
        NotificationCenter.default.removeObserver(self)
        //移除KVO
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        // 先移除playerItem 的观察对象再移除playerItem
        playerItem = nil
        tableView = nil
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        if (timeObserver != nil) {
            player?.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    /// 用于在cell上播放player
    private func cellVideoWithTableView(tableView: UITableView, indexPath: NSIndexPath) {
        if !viewDisappear! && (playerItem != nil) {
            resetPlayer()
        }
        isCellVideo = true
        viewDisappear = false
        self.tableView = tableView
        self.indexPath = indexPath;
        controlView?.playerCellPlay()
    }
    
    fileprivate func addPlayerToFatherView(view: UIView) {
        removeFromSuperview()
        view.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
    }
    
    fileprivate func resetToPlayNewUrl() {
        repeatToPlayer = true
        resetPlayer()
    }
    
    // MARK: - 方法
    /// 创建手势 单击 / 双加
    private func createGesture() {
        
        //单击
        singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(gesture:)))
        singleTap?.delegate = self;
        singleTap?.numberOfTouchesRequired = 1  //手指数
        singleTap?.numberOfTapsRequired = 1     //点击次数
        addGestureRecognizer(singleTap!)
        
        //双击
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(gesture:)))
        doubleTap?.delegate = self
        doubleTap?.numberOfTouchesRequired = 1
        doubleTap?.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap!)
    }
    
    private func addNotifications() {
        //app进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        //app进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterPlayground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        // 检测设备方向
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStatusBarOrientationChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    // MARK: - 事件监听
    /// 单击 是否显示控制层
    @objc private func singleTapAction(gesture: UIGestureRecognizer) {
        if gesture.isKind(of: NSNumber.self) && !(gesture as AnyObject).boolValue{
            fullScreenAction()
            return
        }
        if gesture.state == UIGestureRecognizerState.recognized {
            if isBottomVideo && isFullScreen {
                fullScreenAction()
            } else {
                if playDidEnd {
                    return
                } else {
                    controlView?.playerShowControlView()
                }
            }
        }
    }
    
    /// 双击 播放 / 暂停
    @objc private func doubleTapAction(gesture: UIGestureRecognizer) {
        if playDidEnd {
            controlView?.playerCancelAutoFadeOutControlView()
            controlView?.playerShowControlView()
        }
        if isPauseByUser {
            play()
        } else {
            pause()
        }
        if !isAutoPlay {
            isAutoPlay = true
            configPLayer()
        }
    }
    
    @objc private func moviePlayDidEnd(notification: NSNotification) {
        state = .Stoppped
        if isBottomVideo && isFullScreen {
            repeatToPlayer = false
            playDidEnd = false
        } else {
            if !isDragging! {
                playDidEnd = true
                controlView?.playerPlayEnd()
            }
        }
    }
    
    /// APP进入后台
    @objc fileprivate func appDidEnterBackground() {
        didEnterBackground = true
        // 退到后台锁定屏幕方向
        STBrightnessView.shared.isLockScreen = true
        player?.pause()
        state = .Pause
    }
    
    /// APP进入前台
    @objc fileprivate func appDidEnterPlayground() {
        didEnterBackground = false
        STBrightnessView.shared.isLockScreen = isLocked
        if !isPauseByUser {
            state = .Playing
            isPauseByUser = false
            play()
        }
    }
    
    /// 缩小到底部 显示小视频
    fileprivate func updatePlayerViewToBottom() {
        if isBottomVideo {
            return
        }
        isBottomVideo = true
        if playDidEnd {
            //当播放完成的时候,滑动到小屏bottom位置的时候,直接resetPlayer
            repeatToPlayer = false
            playDidEnd = false
            resetPlayer()
            return
        }
        layoutIfNeeded()
        UIApplication.shared.keyWindow?.addSubview(self)
        self.snp.makeConstraints { (make) in
            let width = UIScreen.main.bounds.width * 0.5 - 20
            let height = bounds.size.height / bounds.size.width
            make.width.equalTo(width)
            make.height.equalTo(self.snp.width).multipliedBy(height)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(-Int((self.tableView?.contentInset.bottom)!) - 10)
        }
        controlView?.playerBottomShrinkPlay()
    }
    
    
    /// 解锁屏幕锁定方向
    fileprivate func unLockTheScreen() {
        STBrightnessView.shared.isLockScreen = false
        controlView?.playerPlayBtnState(state: false)
        isLocked = false
        interfaceOrientation(orientation: UIInterfaceOrientation.portrait)
    }
    
    /// 单例
    static let shared = STPlayerView()
    
    /// 指定控制的控制层和模型(传nil,代表使用当前控制器,在这里指的是PlayerViewController)
    //tips:如果 参数不是必须的,可以是nil的话,在类型后一个问号就可以,调用也可以传入nil
    func playerControlView(controlView: UIView?, playerModel: STPlayerModel) {
        if (controlView == nil) {
            self.controlView = STPlayerControlView()
            (self.controlView as! STPlayerControlView).delegateControl = self
            addSubview(self.controlView!)
            self.controlView?.snp.makeConstraints({ (make) in
                make.top.leading.trailing.bottom.equalTo(self)
            })
        } else {
            self.controlView = controlView
        }
        self.playerModel = playerModel
    }
    
    /// 自动播放
    func autoPlayTheVideo() {
        configPLayer()
    }
    
    /// 重置player
    func resetPlayer() {
        playDidEnd = false
        playerItem = nil
        didEnterBackground = false
        seekTime = 0
        isAutoPlay = false
        if (timeObserver != nil) {
            player?.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
        pause()
        playerLayer?.removeFromSuperlayer()
        player?.replaceCurrentItem(with: nil)
        imageGenerator = nil
        player = nil
        if isChangeResolution! {
            //切换分别率
            controlView?.playerResetControlViewForResolution()
            isChangeResolution = false
        } else {
            //重置控制层view
            controlView?.playerResetControlView()
        }
        controlView = nil
        
        if !repeatToPlayer {
            removeFromSuperview()
        }
        isBottomVideo = false
        
        if isCellVideo && repeatToPlayer {
            viewDisappear = true
            isCellVideo = false
            tableView = nil
            indexPath = nil
        }
    }
    
    /// 在当前界面,设置新的视频调用此方法
    func resetPlayerNewVideo(playerModel: STPlayerModel) {
        repeatToPlayer = true
        resetPlayer()
        self.playerModel = playerModel
        configPLayer()
    }
    
    /// 播放
    func play() {
        controlView?.playerPlayBtnState(state: true)
        if state == .Pause {
            state = .Playing
        }
        isPauseByUser = false
        player?.play()
        if !isBottomVideo {
            // 显示控制层
            controlView?.playerCancelAutoFadeOutControlView()
            controlView?.playerShowControlView()
        }
    }
    
    /// 暂停
    func pause() {
        controlView?.playerPlayBtnState(state: false)
        if state == .Playing {
            state = .Pause
            isPauseByUser = true
            player?.pause()
        }
    }
    
    /// 设置player相关参数
    fileprivate func configPLayer() {
        urlAsset = AVURLAsset(url:videoUrl!)
        // 初始化playerItem
        playerItem = AVPlayerItem.init(asset: urlAsset!)
        player = AVPlayer(playerItem: playerItem)
        // 初始化playerLayer
        playerLayer = AVPlayerLayer.init(player: player)
        backgroundColor = UIColor.black
        // 默认视频填充模式
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        isAutoPlay = true
        // 播放进度计时器
        createTimer()
        // 获取系统音量
        configureVolume()
        if videoUrl?.scheme == "file" {
            state = .Playing
            isLocalVideo = true
            controlView?.playerDownloadBtnState(state: false)
        } else {
            state = .Buffering
            isLocalVideo = false
            controlView?.playerDownloadBtnState(state: true)
        }
        play()
        isPauseByUser = false
    }
    
    /// 进度计时器
    private func createTimer() {
        weak var weakSelf = self
        timeObserver = weakSelf?.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1, preferredTimescale: 1), queue: nil, using: { (time) in
            let currentItem = weakSelf?.playerItem
            let loadedRange = currentItem?.seekableTimeRanges
            if (loadedRange?.count)! > 0 && (currentItem?.duration.timescale)! != 0 {
                let currentTime = CMTimeGetSeconds((currentItem?.currentTime())!)
                let totalTime: CGFloat = CGFloat((currentItem?.duration.value)!) / CGFloat((currentItem?.duration.timescale)!)
                let value = CGFloat(CMTimeGetSeconds((currentItem?.currentTime())!)) / totalTime
                weakSelf?.controlView?.playCurrentTime(currentTime: NSInteger(currentTime), totalTime: NSInteger(totalTime), sliderValue: value)
            }
        }) as AnyObject?
    }
    
    /// KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? AVPlayerItem == player?.currentItem {
            if keyPath == "status" {
                if player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
                    setNeedsLayout()
                    layoutIfNeeded()
                    //添加playerLayer到self.layer
                    self.layer.insertSublayer(playerLayer!, at: 0)
                    state = .Playing
                    
                    //加载完成后添加平移手势,  控制音量 亮度  进退
                    let pan = UIPanGestureRecognizer(target: self, action: #selector(panDirections(pan:)))
                    pan.delegate = self
                    pan.maximumNumberOfTouches = 1
                    pan.cancelsTouchesInView = true
                    self.addGestureRecognizer(pan)
                    
                    //跳到XX秒播放视频
                    if (seekTime != nil) {
                        
                    }
                    player?.isMuted = mute
                } else if player?.currentItem?.status == .failed {
                    state = .Failed
                }
            } else if keyPath == "loadedTimeRanges" {
                //计算缓冲进度
                let timeInterval = availableDuration()
                let duration = playerItem?.duration
                let totalDuration =  CMTimeGetSeconds(duration!)
                controlView?.playerSetProgress(progress: CGFloat(timeInterval) / CGFloat(totalDuration))
            } else if keyPath == "playbackBufferEmpty" {
                //当缓冲是空的时候
                if (playerItem?.isPlaybackBufferEmpty)! {
                    self.state = .Buffering
                    bufferingSomeSecond()
                }
            } else if keyPath == "playbackLikelyToKeepUp" {
                // 当缓冲好的时候
                if (playerItem?.isPlaybackLikelyToKeepUp)! && state == .Buffering {
                    state = .Playing
                }
            }
        } else if (object as? UITableView == self.tableView) {
            if keyPath == "kZFPlayerViewContentOffset" {
                if self.isFullScreen {
                    return
                }
                //当tableView滑动的时候处理playerView的位置
                handleScrollOffsetWithDict(dict: change!)
            }
        }
    }
    
    /// 手势事件
    @objc private func panDirections(pan: UIPanGestureRecognizer) {
        
    }
    
    private func availableDuration() -> TimeInterval {
        return 0.1
    }
    
    /// 缓冲较差的时候回调用这里
    private func bufferingSomeSecond() {
        
    }
    
    /// KVO TableViewContentOffset
    private func handleScrollOffsetWithDict(dict: Dictionary<NSKeyValueChangeKey, Any>) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 屏幕旋转相关操作
extension STPlayerView {
    /// 屏幕方向发生变化调用这里
    //UIDeviceOrientation      是机器硬件的当前旋转方向   这个只能取值 不能设置
    //UIInterfaceOrientation   是你程序界面的当前旋转方向   这个可以设置
    @objc fileprivate func onDeviceOrientationChange() {
        if (!(player != nil)) {
            return
        }
        if STBrightnessView.shared.isLockScreen {
            return
        }
        if didEnterBackground {
            return
        }
        // 当前设备方向
        let orientation = UIDevice.current.orientation
        // 如果手机硬件屏幕朝上或者屏幕朝下或者未知
        if orientation == UIDeviceOrientation.faceUp || orientation == UIDeviceOrientation.faceDown || orientation == UIDeviceOrientation.unknown {
            return
        }
        let interfaceOrientation: UIInterfaceOrientation = UIInterfaceOrientation(rawValue: orientation.rawValue)!
        switch interfaceOrientation {
        //屏幕竖直,home键在上面
        case UIInterfaceOrientation.portraitUpsideDown: break
        //屏幕竖直,home键在下面
        case UIInterfaceOrientation.portrait:
            if isFullScreen {
                toOrientation(orientation: UIInterfaceOrientation.portrait)
            }; break
        //屏幕水平,home键在左
        case UIInterfaceOrientation.landscapeLeft:
            if isFullScreen == false {
                toOrientation(orientation: UIInterfaceOrientation.landscapeLeft)
                isFullScreen = true
            } else {
                toOrientation(orientation: UIInterfaceOrientation.landscapeLeft)
            }; break
        //屏幕水平,home键在右
        case UIInterfaceOrientation.landscapeRight:
            if isFullScreen == false {
                toOrientation(orientation: UIInterfaceOrientation.landscapeRight)
                isFullScreen = true
            } else {
                toOrientation(orientation: UIInterfaceOrientation.landscapeRight)
            }; break
            
        default:
            break
        }
    }
    
    /// 旋转
    ///
    /// - Parameter orientation: 要旋转的方向
    private func toOrientation(orientation: UIInterfaceOrientation) {
        
        //获取当前状态栏的方向
        let currentOrientation = UIApplication.shared.statusBarOrientation
        //如果当前的方向和要旋转的方向一致,就不做任何操作
        if currentOrientation == orientation {
            return
        }
        //根据要旋转的方向,重新布局
        //UIInterfaceOrientation.portrait屏幕竖直,home键在下面
        if orientation != UIInterfaceOrientation.portrait {
            // 这个地方加判断是为了从全屏的一侧,直接到全屏的另一侧不用修改限制,否则会出错;
            if currentOrientation == UIInterfaceOrientation.portrait {
                self.removeFromSuperview()
                let brightnessView = STBrightnessView.shared
                UIApplication.shared.keyWindow?.insertSubview(self, belowSubview: brightnessView)
                //从全屏的一侧,直接到全屏的另一侧不用修改限制
                self.snp.makeConstraints({ (make) in
                    make.width.equalTo(UIScreen.main.bounds.size.height)
                    make.height.equalTo(UIScreen.main.bounds.size.width)
                    make.center.equalTo(UIApplication.shared.keyWindow!)
                })
            }
        }
        //状态栏旋转
        UIApplication.shared.setStatusBarOrientation(orientation, animated: false)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.35)
        self.transform = CGAffineTransform.identity
        self.transform = getTransformRotationAngle()
        UIView.commitAnimations()
        controlView?.layoutIfNeeded()
        controlView?.setNeedsLayout()
    }
    
    /// 获取变换的旋转角度
    private func getTransformRotationAngle() -> CGAffineTransform {
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        if interfaceOrientation == UIInterfaceOrientation.portrait {
            return CGAffineTransform.identity
        } else if interfaceOrientation == UIInterfaceOrientation.landscapeLeft {
            return CGAffineTransform(rotationAngle: (CGFloat)(-Double.pi/2))
        } else if (interfaceOrientation == UIInterfaceOrientation.landscapeRight) {
            return CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        return CGAffineTransform.identity
    }
    
    /// 全屏
    fileprivate func fullScreenAction() {
        if STBrightnessView.shared.isLockScreen {
            unLockTheScreen()
            return
        }
        if isFullScreen {
            interfaceOrientation(orientation: UIInterfaceOrientation.portrait)
            isFullScreen = false
            return
        } else {
            let orientation = UIDevice.current.orientation
            if orientation == UIDeviceOrientation.landscapeRight {
                interfaceOrientation(orientation: UIInterfaceOrientation.landscapeLeft)
            } else {
                interfaceOrientation(orientation: UIInterfaceOrientation.landscapeRight)
            }
            isFullScreen = true
        }
    }
    
    /// 屏幕旋转
    ///
    /// - Parameter orientation: 屏幕方向
    fileprivate func interfaceOrientation(orientation: UIInterfaceOrientation) {
        if orientation == UIInterfaceOrientation.landscapeRight || orientation == UIInterfaceOrientation.landscapeLeft {
            setOrientationLandscapeConstraint(orientation: orientation)
        } else if orientation == UIInterfaceOrientation.portrait {
            setOrientationPortraitConstraint()
        }
    }

    /// 状态条发生变化
    @objc fileprivate func onStatusBarOrientationChange() {
        if !didEnterBackground {
            //获取当前状态栏方向
            let currentOrientation = UIApplication.shared.statusBarOrientation
            if currentOrientation == UIInterfaceOrientation.portrait {
                setOrientationPortraitConstraint()
                if cellPlayerOnCenter! {
                    tableView?.scrollToRow(at: indexPath! as IndexPath, at: .middle, animated: false)
                }
                brightnessView?.removeFromSuperview()
                UIApplication.shared.keyWindow?.addSubview(brightnessView ?? UIView())
                brightnessView?.snp.makeConstraints({ (make) in
                    make.width.height.equalTo(155)
                    make.leading.equalTo((UIScreen.main.bounds.width - 155) / 2)
                    make.top.equalTo((UIScreen.main.bounds.height - 155) / 2)
                })
            } else {
                if currentOrientation == UIInterfaceOrientation.landscapeRight {
                    toOrientation(orientation: UIInterfaceOrientation.landscapeRight)
                } else if currentOrientation == UIInterfaceOrientation.landscapeLeft {
                    toOrientation(orientation: UIInterfaceOrientation.landscapeLeft)
                }
                brightnessView?.removeFromSuperview()
                addSubview((brightnessView ?? UIView())!)
                brightnessView?.snp.makeConstraints({ (make) in
                    make.center.equalTo(self)
                    make.width.height.equalTo(155)
                })
            }
        }
    }
    
    /// 设置横屏约束
    private func setOrientationLandscapeConstraint(orientation: UIInterfaceOrientation) {
        toOrientation(orientation: orientation)
        isFullScreen = true
    }
    
    /// 设置竖屏约束
    private func setOrientationPortraitConstraint() {
        if isCellVideo  {
            let cell = tableView?.cellForRow(at: indexPath! as IndexPath)
            let visableCells = tableView?.visibleCells
            isBottomVideo = false
            if !(visableCells?.contains(cell!))! {
                updatePlayerViewToBottom()
            } else {
                addPlayerToFatherView(view: (playerModel?.fatherView)!)
            }
        } else {
            addPlayerToFatherView(view: (playerModel?.fatherView)!)
        }
        toOrientation(orientation: UIInterfaceOrientation.portrait)
        isFullScreen = false
    }
}


// MARK: - 音量耳机相关
extension STPlayerView {
    
    /// 获取系统音量
    fileprivate func configureVolume() {
        let volumeView = MPVolumeView()
        volumeViewSlider = nil
        for view in volumeView.subviews {
            if NSStringFromClass(view.classForCoder) == "MPVolumeSlider" {
                volumeViewSlider = view as? UISlider
                break
            }
        }
        // 两种try
        //        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        //        let success = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        //        do {
        //            //没有返回值
        //            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        //            NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListenerCallback(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        //        } catch  {
        //        }
    }

    /// 耳机插入 拔出事件
    @objc private func audioRouteChangeListenerCallback(notification: NSNotification) {
        
        let infoDict = notification.userInfo
        guard let routeChangeReason = infoDict?[AVAudioSessionRouteChangeReasonKey] as! AVAudioSessionRouteChangeReason? else {
            return
        }
        switch routeChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable:
            print("耳机插入")
            break
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
            print("耳机拔出,决定是否继续播放")
            break
        case AVAudioSessionRouteChangeReason.categoryChange:
            print("12")
            break
            
        default: break
        }
    }
}

// MARK: - PlayerControlViewDelagate
extension STPlayerView: PlayerControlViewDelagate {
    
    func lockScreenButtonClick() {
        
    }
    func playerButtonClick() {
        
    }
    func fullScreenButtonClick() {
        fullScreenAction()
    }
    func repeatButtonClick() {
        
    }
    func centerPlayButtonClick() {
        
    }
    func failButtonClick() {
        
    }
}

// MARK: - UIGestureRecognizerDelegate
extension STPlayerView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            if isCellVideo && isFullScreen || playDidEnd || isLocked {
                return false
            }
        }
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            if isBottomVideo && isFullScreen {
                return false
            }
        }
        if (touch.view?.isKind(of: UISlider.self))! {
            return false
        }
        return true
    }
}
