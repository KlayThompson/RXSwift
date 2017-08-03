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
import Moya
import RxDataSources
import ZYBannerView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var menuItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: ZYBannerView!
    
    
    
    /// 菜单视图
    let menuView = MenuViewController.shareManager
    let disposBag = DisposeBag()
    //网络请求
    let provider = RxMoyaProvider<APIManager>()
    //存放新闻数组
    let dataArray = Variable([SectionModel<String, StoryModel>]())
    //DataSource
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, StoryModel>>()
    //存放Banner图片数组
    let bannerArray = Variable([StoryModel]())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupUI()
        
        //TableView相关
        dataSource.configureCell = { (dataSou, tableView, indexPath, model) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
            cell.titleLabel.text = model.title
            cell.newsImageview.kf.setImage(with: URL(string: model.images?.first ?? ""))
            cell.moreImageIcon.isHidden = !model.multipic
            return cell
        }
        
        dataArray
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposBag)
        
        
        menuItem.rx
            .tap
            .subscribe(onNext: {
                self.menuView.showMenuView = !self.menuView.showMenuView
            })
            .addDisposableTo(disposBag)
        
    }


}

// MARK: - 加载数据
private extension HomeViewController {

    func loadData() {
        
      provider
        .request(.getNewsList)
        .mapModel(ListModel.self)
        .subscribe(onNext: { (model) in
            self.dataArray.value = [SectionModel(model: model.date ?? "", items: model.stories ?? [])]
            //处理banner图片数组
            guard var array = model.top_stories else {
                return
            }
            array.insert(array.last!, at: 0)
            array.append(array[1])
            self.bannerArray.value = array
            self.bannerView.reloadData()
        })
        .addDisposableTo(disposBag)
    }
}

// MARK: - 设置界面
private extension HomeViewController {

    func setupUI() {

        setBarUI()
    }
    
    func setBarUI() {
        //将菜单添加到KeyWindow上面
        UIApplication.shared.keyWindow?.addSubview(menuView.view)
    }
}

extension HomeViewController: ZYBannerViewDataSource {

    func numberOfItems(inBanner banner: ZYBannerView!) -> Int {
        return bannerArray.value.count
    }
    
    func banner(_ banner: ZYBannerView!, viewForItemAt index: Int) -> UIView! {
        
        let model = bannerArray.value[index]
        
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: model.image ?? ""))
        
        return imageView
    }
}
