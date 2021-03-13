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
import CoreLocation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "EEEE, MMM d" //, h:mm aaa"
    
    return dateFormatter
}()

class MainVC: UIViewController {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var temperatureImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var compareLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weatherDetail: WeatherDetail!
    var locationIndex = 0
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initView()
        updateUserInterface()
    }
    
    func initView() {
        clearUserInterface()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 앱을 처음 구동하면 locationIndex는 무조건 0이므로,
        // 이때 권한 요청을 한다.
        if locationIndex == 0 {
            getLocation()
        }
        
        self.view.backgroundColor = hexStringToUIColor(hex: baseColor)
        self.tableView.backgroundColor = hexStringToUIColor(hex: baseColor)
    }
    
    func updateUserInterface() {
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        let weatherLocation = pageVC.weatherLocations[locationIndex]
        
        weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
        
        // pageControl 값 셋팅.
        pageControl.numberOfPages = pageVC.weatherLocations.count
        pageControl.currentPage = locationIndex
        
        weatherDetail.getData {
            // UILabel.text must be used from main thread only 에러 때문에,
            // DispatchQueue.main.async안에 해당 구문을 넣어준다.
            // UI와 관련된 모든 이벤트가 메인 쓰레드에 붙기 때문에 반드시 메인에서 구현해야한다. Ref : https://zeddios.tistory.com/519
            DispatchQueue.main.async { [self] in
//                dateFormatter.timeZone = TimeZone(identifier: self.weatherDetail.timezone)
//                let usableDate = Date(timeIntervalSince1970: self.weatherDetail.currentTime)
                
                self.temperatureImageView.image = UIImage(named: self.weatherDetail.dayIcon)
                self.placeLabel.text = self.weatherDetail.name
                self.summaryLabel.text = self.weatherDetail.summary
                self.temperatureLabel.text = "\(self.weatherDetail.temperature)°"
                self.maxTemperatureLabel.text = "최고 : \(self.weatherDetail.maxTemperature)°"
                self.minTemperatureLabel.text = "최저 : \(self.weatherDetail.minTemperature)°"
               // self.compareLabel.text = "어제보다 2° 높음"
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }
            
            // 어제의 현재시간 날씨 데이터를 가져와 오늘의 데이터와 비교하여 표기함.
            self.weatherDetail.getHistoricalData(dt: self.weatherDetail.currentTime) {
                DispatchQueue.main.async { [self] in
                    
                    if self.weatherDetail.historicalTemperature == self.weatherDetail.temperature {
                        self.compareLabel.text = "어제와 같아요"
                    } else if self.weatherDetail.historicalTemperature > self.weatherDetail.temperature {
                        self.compareLabel.text = "어제보다 \(weatherDetail.historicalTemperature-self.weatherDetail.temperature)도 낮아요"
                    } else {
                        self.compareLabel.text = "어제보다 \(self.weatherDetail.temperature-weatherDetail.historicalTemperature)도 높아요"
                    }
                }
            }
        }
    }
    
    // 화면 페이징 시 메인화면에 나타낼 정보 안보이게 하기.
    func clearUserInterface() {
        placeLabel.text = ""
        summaryLabel.text = ""
        temperatureImageView.image  = UIImage()
        temperatureLabel.text = ""
        maxTemperatureLabel.text = ""
        minTemperatureLabel.text = ""
        compareLabel.text = ""
    }
    
    @IBAction func unwindFromMainVC(segue: UIStoryboardSegue) {
        let source = segue.source as! AddLocationVC
        
        locationIndex = source.selectedLocationIndex
        
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        
        // AddLocationVC에서 선택된 LocationIndex의 정보를 PageVC로 넘긴다.
        // PageVC는 넘겨받은 정보로 페이징 처리를 하고 다시 MainVC로 전환시킨다.
        // 전환 후 MainVC의 updateUserInterface 메서드를 통해 화면을 업데이트 한다.
        pageVC.weatherLocations = source.weatherLocations
        pageVC.setViewControllers([pageVC.createMainVC(forPage: locationIndex)], direction: .forward, animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddLocationVC" {
            let destination = segue.destination as! AddLocationVC
            let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
            
            destination.weatherLocations = pageVC.weatherLocations
        }
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        var direction: UIPageViewController.NavigationDirection = .forward
        
        // 스와이핑 하지않고 pageControll버튼을 눌렀을 때 화면전환에 애니메이션을 올바르게 주기위한 방법.
        // 밑에 setViewControllers에서 direction을 그냥 .forwawrd로 주고 animated를 true로 준다면,
        // 왼쪽이든 오른쪽이든 같은방향으로 스와이핑 애니메이션이 보이게 된다.
        // 옳바른 방향으로 애니메이션을 보여주고 싶다면 아래 구문을 이용하면 된다.
        if sender.currentPage < locationIndex {
            direction = .reverse
        }
        
        pageVC.setViewControllers([pageVC.createMainVC(forPage: sender.currentPage)], direction: direction, animated: true, completion: nil)
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
extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // API로 받아온 데이터의 갯수만큼 행을 Row를 띄워준다.
        return weatherDetail.dailyWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // DailyTableViewCell로 캐스팅하고,
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DailyTableViewCell
        
        // 받아온 날씨정보를 DailyTableViewCell.swift에서 만든 변수 형식에 맞게 넣어주면,
        // DailyTableViewCell.swift에 dailyWeather변수는
        // weatherDetail.dailyWeatherData[indexPath.row]로 받은 데이터를 각각의 IBOutlet에 값을 넘겨주고,
        cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
                
        // 그렇게 넣어준 cell을 return 해준다.
        return cell
    }   
    
}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherDetail.hourlyWeatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCollectionViewCell
        
        hourlyCell.hourlyWeather = weatherDetail.hourlyWeatherData[indexPath.row]
        
        return hourlyCell
    }
}

