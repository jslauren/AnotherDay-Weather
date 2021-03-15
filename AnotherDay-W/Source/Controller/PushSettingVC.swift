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
            // datePicker로 부터 포맷을 적용한 데이터를 받아와서 UserDefaults에 저장.
            let pickerDate = dateFormatter.string(from: datePicker.date)
            
            UserDefaults.standard.setValue(pickerDate, forKey: "pushDate")
            
            setNotification(pickerDate: pickerDate)
            showToastAlert(controller: self, message: "설정되었습니다!", seconds: 0.7)
        } else {
            // 추가한 모든 노티를(1개) 제거한다.
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            showToastAlert(controller: self, message: "비활성화되었습니다!", seconds: 0.7)
        }
        
        UserDefaults.standard.setValue(serviceSwitch.isOn, forKey: "switchStatus")
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        if sender.isOn == true {
            self.datePicker.isEnabled = true
            // getDate()
            
        } else {
            self.datePicker.isEnabled = false
            settedTimeLabel.text = "서비스가 비활성화 되어있습니다."
        }
    }
    
    func initView() {
        // 옵저버 추가.
        // UIApplication.willEnterForegroundNotification => 앱이 백그라운드에서 포그라운드로 전환되었을때,
        // #selector()안쪽의 메소드인 handleAuthenticalStatus를 실행한다.
        NotificationCenter.default.addObserver(self, selector: #selector(handleAuthenticalStatus), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // 권한요청.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { didAllow, Error in
            // 권한 요청 거부시,
            if didAllow == false {
                self.showAlertToPrivacySetting(title: "푸시알림 권한이 거부되었습니다.", message: "앱 설정 화면에서 푸시알림 권한을 허용해 주세요.")
            }
        }
        
        // datePicker로부터 받을 데이터의 포맷 설정.
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
        
        // datePicker로 부터 넘어온 String형식의 데이터를 DateComponents형식으로 변경하기.
        // '오전_hh:mm' 형식으로 들어온것을 ["오전", "hh", "mm"] 형식으로 잘라 배열에 넣기.
        let array = pickerDate.components(separatedBy: [" ", ":"])
        var date = DateComponents()
        
        // 오후면 시간에 12를 더해준다.
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
        
        //alert.view.backgroundColor = .white
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            // Toast Alert 종료.
            alert.dismiss(animated: true)
            
            // 해당 모달 뷰 닫기.
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit { // 노티 옵저버 제거.
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

