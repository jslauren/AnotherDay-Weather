//
// CustomSideMenuNVC.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/13.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit
import SideMenu

class CustomSideMenuNVC: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presentationStyle = .menuSlideIn
        self.menuWidth = 290
    }

}
