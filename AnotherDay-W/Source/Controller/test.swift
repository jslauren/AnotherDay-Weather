//
// test.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/07.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit

class test: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func moveMainVC(_ sender: UIBarButtonItem) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuController") else { return }
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
