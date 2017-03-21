//
//  STVideoPlayer-Bridge.h
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/25.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//
//  在这里包含OC类头文件
//
//  tips:手动创建STVideoPlayer-Bridge.h文件后,在Build Setteings 中找到 Objective_C Bridging Header 添加路径$(SRCROOT)/STVideoPlayer/STVideoPlayer-Bridge.h

//  tips:
//  (1)swift项目cocoapods 默认 use_frameworks!
//  (2)OC项目cocoapods 默认 #use_frameworks!
//  导入SnapKit的时候,需要use_frameworks!,否则,pod update通不过,但是OC框架ZFDownload里的ASI却不能用这个,所以暂时SNapKit没有使用pod,直接拽进来https://segmentfault.com/a/1190000007076865  https://segmentfault.com/a/1190000007076865

// OC 头文件
#import "ZFDownload/ZFDownloadManager.h"
#import "ASValueTrackingSlider.h"
#import "MMMaterialDesignSpinner.h"
