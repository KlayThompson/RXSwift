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
//    var currentWebView = DetailNewsWebView(frame: CGRect(x: 0, y: 0, width: screenW, height: screenH))
    let provider = RxMoyaProvider<APIManager>()
    let disposeBag = DisposeBag()
    
    var id: Int = 0 {
        didSet{
           //传入id调用加载数据
            loadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    

}

extension DetailNewsViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("开始了？")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
//        currentWebView.waitView.removeFromSuperview()
        print("结束了？")
    }
}

// MARK: - 加载数据
extension DetailNewsViewController {

    func loadData() {
        
        provider
            .request(.getNewsDesc(id))
            .mapModel(NewsDetailModel.self)
            .subscribe(onNext: { (model) in
//                if let image = model.image {
//                    self.currentWebView.img.kf.setImage(with: URL(string: image))
//                    self.currentWebView.titleLab.text = model.title
//                } else {
//                    self.currentWebView.img.isHidden = true
//                    self.currentWebView.previousLab.textColor = UIColor.colorFromHex(0x777777)
//                }
//                if let image_source = model.image_source {
//                    self.currentWebView.imgLab.text = "图片: " + image_source
//                }
//                if (model.title?.characters.count)! > 16 {
//                    self.currentWebView.titleLab.frame = CGRect(x: 15, y: 120, width: screenW - 30, height: 55)
//                }
//                OperationQueue.main.addOperation {
//                    
//                }
                //回到主线程
                DispatchQueue.main.async {
                    let string = self.concatHTML(css: model.css!, body: model.body!)
                    let web = UIWebView(frame: self.view.bounds)
                    self.view.addSubview(web)
                    web.loadHTMLString(string, baseURL: nil)
                    
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

// MARK: - 设置界面
private extension DetailNewsViewController {

    func setupUI() {
        
        view.backgroundColor = UIColor.white
//        navigationItem.leftBarButtonItem = UIB arButtonItem(customView: UILabel())
//        currentWebView = DetailNewsWebView(frame: view.bounds)
//        currentWebView.delegate = self
//        webView.scrollView.delegate = self
//        view.addSubview(currentWebView)
        
    }
}

extension DetailNewsViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //加载结束
        print("加载结束")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //开始加载
        print("开始加载")
    }
    
}
