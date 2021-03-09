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
    
    var weatherLocations: [WeatherLocation] = []    // WeatherLocation 구조체 배열 생성.
    var selectedLocationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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

            // Display the autocomplete view controller.
            present(autocompleteController, animated: true, completion: nil)
    }
    
    func initView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // 테이블 뷰 배경 색 변경.
        self.view.backgroundColor = hexStringToUIColor(hex: baseColor)
        self.tableView.backgroundColor = hexStringToUIColor(hex: baseColor)
    }
    
    // 코드 내에 특정 Segue를 작동시키기 위해서는 perfomeSegue를 사용하는데,
    // 이 메서드가 작동하기 전에 데이터를 전달할 수 있는 시기가 prepare메서드를 통해 이뤄질 수 있다.
    // 뷰 컨트롤러 전환 전에 데이터를 처리할 수 있는 메서드가 prepare메서드다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 선택 된 Location의 테이블 뷰 셀의 인덱스를 selectedLocationIndex변수에 저장한다.
        // MainVC에서 해당 값에 접근하여 선택 된 Location의 정보들을 띄워주기 위해서이다.
        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
    }
}

extension AddLocationVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    // 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddLocationCell", for: indexPath)
        
        cell.textLabel?.text = weatherLocations[indexPath.row].name
        cell.backgroundColor = hexStringToUIColor(hex: baseColor)
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
    
}

extension AddLocationVC: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    // MARK: - 새로운 위치 정보 셋팅
    let newLocation = WeatherLocation(name: place.name ?? "알수없는 위치", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
    
    weatherLocations.append(newLocation)
    tableView.reloadData()
    
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // 취소 버튼 터치 시, 창 닫기.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }
    
}
