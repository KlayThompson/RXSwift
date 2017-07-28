//
//  ViewController.swift
//  RXSwiftBindTableViewData
//
//  Created by Kim on 2017/7/26.
//  Copyright © 2017年 Brain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    
    @IBOutlet weak var uTableView: UITableView!
    
    let speakerListViewModel = SpeakerListViewModel()
    
    /// 这是 Rx 在视图控制器或者其持有者将要销毁的时候，其中一种实现「订阅处置机制」的方式。这就和 NSNotificationCenter 的 removeObserver 类似
    let disposeBag = DisposeBag()
    
    let nameTextfield = UITextField()
    
    let cellId = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        uTableView.delegate = self
//        uTableView.dataSource = self
        uTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        _ = nameTextfield.rx.text.shareReplay(1).map({($0?.characters.count)! >= 6})
        automaticallyAdjustsScrollViewInsets = false
        speakerListViewModel.data
            .bind(to: uTableView.rx.items(cellIdentifier: cellId)){ index, speaker,cell in
                
                cell.textLabel?.text = speaker.name
                cell.detailTextLabel?.text = speaker.twitterHandle
                cell.imageView?.image = speaker.image
        }.addDisposableTo(disposeBag)
        
        uTableView.rx.modelSelected(Speaker.self).subscribe { speaker in
            print("You selected \(speaker)")
        }.addDisposableTo(disposeBag)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//extension ViewController: UITableViewDelegate,UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return speakerListViewModel.data.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
//        
//        let speaker = speakerListViewModel.data[indexPath.row]
//        
//        cell.textLabel?.text = speaker.name
//        cell.detailTextLabel?.text = speaker.twitterHandle
//        cell.imageView?.image = speaker.image
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("You selected \(speakerListViewModel.data[indexPath.row])")
//    }
//}

