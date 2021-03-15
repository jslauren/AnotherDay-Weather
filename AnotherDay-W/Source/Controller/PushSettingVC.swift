//
// PushSettingVC.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/14.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit
import UserNotifications

class PushSettingVC: UIViewController {
    
    @IBOutlet weak var settedTimeLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var serviceSwitch: UISwitch!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        getDate()
        
    }
    
    @IBAction func xButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        if datePicker.isEnabled == true {
            let pickerDate = dateFormatter.string(from: datePicker.date)
            
            UserDefaults.standard.setValue(pickerDate, forKey: "pushDate")
            
            setNotification(pickerDate: pickerDate)
            showToastAlert(controller: self, message: "설정되었습니다!", seconds: 0.7)
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            showToastAlert(controller: self, message: "비활성화되었습니다!", seconds: 0.7)
        }
        
        UserDefaults.standard.setValue(serviceSwitch.isOn, forKey: "switchStatus")
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        if sender.isOn == true {
            self.datePicker.isEnabled = true
            
        } else {
            self.datePicker.isEnabled = false
            settedTimeLabel.text = "서비스가 비활성화 되어있습니다."
        }
    }
    
    func initView() {
        // 옵저버 추가.
        NotificationCenter.default.addObserver(self, selector: #selector(handleAuthenticalStatus), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // 권한요청.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { didAllow, Error in
            if didAllow == false {
                self.showAlertToPrivacySetting(title: "푸시알림 권한이 거부되었습니다.", message: "앱 설정 화면에서 푸시알림 권한을 허용해 주세요.")
            }
        }
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
    }
    
    func getDate() {
        let status = UserDefaults.standard.bool(forKey: "switchStatus")
        
        if status == true {
            let loadDate = UserDefaults.standard.string(forKey: "pushDate")
            
            // 설정해놓은 시간이 존재한다면, 해당시간으로 datePicker의 값을 셋팅.
            if loadDate != "" {
                let pickerDate = dateFormatter.date(from: loadDate!)
                
                datePicker.date = pickerDate!
            }
            
            serviceSwitch.isOn = status
            datePicker.isEnabled = status
            settedTimeLabel.text = "현재 설정 된 시각 : \(loadDate ?? "설정된 시간이 없습니다!")"
        } else {
            settedTimeLabel.text = "서비스가 비활성화 되어있습니다."
        }
    }
    
    func setNotification(pickerDate: String) {
        // 노티 콘텐츠 설정.
        let content = UNMutableNotificationContent()
        
        content.title = "외출 준비 중이신가요? 🤔"
        content.body = "오늘의 날씨를 확인해 보세요!"
        
        let array = pickerDate.components(separatedBy: [" ", ":"])
        var date = DateComponents()
        
        date.hour = array[0] == "오후" ? Int(array[1])! + 12 : Int(array[1])
        date.minute = Int(array[2])
        
        // 푸시알림 요청하기.
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "morningPush", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @objc private func handleAuthenticalStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .denied:
                self.showAlertToPrivacySetting(title: "푸시알림 권한이 거부되었습니다.", message: "앱 설정 화면에서 푸시알림 권한을 허용해 주세요.")
            case .authorized, .provisional, .ephemeral, .notDetermined:
                break
            @unknown default:
                print("⚠️ 경고: 알 수 없는 권한상태 입니다!")
            }
        }
    }
    
    // 위치정보 권한 거부 시 설정화면 유도 알림 함수.
    func showAlertToPrivacySetting(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                print("UIApplication.openSettingsURLStrings를 가져오는데 문제가 발생하였습니다.")
                return
            }
            let settingsAction = UIAlertAction(title: "설정", style: .default) { (_) in
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .default) { (_) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showToastAlert(controller: UIViewController, message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit { // 노티 옵저버 제거.
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
