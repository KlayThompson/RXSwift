//
//  MenuViewController.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/2.
//  Copyright © 2017年 Brain. All rights reserved.
//

import UIKit
import RxSwift
import Moya

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposBag = DisposeBag()
    /// 存放主题的数组
    var themeArray = Variable([ThemeModel]())
    /// 请求网络
    let provider = RxMoyaProvider<APIManager>()
    //控制菜单显示与否变量
    var showMenuView = false {
        didSet {//利用didSet来实现
            showMenuView ? showMenu() : dismissMenu()
        }
    }
    //tabBar
    var tabBar: UITabBarController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lodaData()
    }
}

// MARK: - 请求网络数据
private extension MenuViewController {

    func lodaData() {
        //加载主题数据
        provider.request(.getThemeList)
            .mapModel(ThemeResponseModel.self)
            .subscribe(onNext: {(model) in
                guard let others = model.others else {
                    return
                }
                self.themeArray.value = others
                //设置第一个首页model
                var homeModel = ThemeModel()
                homeModel.name = "首页"
                self.themeArray.value.insert(homeModel, at: 0)
            })
            .addDisposableTo(disposBag)
        
        //绑定数据
        themeArray.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "ThemeTableViewCell", cellType: ThemeTableViewCell.self)) {row, model, cell in
                cell.nameLabel.text = model.name
                cell.homeIcon.isHidden = row == 0 ? false : true
                cell.nameLabelLeftCons.constant = row == 0 ? 50 : 15
        }
        .addDisposableTo(disposBag)
        
        //点击处理
        tableView.rx
            .modelSelected(ThemeModel.self)
            .subscribe(onNext: {(model) in
                //隐藏菜单视图
                self.showMenuView = false
                //更改主题
                self.showThemeView(model: model)
            })
            .addDisposableTo(disposBag)
    }
}

// MARK: - 自定义方法
extension MenuViewController {
    
    func showThemeView(model: ThemeModel) {
        //这么做是行不通的，因为navigationController为空
        //这个方法是使用uitabbar来处理，selectIndex
        if model.id == nil {
            tabBar?.selectedIndex = 0
        } else {
            //跳转到Theme
            tabBar?.selectedIndex = 1
            //传递数据模型model过去
            //通知
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CHANGETHEME"), object: nil, userInfo: ["model" : model])
            //因为第一次点击的时候ThemeViewController还没有创建，接收不到通知，故只能保存在本地，然后在创建的时候取出本地的来使用
            UserDefaults.standard.set(model.name, forKey: "themeName")
            UserDefaults.standard.set(model.thumbnail, forKey: "themeThumbnail")
            UserDefaults.standard.set(model.id, forKey: "themeId")
        }
        //此处发送一个通知，首页移除手势
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "REMOVEHOMETAP"), object: nil)
    }
}

// MARK: - 控制菜单显示与否相关方法
extension MenuViewController {

    
    /// 显示菜单
    func showMenu() {
        
        //把menuView放在前面
        guard let firstView = UIApplication.shared.keyWindow?.subviews.first,
            let menuView = UIApplication.shared.keyWindow?.subviews.last,
            let toFrontView = UIApplication.shared.keyWindow?.subviews[1] else { return }
        UIApplication.shared.keyWindow?.bringSubview(toFront: toFrontView)
        //动画显示出来
        UIView.animate(withDuration: 0.35) {
            firstView.transform = CGAffineTransform(translationX: 225, y: 0)
            menuView.transform = firstView.transform
        }
        
    }
    
    func dismissMenu() {
        
        guard let firstView = UIApplication.shared.keyWindow?.subviews.first,
            let menuView = UIApplication.shared.keyWindow?.subviews.last,
            let toFrontView = UIApplication.shared.keyWindow?.subviews[1] else { return }
        UIApplication.shared.keyWindow?.bringSubview(toFront: toFrontView)
        
        UIView.animate(withDuration: 0.35) {
            firstView.transform = CGAffineTransform(translationX: 0, y: 0)
            menuView.transform = firstView.transform
        }
    }
}

// MARK: - 制作成单利
extension MenuViewController {

    static let shareManager = createMenuView()
    private static func createMenuView() -> MenuViewController {
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        let menu = sb.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menu.view.frame = CGRect(x: -225, y: 0, width: 225, height: screenH)
        return menu
    }
}
