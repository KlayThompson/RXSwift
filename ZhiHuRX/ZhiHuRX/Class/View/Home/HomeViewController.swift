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
import Then
import SwiftDate

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
    //导航栏View
    var barView = UIView()
    //刷新的时间
    var newsDate = ""

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isStatusBarHidden = false
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
        
        //设置scrollView代理
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposBag)
        
        //tableView点击
        tableView.rx
            .modelSelected(StoryModel.self)
            .subscribe(onNext: { (model) in
                let detailVc = DetailNewsViewController()
                self.dataArray.value.forEach({ (sectionModel) in
                    sectionModel.items.forEach({ (storyModel) in
                        detailVc.idArray.append(storyModel.id ?? 0)
                    })
                })
                detailVc.id = model.id ?? 0
                self.navigationController?.pushViewController(detailVc, animated: true)
            })
            .addDisposableTo(disposBag)
        
        //导航栏按钮点击
        menuItem.rx
            .tap
            .subscribe(onNext: {
                self.menuView.showMenuView = !self.menuView.showMenuView
            })
            .addDisposableTo(disposBag)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bannerView.startTimer()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bannerView.stopTimer()
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
            guard let array = model.top_stories else {
                return
            }
            self.bannerArray.value = array
            self.bannerView.reloadData()
            self.newsDate = model.date ?? ""
        })
        .addDisposableTo(disposBag)
    }
    
    func lodaMoreData() {
        
        provider
            .request(.getMoreNews(newsDate))
            .mapModel(ListModel.self)
            .subscribe(onNext: { (model) in
                self.dataArray.value.append(SectionModel(model: model.date ?? "", items: model.stories ?? []))
                self.newsDate = model.date ?? ""
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
        
        //设置导航栏
        guard let barView1 = navigationController?.navigationBar.subviews.first else {
            return
        }
        barView = barView1
        
        barView.alpha = 0
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.rgb(63, 141, 208)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        //此处需要设置tableView的frame，故不需要在sb中设置约束
        tableView.frame = CGRect(x: 0, y: -64, width: screenW, height: screenH)
        
        
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == dataArray.value.count - 1 && indexPath.row == 0 {
            lodaMoreData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section > 0 {
            return UILabel().then({ (label) in
                label.frame = CGRect(x: 0, y: 0, width: screenW, height: 38)
                label.backgroundColor = UIColor.rgb(63, 141, 208)
                label.textColor = UIColor.white
                label.font = UIFont.systemFont(ofSize: 15)
                label.textAlignment = .center
                guard let date = DateInRegion(string: dataSource[section].model, format: DateFormat.custom("yyyyMMdd")) else {
                    return
                }
                label.text = "\(date.year)年\(date.month)月\(date.day)日 \(date.weekday.toWeekday())"
            })
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 38
        }
        return 0.01
    }
}

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        barView.alpha = scrollView.contentOffset.y / 200
    }
}

// MARK: - ZYBannerViewDataSource
extension HomeViewController: ZYBannerViewDataSource {

    func numberOfItems(inBanner banner: ZYBannerView!) -> Int {
        return bannerArray.value.count
    }
    
    func banner(_ banner: ZYBannerView!, viewForItemAt index: Int) -> UIView! {
        
        let model = bannerArray.value[index]
        
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: model.image ?? ""))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        //显示标题Label
        let titleLabel = UILabel().then { (label) in
            label.text = model.title
            label.font = UIFont.systemFont(ofSize: 21)
            label.textColor = UIColor.white
            label.frame = CGRect(x: 10, y: 200 - 20 - 25, width: screenW - 2 * 10, height: 25)
        }
        imageView.addSubview(titleLabel)
        
        return imageView
    }
}
