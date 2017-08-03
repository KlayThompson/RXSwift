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

class DetailNewsViewController: UIViewController {

    /// WebView
    let currentWebView = DetailNewsWebView()
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
        currentWebView.waitView.removeFromSuperview()
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
                    self.currentWebView.img.kf.setImage(with: URL.init(string: image))
                    self.currentWebView.titleLab.text = model.title
                } else {
                    self.currentWebView.img.isHidden = true
                    self.currentWebView.previousLab.textColor = UIColor.colorFromHex(0x777777)
                }
                if let image_source = model.image_source {
                    self.currentWebView.imgLab.text = "图片: " + image_source
                }
                if (model.title?.characters.count)! > 16 {
                    self.currentWebView.titleLab.frame = CGRect.init(x: 15, y: 120, width: screenW - 30, height: 55)
                }
                OperationQueue.main.addOperation {
                    self.currentWebView.loadHTMLString(self.concatHTML(css: model.css!, body: model.body!), baseURL: nil)
                    
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
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UILabel())
        currentWebView.frame = view.bounds
        currentWebView.uiDelegate = self
//        webView.scrollView.delegate = self
        view.addSubview(currentWebView)
        
    }
}
