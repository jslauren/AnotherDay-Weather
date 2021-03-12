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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        updateUserInterface()
        
    }
    
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.backgroundColor = hexStringToUIColor(hex: baseColor)
        self.tableView.backgroundColor = hexStringToUIColor(hex: baseColor)
        
        clearUserInterface()
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
                self.compareLabel.text = "어제보다 2° 높음"
                self.tableView.reloadData()
                self.collectionView.reloadData()
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
        let destination = segue.destination as! AddLocationVC
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        
        destination.weatherLocations = pageVC.weatherLocations
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
