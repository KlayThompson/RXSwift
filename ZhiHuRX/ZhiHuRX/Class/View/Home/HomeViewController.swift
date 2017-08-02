//
//  HomeViewController.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/2.
//  Copyright © 2017年 Brain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    @IBOutlet weak var menuItem: UIBarButtonItem!
    
    
    /// 菜单视图
    let menuView = MenuViewController.shareManager
    let disposBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBarUI()
        
        menuItem.rx
            .tap
            .subscribe(onNext: {
                self.menuView.showMenuView = !self.menuView.showMenuView
            })
            .addDisposableTo(disposBag)
        
    }


}

// MARK: - 设置界面
private extension HomeViewController {

    func setBarUI() {
        //将菜单添加到KeyWindow上面
        UIApplication.shared.keyWindow?.addSubview(menuView.view)
    }
}