extension MainVC: CLLocationManagerDelegate {
    func getLocation() {
        locationManager = CLLocationManager()
        
        // 델리게이션(Delegation)이란?
        // 특정 기능을 다른 객체에 위임하고, 그에 따라 필요한 시점에서 메소드의 호출만 받는 패턴.
        // 델리게이트 참조를 통해 메소드를 호출할 인스턴스 객체를 전달받고,
        // 이 인스턴스 객체가 구현하고 있는 프로토콜에 선언된 메소드를 호출하는 것.
        locationManager.delegate = self
        
        // 밑에 두 줄을 작성하지 않으면 위치 속도를 가져오는데 엄청 걸린다.         Ref)https://www.debugcn.com/ko/article/21949717.html
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest  // 정확도 설정.
        locationManager?.startUpdatingLocation()                    // 사용자의 현재 위치에 대해 업데이트를 시작함.
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("🤔 권한 상태를 체크 중입니다.")
        handleAuthenticalStatus(status: manager.authorizationStatus)
    }
    
    func handleAuthenticalStatus(status: CLAuthorizationStatus) {
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
            print("⚠️ 경고: 알 수 없는 권한상태 입니다! : \(status)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("🕊 지역을 업데이트 중입니다.")
        
        let currentLocation = locations.last ?? CLLocation()
        
        print("🌿 현재 위치의 위도와 경도는 \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude) 입니다.")
        
        let geocoder = CLGeocoder()
        
        // CLGeocoder로 위도, 경도 정보를 사용하여 주소 정보 얻기.
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            var locationName = ""
            
            if placemarks != nil {
                // 첫 번째 placemark 가져오기.
                let placemark = placemarks?.last
                
                locationName = placemark?.name ?? "알 수 없습니다"
            } else {
                print("🚫 에러: 검색장소 에러.")
                locationName = "위치를 찾을 수 없습니다."
            }
            print("현재 위치 : \(locationName)")
            
            // pageVC를 불러온 뒤, 해당 뷰컨트롤러의 weatherLocations변수에 현재 위치 정보를 업데이트해준다.
            let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
            
            pageVC.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.latitude
            pageVC.weatherLocations[self.locationIndex].longitude = currentLocation.coordinate.longitude
            pageVC.weatherLocations[self.locationIndex].name = locationName

            self.updateUserInterface()
            
            self.locationManager?.stopUpdatingLocation()
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
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("🚫 에러: \(error.localizedDescription). 디바이스의 위치정보를 가져오는데 실패하였습니다.")
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
