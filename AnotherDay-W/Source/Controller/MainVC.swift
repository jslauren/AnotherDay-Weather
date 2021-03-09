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

    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var compareLabel: UILabel!
    
    var weatherLocation: WeatherLocation!
    var weatherLocations: [WeatherLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initView()
        
        if weatherLocation == nil {
            weatherLocation = WeatherLocation(name: "현재 위치", latitude: 0.0, longitude: 0.0)
            weatherLocations.append(weatherLocation)
        }
        
        updateUserInterface()
        
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
    
    @IBAction func unwindFromMainVC(segue: UIStoryboardSegue) {
        let source = segue.source as! AddLocationVC
        
        self.weatherLocations = source.weatherLocations
        self.weatherLocation = self.weatherLocations[source.selectedLocationIndex]
        
        updateUserInterface()
    }
    
    func initView() {
        // PermissionVC에서 네비게이션 push로 넘어왔기때문에 생성된 "Back" 버튼 숨기기.
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // 네비게이션바 위쪽 여백 추가하기.
        navigationController?.additionalSafeAreaInsets.top = 10
        
        // 뷰 전체 색 및 노치와 네비게이션 바 색 변경.
        self.view.backgroundColor = hexStringToUIColor(hex: baseColor)
        self.navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: baseColor)
    }
    
    func updateUserInterface() {
        placeLabel.text = weatherLocation.name
        temperatureLabel.text = "--°"
        maxTemperatureLabel.text = "최고 : --°"
        minTemperatureLabel.text = "최저 : --°"
        compareLabel.text = "어제보다 --° 높음"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MainVC
        
        destination.weatherLocations = weatherLocations
    }

}

