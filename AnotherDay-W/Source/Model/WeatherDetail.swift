//
// WeatherDetail.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/11.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import Foundation

class WeatherDetail: WeatherLocation {
    
    struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
    }
    
    struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    struct Daily: Codable {
        var temp: Temp
        var sunrise: TimeInterval
        var sunset: TimeInterval
    }
    
    struct Weather: Codable {
        var description: String
        var icon: String
    }
    
    struct Temp: Codable {
        var min: Double
        var max: Double
    }
    
    var currentTime = 0.0
    var temperature = 0
    var maxTemperature = 0
    var minTemperature = 0
    var summary = ""
    var dailyIcon = ""
    
    func getData(completed: @escaping () -> ()) {
        let urlString =  "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&appid=\(APIkeys.openWheatherKey)"
        
        print("🏃🏻 URL에 접근하는 중입니다. \(urlString)")
        
        // URL 생성
        guard let url = URL(string: urlString) else {
            print("🚫 에러: URL을 생성할 수 없습니다. \(urlString)")
            completed()
            
            return
        }
        
        // 세션 생성
        let session = URLSession.shared
        
        // .dataTsk메서드를 이용하여 데이터 받아오기.
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("🚫 에러: \(error.localizedDescription)")
            }
            
            do {
                let result = try JSONDecoder().decode(Result.self, from: data!)
                
                print("'\(self.name)'의 타임 존 : \(result.timezone)")
                
                //self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.maxTemperature = Int(result.daily[0].temp.max.rounded())
                self.minTemperature = Int(result.daily[0].temp.min.rounded())
                self.summary = result.current.weather[0].description
                self.dailyIcon = result.current.weather[0].icon
                
            } catch {
                print("🚫 JSON 에러: \(error.localizedDescription)")
            }
            completed()
        }
        
        task.resume()
    }
}

