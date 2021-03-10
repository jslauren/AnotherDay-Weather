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
        
        loadLocations()
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
    
    func loadLocations() {
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            print("⚠️ 경고: 'UserDefaults'로 부터 weatherLocations 데이터를 불러올 수 없습니다. 이 에러는 앱이 처음 설치되었을때 발생하는 에러이므로, 해당 경우에는 무시하셔도 좋습니다.")
            return
        }
        let decoder = JSONDecoder()
        if let weatherLocations = try? decoder.decode(Array.self, from: locationsEncoded) as [WeatherLocation] {
            self.weatherLocations = weatherLocations
        } else {
            print("🚫 에러: UserDefaults로 부터 decode데이터를 읽지 못하였습니다.")
        }
    }
}

