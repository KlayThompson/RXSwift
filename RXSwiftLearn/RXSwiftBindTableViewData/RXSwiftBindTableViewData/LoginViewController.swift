//
//  LoginViewController.swift
//  RXSwiftBindTableViewData
//
//  Created by Kim on 2017/7/27.
//  Copyright © 2017年 Brain. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class LoginViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var check1Image: UIImageView!
    
    @IBOutlet weak var check2Iamge: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let usernameObserable = usernameTextField.rx
            .text
            .map({($0?.characters.count ?? 0) >= 6})
            
        
            
        _ = usernameObserable.subscribe({(valid) in
           
                self.check1Image.image = valid.element ?? false ? #imageLiteral(resourceName: "checkGood") : #imageLiteral(resourceName: "checkBad")
            }).disposed(by: disposeBag)
        
        let passwordObserable = passwordTextField.rx.text
            .map({($0?.characters.count ?? 0) >= 8})
            
            
            _ = passwordObserable.subscribe({valid in
                self.check2Iamge.image = valid.element ?? false ? #imageLiteral(resourceName: "checkGood") : #imageLiteral(resourceName: "checkBad")
            })
        
        Observable.combineLatest(usernameObserable, passwordObserable) {$0 && $1}.subscribe({valid in
            
            let canLogin = valid.element ?? false
            
            if canLogin {
                self.loginButton.isEnabled = true
                self.loginButton.backgroundColor = UIColor.orange
            } else {
                self.loginButton.isEnabled = false
                self.loginButton.backgroundColor = UIColor.lightGray
            }
            
        }).addDisposableTo(disposeBag)
        
        loginButton.rx
            .tap
            .subscribe(onNext: {
                print("1234567890-987654")
            }).addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButtonPress(_ sender: Any) {
        print("用户点击了登录")
    }

}
