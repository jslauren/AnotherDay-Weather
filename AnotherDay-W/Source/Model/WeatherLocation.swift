//
// WeatherLocation.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/07.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
