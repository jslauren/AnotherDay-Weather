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
                
        // 저장한 위치들을 불러온다.
        loadLocations()
    }
    
    // 코드 내에 특정 Segue를 작동시키기 위해서는 perfomeSegue를 사용하는데,
    // 이 메서드가 작동하기 전에 데이터를 전달할 수 있는 시기가 prepare메서드를 통해 이뤄질 수 있다.
    // 뷰 컨트롤러 전환 전에 데이터를 처리할 수 있는 메서드가 prepare메서드다.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 선택 된 Location의 테이블 뷰 셀의 인덱스를 selectedLocationIndex변수에 저장한다.
        // MainVC에서 해당 값에 접근하여 선택 된 Location의 정보들을 띄워주기 위해서이다.
        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
        saveLocations()
    }
    
    // 뷰 전환을 하면 검색한 위치데이터 값들은 사라지므로, 해당 값들이 사라지지 않기 위해 UserDefaults를 사용하여 저장해 놓는다.
    // 값들을 Json 형식으로 저장할 예정이므로, Model폴더의 'WeatherLocation' 클래스에 'Codable'을 채택해준다.
    func saveLocations() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherLocations) {
            UserDefaults.standard.setValue(encoded, forKey: "weatherLocations")
        } else {
            print("🚫 에러: 인코딩 저장이 작동하지 않습니다!")
        }
    }
    
    // 저장해놓은 위치 데이터들을 뷰가 불려질때마다 불러온다.
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
    print("🚫 Error: ", error.localizedDescription)
  }

  // 취소 버튼 터치 시, 창 닫기.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }
    
}
