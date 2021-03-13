//
// SideMenuVC.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/13.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit

class SideMenuVC: UIViewController {
    @IBOutlet weak var appVerLabel: UILabel!
    
    let appVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let buildVer = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appVerLabel.text = "앱 버전 : \(appVer)"
        
    }
}

