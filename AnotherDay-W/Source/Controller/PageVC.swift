//
// PageVC.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/10.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit

class PageVC: UIPageViewController {
    
    var weatherLocations: [WeatherLocation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        
    }

    func initView() {
        self.delegate = self
        self.dataSource = self
        
        loadLocations()
        setViewControllers([createMainVC(forPage: 0)], direction: .forward, animated: false, completion: nil)
    }
    
    func createMainVC(forPage page: Int) -> MainVC {
        let mainVC = storyboard!.instantiateViewController(identifier: "MainVC") as! MainVC
        
        mainVC.locationIndex = page
        
        return mainVC
    }
    
    func loadLocations() {
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            print("⚠️ 경고: 'UserDefaults'로 부터 weatherLocations 데이터를 불러올 수 없습니다. 이 에러는 앱이 처음 설치되었을때 발생하는 에러이므로, 해당 경우에는 무시하셔도 좋습니다.")
            weatherLocations.append(WeatherLocation(name: "현재 위치", latitude: 37.521015, longitude: 127.022538))
            
            return
        }
        let decoder = JSONDecoder()
        if let weatherLocations = try? decoder.decode(Array.self, from: locationsEncoded) as [WeatherLocation] {
            self.weatherLocations = weatherLocations
        } else {
            print("🚫 에러: UserDefaults로 부터 decode데이터를 읽지 못하였습니다.")
        }
        
        if weatherLocations.isEmpty {
            weatherLocations.append(WeatherLocation(name: "현재 위치", latitude: 37.521015, longitude: 127.022538))
        }
    }
}

extension PageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentVC = viewController as? MainVC {
            if currentVC.locationIndex > 0 {
                return createMainVC(forPage: currentVC.locationIndex - 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentVC = viewController as? MainVC {
            if currentVC.locationIndex < weatherLocations.count - 1 {
                return createMainVC(forPage: currentVC.locationIndex + 1)
            }
        }
        return nil
    }
    
}
