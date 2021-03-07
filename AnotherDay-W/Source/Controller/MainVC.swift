//
// MainVC.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/06.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit
import SideMenuSwift

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // PermissionVC에서 네비게이션 push로 넘어왔기때문에 생성된 "Back" 버튼 숨기기.
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // 네비게이션바 위쪽 여백 추가하기.
        navigationController?.additionalSafeAreaInsets.top = 10
    }

    @IBAction func menuButtonDidClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }
    
    @IBAction func moveAddLocationVC(_ sender: UIBarButtonItem) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationVC") else {
            return
        }

        // 네비게이션VC라 push형식으로 화면전환하기.
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
}

