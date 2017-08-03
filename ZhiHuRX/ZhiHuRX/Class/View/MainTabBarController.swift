//
//  MainTabBarController.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/2.
//  Copyright © 2017年 Brain. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import Kingfisher

class MainTabBarController: UITabBarController {
    
    let provider = RxMoyaProvider<APIManager>()
    let disposebag = DisposeBag()
    let launchImageView = UIImageView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setLaunchView()
    }

    func setLaunchView() {
       
        //设置frame添加到view上
        launchImageView.frame = CGRect(x: 0, y: 0, width: screenW, height: screenH)
        launchImageView.backgroundColor = UIColor.black
        launchImageView.alpha = 0.99
        view.addSubview(launchImageView)
        
        //加载网络的启动图
        provider
            .request(.getLaunchImage)
            .mapModel(LaunchModel.self)
            .subscribe(onNext: { (model) in
                guard let imageModel = model.creatives?.first else {
                    self.launchImageView.removeFromSuperview()
                    return
                }
                
                self.launchImageView.kf.setImage(with: URL(string: imageModel.url ?? ""), placeholder: UIImage(named: ""), options: nil, progressBlock: nil, completionHandler: { (_, _, _, _) in
                    
                    //设置动画
                    UIView.animate(withDuration: 1.5, animations: { 
                        self.launchImageView.alpha = 1
                    }, completion: { (_) in
                        //显示完成，移除
                        UIView.animate(withDuration: 0.3, animations: { 
                            self.launchImageView.alpha = 0
                        }, completion: { (_) in
                            self.launchImageView.removeFromSuperview()
                        })
                    })
                })
                
            })
            .disposed(by: disposebag)
        
    }

}
