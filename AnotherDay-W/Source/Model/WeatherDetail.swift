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

private let hourFormatter: DateFormatter = {
    let hourFormatter = DateFormatter()
    
    hourFormatter.dateFormat = "a h시"
    
    return hourFormatter
}()

struct DailyWeather {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

struct HourlyWeather {
    var hour: String
    var hourlyTemprature: Int
    var hourlyIcon: String
}

class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
        var hourly: [Hourly]
    }
    
    private struct HistoricalResult: Codable {
        var timezone: String
        var current: Current
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
    
    private struct Hourly: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Weather: Codable {
        var description: String
        var icon: String
        var id: Int
    }
    
    private struct Temp: Codable {
        var max: Double
        var min: Double
    }
    
    var currentTime = 0.0
    var temperature = 0
    var historicalTemperature = 0
    var maxTemperature = 0
    var minTemperature = 0
    var summary = ""
    var dayIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    var hourlyWeatherData: [HourlyWeather] = []
    
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
                
                self.currentTime = result.current.dt
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
                    let dailyHigh = Int(result.daily[index].temp.max.rounded())
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    
                    self.dailyWeatherData.append(dailyWeather)
                }
                
                // Default는 너무 많은 데이터가 넘어오니 24시간만 받도록 강제함.
                let lastHour = min(24, result.hourly.count)
                
                if lastHour > 0 {
                    // 0부터 시작하면 현재 시간의 온도부터 나오기 때문에 1부터 시작한다.
                    for index in 1..<lastHour {
                        let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                        
                        // 타임존 맞추기. ex) +0900 Asia/Seoul
                        hourFormatter.timeZone = TimeZone(identifier: result.timezone)
                        
                        let hour = hourFormatter.string(from: hourlyDate)
                        let hourlyIcon = result.hourly[index].weather[0].icon
                        let hourlyTempreature = Int(result.hourly[index].temp.rounded())
                        let hourlyWeather = HourlyWeather(hour: hour, hourlyTemprature: hourlyTempreature, hourlyIcon: hourlyIcon)
                        
                        self.hourlyWeatherData.append(hourlyWeather)
                    }
                }
            } catch {
                print("🚫 JSON 에러: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
    
    func getHistoricalData(dt: TimeInterval, completed: @escaping () -> ()) {
        // 유닉스시간법이라 어제의 시간을 구하려면 -86400을 해주어야 함.
        let historicalURLString = "https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=\(latitude)&lon=\(longitude)&dt=\(Int(dt.rounded() - 86400))&units=metric&appid=\(APIkeys.openWheatherKey)"
        
        print("🏃🏻🏃🏻 historicalURLString에 접근하는 중입니다. \(historicalURLString)")
        
        guard let url = URL(string: historicalURLString) else {
            print("🚫 에러: URL을 생성할 수 없습니다. \(historicalURLString)")
            completed()
            
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("🚫 에러: \(error.localizedDescription)")
            }
            
            do {
                let result = try JSONDecoder().decode(HistoricalResult.self, from: data!)
                
                self.historicalTemperature = Int(result.current.temp.rounded())
            } catch {
                print("🚫 JSON 에러: \(error.localizedDescription)")
            }
            completed()
        }
        task.resume()
    }
}

