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
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var compareLabel: UILabel!
    
    var weatherLocation: WeatherLocation!
    var locationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
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
        
        locationIndex = source.selectedLocationIndex
        
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC

        pageVC.weatherLocations = source.weatherLocations
        pageVC.setViewControllers([pageVC.createMainVC(forPage: locationIndex)], direction: .forward, animated: false, completion: nil)
    }
    
    func initView() {
        //     self.toolBar.barTintColor = hexStringToUIColor(hex: baseColor)
        self.view.backgroundColor = hexStringToUIColor(hex: baseColor)
    }
    
    func updateUserInterface() {
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        
        weatherLocation = pageVC.weatherLocations[locationIndex]
        
        placeLabel.text = weatherLocation.name
        temperatureLabel.text = "--°"
        maxTemperatureLabel.text = "최고 : --°"
        minTemperatureLabel.text = "최저 : --°"
        compareLabel.text = "어제보다 --° 높음"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AddLocationVC
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        
        destination.weatherLocations = pageVC.weatherLocations
    }
    
}

