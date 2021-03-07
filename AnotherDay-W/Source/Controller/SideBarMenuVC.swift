//
// SideBarMenuVC.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/07.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit
import SideMenuSwift

class Preferences {
    static let shared = Preferences()
    var enableTransitionAnimation = false
}

class SideBarMenuVC: UIViewController {

    @IBOutlet weak var sideBarMenuTableView: UITableView! {
        didSet {
            sideBarMenuTableView.dataSource = self
            sideBarMenuTableView.delegate = self
        }
    }
    
    let appVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let buildVer = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
    
    // MARK: - 테이블 뷰 헤더 변수
    let appName = UILabel()         // 앱 이름 레이블
    let appVersion = UILabel()      // 앱 버전 레이블
    let appImage = UIImageView()    // 앱 대표 이미지
    
    // MARK: - 테이블 뷰 셀 변수
    // 타이틀 아이콘 이미지 설정.
    let icons = [
        UIImage(named: "SideMenu.png"),
        UIImage(named: "SideMenu.png")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.sideBarMenuTableView.separatorStyle = .none    // 사이드바 메뉴 구분선 제거.
        self.sideBarMenuInit()
        self.sideBarMenuHeaderSetting()
        self.sideBarTitleDidClicked()
    }

    // 사이드바 메뉴 preference 셋팅 함수.
    func sideBarMenuInit() {
        SideMenuController.preferences.basic.menuWidth = 240
        SideMenuController.preferences.basic.position = .above
        SideMenuController.preferences.basic.direction = .left
        SideMenuController.preferences.basic.enablePanGesture = true
        SideMenuController.preferences.basic.supportedOrientations = .portrait
        SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
    }
    
    func sideBarMenuHeaderSetting() {
        // MARK: - 테이블 뷰의 헤더 정의
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 150))

        // 테이블 뷰 헤더 셋팅.
        self.sideBarMenuTableView.tableHeaderView = headerView
        headerView.backgroundColor = .brown                        // bgcolor 지정. UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        // 서브 뷰 셋팅
        self.appName.frame = CGRect(x: 100, y: 40, width: 150, height: 50)
        self.appName.text = "어제와 다른 오늘"
        self.appName.textColor = .white
        self.appName.font = UIFont.boldSystemFont(ofSize: 20)
        headerView.addSubview(self.appName)
        
        self.appVersion.frame = CGRect(x: 130, y: 62, width: 150, height: 50)
        self.appVersion.text = "앱 버전 : \(appVer)"
        self.appVersion.textColor = .white
        self.appVersion.font = UIFont.systemFont(ofSize: 14)
        self.appVersion.backgroundColor = .clear
        headerView.addSubview(self.appVersion)
        
        self.appImage.image = UIImage(named: "SideMenu.png")
        self.appImage.frame = CGRect(x: 0, y: 25, width: 100, height: 100)
        headerView.addSubview(self.appImage)
    }
    
    // 사이드바 메뉴 타이틀 선택 시 뷰 화면 전환 기능 함수.
    func sideBarTitleDidClicked() {
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "TestView1")
        }, with: "0")

        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "ThirdViewController")
        }, with: "1")
    }
}

extension SideBarMenuVC: UITableViewDelegate, UITableViewDataSource {
    // 사이드바 메뉴에 들어갈 타이틀 갯수 설정 함수.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    // 사이드바 메뉴에 들어갈 타이틀 설정 함수.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SelectionCell
        
        cell.contentView.backgroundColor = UIColor.white    // 셀 바탕색 설정.
        cell.imageView?.image = self.icons[indexPath.row]   // 셀 아이콘 설정.
        
        switch indexPath.row {
        case 0:
            cell.titleLabel?.text = "푸시알림 설정하기"
        case 1:
            cell.titleLabel?.text = "만든 사람"
        default:
            print("사이드바 메뉴 타이틀 오류")
        }

        return cell
    }

    // 사이드바 메뉴 타이틀 선택 시 처리 함수.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row

        sideMenuController?.setContentViewController(with: "\(row)", animated: Preferences.shared.enableTransitionAnimation)
        sideMenuController?.hideMenu()
    }

    // 테이블 뷰 행의 높이 조절 함수.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

class SelectionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
