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

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "EEEE"
    
    return dateFormatter
}()

struct DailyWeather {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
    }
    
    private struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Daily: Codable {
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
    }
    
    private struct Weather: Codable {
        var description: String
        var icon: String
    }
    
    private struct Temp: Codable {
        var max: Double
        var min: Double
    }
    
    var currentTime = 0.0
    var temperature = 0
    var maxTemperature = 0
    var minTemperature = 0
    var summary = ""
    var dayIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    
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
                self.dayIcon = result.current.weather[0].icon
                
                for index in 0..<result.daily.count {
                    let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
                    
                    // 타임존 맞추기. ex) +0900 Asia/Seoul
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    
                    let dailyWeekday = dateFormatter.string(from: weekdayDate)
                    let dailyIcon = result.daily[index].weather[0].icon
                    let dailySummary = result.daily[index].weather[0].description
                    let dailyHigh = Int(result.daily[index].temp.max.rounded()) // .rounded() -> 반올림
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    
                    self.dailyWeatherData.append(dailyWeather)
                    
                    print("Day: \(dailyWeekday), High: \(dailyHigh), Low: \(dailyLow)")
                }
                
            } catch {
                print("🚫 JSON 에러: \(error.localizedDescription)")
            }
            completed()
        }
        
        task.resume()
    }
}

