//
//  ViewController.swift
//  MBProgressHUD
//
//  Created by zchao on 2019/9/19.
//  Copyright © 2019 zhengchao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello world !")
        
        MainAssert
        indicator = UIActivityIndicatorView(style: .whiteLarge)
        
        self.dismiss(animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        
        if var view = indicator, view.isKind(of: UIActivityIndicatorView.self) {
            
            
            print("\(String(describing: indicator)) indicator starRunning")
            
            indicator = UIView()
            
            print("\(String(describing: indicator)) indicator starRunning")
        }else {
            print("\(String(describing: indicator)) is invaild")
        }
        
        
    }
    var indicator: UIView?
    fileprivate let MainAssert = assert(Thread.isMainThread, "MBProgressHUD needs to be accessed on the main thread.")

    
}

