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
        indicator = UIActivityIndicatorView(style: .whiteLarge)
        
        if var view = indicator, view.isKind(of: UIActivityIndicatorView.self) {
            
            
            print("\(String(describing: indicator)) indicator starRunning")
            
            indicator = UIView()
            
            print("\(String(describing: indicator)) indicator starRunning")
        }else {
            print("\(String(describing: indicator)) is invaild")
        }
        
        
    }
    var indicator: UIView?
    
    
}

