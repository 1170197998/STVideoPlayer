//
//  ViewController.swift
//  STVideoPlayer
//
//  Created by ShaoFeng on 2017/2/24.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var dataArray: Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataArray = ["http://7xqhmn.media1.z0.glb.clouddn.com/femorning-20161106.mp4",
                     "http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
                     "http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                     "http://baobab.wdjcdn.com/14525705791193.mp4",
                     "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                     "http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                     "http://baobab.wdjcdn.com/1455782903700jy.mp4",
                     "http://baobab.wdjcdn.com/14564977406580.mp4",
                     "http://baobab.wdjcdn.com/1456316686552The.mp4",
                     "http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                     "http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                     "http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                     "http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                     "http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                     "http://baobab.wdjcdn.com/1456734464766B(13).mp4",
                     "http://baobab.wdjcdn.com/1456653443902B.mp4",
                     "http://baobab.wdjcdn.com/1456231710844S(24).mp4"]
        
        setupTableView()
    }

    fileprivate func setupTableView() {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self;
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(0)
        }
        tableView.tableFooterView = UIView()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}

// MARK: - UITableViewDataSource,UITableViewDelegate
extension HomeViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataArray?.count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "ID")
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "ID")
        }
        cell?.textLabel?.text = "data\(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PlayerViewController()
        let urlString:String = dataArray![indexPath.row]
        vc.videoUrl = URL(string:urlString)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        vc.hidesBottomBarWhenPushed = false
    }
}
