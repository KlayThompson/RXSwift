//
//  ThemeViewController.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/7.
//  Copyright © 2017年 Brain. All rights reserved.
//  点击菜单栏分类跳转的界面

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import Moya
import MJRefresh

class ThemeViewController: UIViewController {

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    //菜单视图
    let menuView = MenuViewController.shareManager
    //返回按钮
    var backButton: UIButton!
    //主题id
    var id = 0
    //请求网络单例
    let provider = RxMoyaProvider<APIManager>()
    //存放listModel数组
    let listModelArray = Variable([StoryModel]())
    //隐藏菜单栏手势
    var tap: UITapGestureRecognizer?//注意：此处处理不完善，需要两处地方移除该手势，在接受通知切换主题时候需要移除，还有当点击了手势执行后需要移除
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupUI()
        loadData()
        
        //下拉刷新
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            self.loadData()
        })
        
        backButton.rx
            .tap
            .subscribe(onNext: {
                self.menuView.showMenuView = !self.menuView.showMenuView
                //添加一个手势，当菜单栏显示的时候，点击此界面则隐藏菜单栏
                self.tap = UITapGestureRecognizer(target: self, action: #selector(self.tapMe))
                self.view.addGestureRecognizer(self.tap!)
            })
            .addDisposableTo(disposeBag)
        
        //接收通知
        NotificationCenter.default.rx
            .notification(NSNotification.Name("CHANGETHEME"))
            .subscribe(onNext: { (notify) in
                self.loadData()
                let model = notify.userInfo?["model"] as? ThemeModel
                guard let themeModel = model else { return }
                self.title = themeModel.name
                self.titleImage.kf.setImage(with: URL(string: model?.thumbnail ?? ""))
                self.id = model?.id ?? 0
                //移除手势
                self.view.removeGestureRecognizer(self.tap!)
            })
            .addDisposableTo(disposeBag)
        
        //绑定数据
        listModelArray
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "ListTableViewCell", cellType: ListTableViewCell.self)) {row, model, cell in
                cell.titleLabel.text = model.title
                cell.moreImageIcon.isHidden = !model.multipic
                if model.images != nil {
                    cell.newsImageview.isHidden = false
                    cell.titleLabelRightCons.constant = 105
                    cell.newsImageview.kf.setImage(with: URL(string: model.images?.first ?? ""))
                } else {
                    cell.newsImageview.isHidden = true
                    cell.titleLabelRightCons.constant = 15
                }
            }
            .addDisposableTo(disposeBag)
        
        //点击新闻
        tableView.rx
            .modelSelected(StoryModel.self)
            .subscribe(onNext: { (model) in
                self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow ?? IndexPath(), animated: true)
                let detailVc = DetailNewsViewController()
                self.listModelArray.value.forEach({ (model) in
                    detailVc.idArray.append(model.id ?? 0)
                })
                detailVc.id = model.id ?? 0
                self.navigationController?.pushViewController(detailVc, animated: true)
            })
            .addDisposableTo(disposeBag)
        
    }

    
}

// MARK: - 自定义方法
extension ThemeViewController {

    /// 点击非菜单栏部分
    func tapMe() {
        //如果显示了菜单栏在进行处理
        if menuView.showMenuView {
            menuView.showMenuView = !menuView.showMenuView
        }
        //移除手势
        view.removeGestureRecognizer(tap!)
    }
}

// MARK: - 获取网络
extension ThemeViewController {

    func loadData() {
        provider
            .request(.getThemeDesc(id))
            .mapModel(ListModel.self)
            .subscribe(onNext: { (model) in
                self.tableView.mj_header.endRefreshing()
                self.listModelArray.value = model.stories ?? [StoryModel]()
                //要滚动到顶部
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            })
            .addDisposableTo(disposeBag)
    }
}

// MARK: - 设置界面
private extension ThemeViewController {
    func setupUI() {
        navigationController?.navigationBar.barTintColor = UIColor.lightGray
        //设置左边导航栏返回按钮
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        backButton.setImage(UIImage(named: "Back_White"), for: .normal)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 60)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        //隐藏navigationbar的第一个view，以及一些属性
        navigationController?.navigationBar.subviews.first?.alpha = 0
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false

        //设置titleImage的frame
        titleImage.frame = CGRect(x: 0, y: -64, width: screenW, height: 64)
        
        //设置tableView坐标
        tableView.frame = CGRect(x: 0, y: 0, width: screenW, height: screenH - 64)
        
        //读取本地数据
        title = UserDefaults.standard.object(forKey: "themeName") as? String
        id = UserDefaults.standard.object(forKey: "themeId") as? Int ?? 0
        titleImage.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "themeThumbnail") as? String ?? ""))
        
    }
}
