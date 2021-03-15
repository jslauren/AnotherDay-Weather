//
// AddLocationVC.swift
// AnotherDay-W
//
// Created by jslauren on 2021/03/07.
// Copyright © 2021 jslauren. All rights reserved.
//
// Swift version : 5.0
// MacOS version : 11.2
//


import UIKit
import GooglePlaces

class AddLocationVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var weatherLocations: [WeatherLocation] = []
    var selectedLocationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "편집"
            addButton.isEnabled = true
        }
        else {
            tableView.setEditing(true, animated: true)
            sender.title = "완료"
            addButton.isEnabled = false
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        loadLocations()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
        saveLocations()
    }
    
    func saveLocations() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherLocations) {
            UserDefaults.standard.setValue(encoded, forKey: "weatherLocations")
        } else {
            print("🚫 에러: 인코딩 저장이 작동하지 않습니다!")
        }
    }
    
    func loadLocations() {
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            print("⚠️ 경고: 'UserDefaults'로 부터 weatherLocations 데이터를 불러올 수 없습니다. 이 에러는 앱이 처음 설치되었을때 발생하는 에러이므로, 해당 경우에는 무시하셔도 좋습니다.")
            return
        }
        let decoder = JSONDecoder()
        if let weatherLocations = try? decoder.decode(Array.self, from: locationsEncoded) as [WeatherLocation] {
            self.weatherLocations = weatherLocations
        } else {
            print("🚫 에러: UserDefaults로 부터 decode데이터를 읽지 못하였습니다.")
        }
    }
}

extension AddLocationVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    // 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = weatherLocations[indexPath.row].name
        cell.detailTextLabel?.text = "Lat:\(weatherLocations[indexPath.row].latitude), Lon:\(weatherLocations[indexPath.row].longitude)"
        
        return cell
    }
    
    // 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weatherLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // 순서 이동 및 변경
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = weatherLocations[sourceIndexPath.row]
        
        weatherLocations.remove(at: sourceIndexPath.row)
        weatherLocations.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    // 첫 번째 위치(=현재 위치) 를 삭제하지 못하게 설정하기
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return (proposedDestinationIndexPath.row == 0 ? sourceIndexPath : proposedDestinationIndexPath)
    }
}

extension AddLocationVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let newLocation = WeatherLocation(name: place.name ?? "알수없는 위치", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        weatherLocations.append(newLocation)
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("🚫 Error: ", error.localizedDescription)
    }
    
    // 취소 버튼 터치 시, 창 닫기.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
