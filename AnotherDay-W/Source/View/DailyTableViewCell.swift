//
// DailyTableViewCell.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/12.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit

class DailyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dailyImageView: UIImageView!
    @IBOutlet weak var dailyDateLabel: UILabel!
    @IBOutlet weak var dailyHighLabel: UILabel!
    @IBOutlet weak var dailyLowLabel: UILabel!
    
    var dailyWeather: DailyWeather! {
        didSet {
            dailyImageView.image = UIImage(named: dailyWeather.dailyIcon)
            dailyDateLabel.text = dailyWeather.dailyWeekday
            dailyHighLabel.text = "\(dailyWeather.dailyHigh)"
            dailyLowLabel.text = "\(dailyWeather.dailyLow)"
        }
    }
}
