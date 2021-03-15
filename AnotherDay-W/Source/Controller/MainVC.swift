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
    
    dateFormatter.dateFormat = "EEEE, MMM d"
    
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
        pageControl.numberOfPages = pageVC.weatherLocations.count
        pageControl.currentPage = locationIndex
        
        weatherDetail.getData {
            DispatchQueue.main.async { [self] in
                self.temperatureImageView.image = UIImage(named: self.weatherDetail.dayIcon)
                self.placeLabel.text = self.weatherDetail.name
                self.summaryLabel.text = self.weatherDetail.summary
                self.temperatureLabel.text = "\(self.weatherDetail.temperature)°"
                self.maxTemperatureLabel.text = "최고 : \(self.weatherDetail.maxTemperature)°"
                self.minTemperatureLabel.text = "최저 : \(self.weatherDetail.minTemperature)°"
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
    
    func clearUserInterface() {
        placeLabel.text = ""
        summaryLabel.text = ""
        temperatureImageView.image = UIImage()
        temperatureLabel.text = ""
        maxTemperatureLabel.text = ""
        minTemperatureLabel.text = ""
        compareLabel.text = ""
    }
    
    @IBAction func unwindFromMainVC(segue: UIStoryboardSegue) {
        let source = segue.source as! AddLocationVC
        
        locationIndex = source.selectedLocationIndex
        
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        
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
        if sender.currentPage < locationIndex {
            direction = .reverse
        }
        
        pageVC.setViewControllers([pageVC.createMainVC(forPage: sender.currentPage)], direction: direction, animated: true, completion: nil)
    }
    
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDetail.dailyWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DailyTableViewCell
        
        cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
        
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
        locationManager.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
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

// 경고창 출력 함수
extension UIViewController {
    func oneButtonAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

