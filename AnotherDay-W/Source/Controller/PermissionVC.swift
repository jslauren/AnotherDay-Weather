//
// PermissionVC.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/07.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit
import CoreLocation

class PermissionVC: UIViewController {
    
    var locationManager: CLLocationManager!
    var locationIndex = 0
    
    // 권한 거부 체크용 변수.
    private var observer: NSObjectProtocol?
    var backgroundCheck = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Background에서 Foreground로 돌아오는 것 체크하기.
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in

            if backgroundCheck == true {
                backgroundCheck = false

                self.checkAuthenticalStatus(status: locationManager.authorizationStatus)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if locationIndex == 0 {
            getLocation()
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - CLLocationManagerDelegate 채택

// [ 꼼꼼한 재은씨의 스위프트 문법편 발췌 ]
// Extension이란?
// 이미 존재하는 클래스나 구조체, 열거형 등의 객체에 새로운 기능을 추가하여 확장해주는 구문.
// 오버로딩(Overloading)은 가능하나 오버라이딩(Overriding)은 불가능.

// Protocol이란?
// 클래스나 구조체가 어떤 기준을 만족하거나 또는 특수한 목적을 달성하기 위해 구현해야하는 메소드와 프로퍼티 목록.
// 다른 객체지향 언어의 인터페이스 개념과 비슷하다.

// C++의 '순수가상함수' 정도로 생각할 수 있을까?
// 개인적으로 프로토콜을 쓰는 이유는 규격에 맞게 잘 정돈된 설계를 위한 것 같다.

extension PermissionVC: CLLocationManagerDelegate {
    func getLocation() {
        
        locationManager = CLLocationManager()
        
        // 델리게이션(Delegation)이란?
        // 특정 기능을 다른 객체에 위임하고, 그에 따라 필요한 시점에서 메소드의 호출만 받는 패턴.
        // 델리게이트 참조를 통해 메소드를 호출할 인스턴스 객체를 전달받고,
        // 이 인스턴스 객체가 구현하고 있는 프로토콜에 선언된 메소드를 호출하는 것.
        locationManager.delegate = self
    }
        
    func checkAuthenticalStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "위치정보 권한이 거부되었습니다.", message: "앱을 사용하려면 해당 권한이 필요합니다.")
        case .denied:
            self.showAlertToPrivacySetting(title: "위치정보 권한이 거부되었습니다.", message: "앱 설정 화면에서 위치 접근을 허용해 주세요.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("🚫 알 수 없는 권한상태 입니다! : \(status)")
        }
    }
    
    // 위치정보 권한 거부 시 설정화면 유도 알림 함수.
    func showAlertToPrivacySetting(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("UIApplication.openSettingsURLStrings를 가져오는데 문제가 발생하였습니다.")
            return
        }
        let settingsAction = UIAlertAction(title: "설정", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }

        alertController.addAction(settingsAction)
        
        // 권한 설정을 변경하지 않고 다시 돌아갔을 때를 대비한 변수 설정.
        backgroundCheck = true
        
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("🤔 권한 상태를 체크 중입니다.")
        self.checkAuthenticalStatus(status: manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last ?? CLLocation()
        let geocoder = CLGeocoder()
        
        print("현재 위치의 위도와 경도는 \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude) 입니다.")
        
        // CLGeocoder로 위도, 경도 정보를 사용하여 주소 정보 얻기.
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            var locationName = ""
            
            if placemarks != nil {
                // 첫 번째 placemark 가져오기.
                let placemark = placemarks?.last
                
                locationName = placemark?.name ?? "알 수 없습니다"
            } else {
                print("🚫에러: 검색장소 에러. 에러 코드: \(error)")
                locationName = "위치를 찾을 수 없습니다."
            }
            print("현재 위치 : \(locationName)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("🚫에러: \(error.localizedDescription). 디바이스의 위치정보를 가져오는데 실패하였습니다.")
    }
}

// MARK: - 경고창 출력 함수
extension UIViewController {
    func oneButtonAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
