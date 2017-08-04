//
//  DetailNewsViewController.swift
//  ZhiHuRX
//
//  Created by Kim on 2017/8/3.
//  Copyright © 2017年 Brain. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import WebKit

class DetailNewsViewController: UIViewController {

    
    /// WebView
    var currentWebView: DetailNewsWebView!
    var previousWeb: DetailNewsWebView!
    
    let provider = RxMoyaProvider<APIManager>()
    let disposeBag = DisposeBag()
    
    /// 存放新闻id数组
    var idArray = [Int]()
    var previousId = 0
    var nextId = -1
    
    /// 状态栏背景视图
    var statusBackView = UIView().then { (view) in
        view.backgroundColor = UIColor.white
        view.frame = CGRect(x: 0, y: 0, width: screenW, height: 20)
        view.isHidden = true
    }
    
    var id: Int = 0 {
        didSet{
           //传入id调用加载数据
            loadData()
            //遍历IDArray
            for (index, element) in idArray.enumerated() {
                if id == element {
                    if index == 0 {
                        //为最新一条
                        previousId = 0
                        nextId = idArray[index + 1]
                    } else if (index == idArray.count - 1) {
                        //最后一条
                        nextId = -1
                        previousId = idArray[index - 1]
                    } else {
                        previousId = idArray[index - 1]
                        nextId = idArray[index + 1]
                    }
                    break
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        
    }
    
    /// 切换界面处理
    ///
    /// - Parameter showId: 显示新闻id
    func changeWebView(showId: Int) {
        currentWebView.removeFromSuperview()
        previousWeb.scrollView.delegate = self
        previousWeb.delegate = self
        currentWebView = previousWeb
        id = showId
        //设置提示文字
        setTopBottomTipUI()
        previousWeb = DetailNewsWebView(frame: CGRect(x: 0, y: -screenH, width: screenW, height: screenH))
        view.addSubview(previousWeb)
        //调用代理
        scrollViewDidScroll(currentWebView.scrollView)
    }

}

// MARK: - 加载数据
extension DetailNewsViewController {

    func loadData() {
        
        provider
            .request(.getNewsDesc(id))
            .mapModel(NewsDetailModel.self)
            .subscribe(onNext: { (model) in
                if let image = model.image {
                    self.currentWebView.img.kf.setImage(with: URL(string: image))
                    self.currentWebView.titleLab.text = model.title
                } else {
                    self.currentWebView.img.isHidden = true
                    self.currentWebView.previousLab.textColor = UIColor.colorFromHex(0x777777)
                }
                if let image_source = model.image_source {
                    self.currentWebView.imgLab.text = "图片: " + image_source
                }
                if (model.title?.characters.count)! > 16 {
                    self.currentWebView.titleLab.frame = CGRect(x: 15, y: 120, width: screenW - 30, height: 55)
                }
                
                //回到主线程
                DispatchQueue.main.async {
                    let string = self.concatHTML(css: model.css!, body: model.body!)
                    self.currentWebView.loadHTMLString(string, baseURL: nil)
                    
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func concatHTML(css: [String], body: String) -> String {
        var html = "<html>"
        html += "<head>"
        css.forEach { html += "<link rel=\"stylesheet\" href=\($0)>" }
        html += "<style>img{max-width:320px !important;}</style>"
        html += "</head>"
        html += "<body>"
        html += body
        html += "</body>"
        html += "</html>"
        return html
    }
}

// MARK: - UIWebViewDelegate
extension DetailNewsViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("-------------------------------------------开始了？")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        currentWebView.waitView.removeFromSuperview()
        currentWebView.nextLab.frame = CGRect.init(x: 15, y: self.currentWebView.scrollView.contentSize.height + 10, width: screenW - 30, height: 20)
        print("-------------------------------------------结束了？")
    }
}

// MARK: - UIScrollViewDelegate
extension DetailNewsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //制作弹性效果
        currentWebView.img.frame.origin.y = CGFloat(scrollView.contentOffset.y)
        currentWebView.img.frame.size.height = 200 - CGFloat(scrollView.contentOffset.y)
        currentWebView.maskImg.frame = CGRect(x: 0, y: currentWebView.img.frame.size.height - 100, width: screenW, height: 100)
        //控制状态栏状态
        if scrollView.contentOffset.y > 180 {
            view.bringSubview(toFront: statusBackView)
            statusBackView.isHidden = false
            UIApplication.shared.statusBarStyle = .default
        } else {
            statusBackView.isHidden = true
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y <= 60 {
            //下拉松手，加载上一篇
            if previousId > 0 {
                previousWeb.frame = CGRect(x: 0, y: -screenH, width: screenW, height: screenH)
                //动画改变坐标
                UIView.animate(withDuration: 0.3, animations: { 
                    self.currentWebView.transform = CGAffineTransform(translationX: 0, y: screenH)
                    self.previousWeb.transform = CGAffineTransform(translationX: 0, y: screenH)
                }, completion: { (success) in
                    //改变显示的webView
                    if success {
                        self.changeWebView(showId: self.previousId)
                    }
                })
            }
        }
        //加载下一篇
        if scrollView.contentOffset.y - 50 + screenH >= scrollView.contentSize.height {
            if nextId > 0 {
                previousWeb.frame = CGRect(x: 0, y: screenH, width: screenW, height: screenH)
                UIView.animate(withDuration: 0.3, animations: { 
                    self.currentWebView.transform = CGAffineTransform(scaleX: 0, y: -screenH)
                    self.previousWeb.transform = CGAffineTransform(translationX: 0, y: -screenH)
                }, completion: { (_) in
                    //改变显示的webView
                    self.changeWebView(showId: self.nextId)
                })
            }
        }
    }
}

// MARK: - 设置界面
private extension DetailNewsViewController {

    func setupUI() {
        
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UILabel())
        currentWebView = DetailNewsWebView(frame: view.bounds)
        currentWebView.delegate = self
        currentWebView.scrollView.delegate = self
        previousWeb = DetailNewsWebView(frame: CGRect(x: 0, y: -screenH, width: screenW, height: screenH))
        view.addSubview(currentWebView)
        view.addSubview(previousWeb)
        view.addSubview(statusBackView)
        
    }
    
    func setTopBottomTipUI() {
        if previousId == 0 {
            currentWebView.previousLab.text = "已经是第一篇了"
        } else {
            currentWebView.previousLab.text = "载入上一篇"
        }
        if nextId == -1 {
            currentWebView.nextLab.text = "已经是最后一篇了"
        } else {
            currentWebView.nextLab.text = "载入下一篇"
        }
    }
}
