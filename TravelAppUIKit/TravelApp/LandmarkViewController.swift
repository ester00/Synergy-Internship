//
//  LandmarkViewController.swift
//  TravelApp
//
//  Created by Synergy01 on 19.07.24.
//

import UIKit
import CoreData
import CoreLocation

class LandmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MapViewControllerDelegate {
    
    func didAddNewLandmark() {
        fetchLandmarks()
    }
 
    @IBOutlet weak var LandmarkVIew: UITableView!    
    
    var landmarks: [Landmark] = []
    var selectedCity: City?
    var selectedLandmark: Landmark?
    var locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    var selectedCityCoordinates: CLLocationCoordinate2D?
    var landmarkName: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        LandmarkVIew.delegate = self
        LandmarkVIew.dataSource = self
        fetchLandmarks()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLandmarks()
    }
    
    func fetchLandmarks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Landmark>(entityName: "Landmark")
        
        if let city = selectedCity {
            fetchRequest.predicate = NSPredicate(format: "city == %@", city)
        }

        do {
            landmarks = try managedContext.fetch(fetchRequest)
            print("fetched landmarks: \(landmarks.count)")
            for landmark in landmarks {
                print("landmark: \(landmark.name ?? "no name")")
            }
            LandmarkVIew.reloadData()
        } catch {
            print("Failed to fetch landmarks: \(error.localizedDescription)")
        }
    }
    
    @IBAction func addOnTap(_ sender: UIBarButtonItem) {
        let TextFieldIndexTap = IndexPath(row: 1, section: 0)
        guard let textFieldCell = LandmarkVIew.cellForRow(at: TextFieldIndexTap) as? LandmarkFieldTableViewCell,
              let landmarkName = textFieldCell.landmarkNameField.text, !landmarkName.isEmpty else {
            showAlert(message: "Landmark name can't be empty")
            return
        }
        
        self.landmarkName = landmarkName
        print("landmark name: \(landmarkName)")
        
        guard let cityName = selectedCity?.name else {
            print("selectedCity?.name is nil")
            return
        }
        print("city name: \(cityName)")
        
        geocoder.geocodeAddressString(cityName) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first,
               let location = placemark.location {
                self.selectedCityCoordinates = location.coordinate
                print("selectedCityCoordinates: \(String(describing: self.selectedCityCoordinates))")
                self.performSegue(withIdentifier: "showMapView", sender: self)
                textFieldCell.landmarkNameField.text = ""
            } else {
                print("Geocoding failed to return a location")
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LandmarkInLabel", for: indexPath) as? LandmarkInLabel else {
                fatalError("could not dequeue")
            }
            if let cityName = selectedCity?.name {
                cell.setCityName(cityName)
            }
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "landmarkNameField", for: indexPath) as? LandmarkFieldTableViewCell else {
                return UITableViewCell()
            }
            return cell
        } else {
            let landmarkIndex = indexPath.row - 2
            let landmark = landmarks[landmarkIndex]
            let cell = tableView.dequeueReusableCell(withIdentifier: "LandmarkCell", for: indexPath)
            cell.textLabel?.text = landmark.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let landmarkIndex = indexPath.row - 2
            
            if landmarkIndex >= 0 && landmarkIndex < landmarks.count {
                let landmark = landmarks[landmarkIndex]
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    fatalError("unable to retrieve")
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                managedContext.delete(landmark)
                
                do {
                    try managedContext.save()
                    landmarks.remove(at: landmarkIndex)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }catch {
                    print("failed to delete landmark: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func didSelectCity(_ city: City) {
        self.selectedCity = city
        fetchLandmarks()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let landmarkIndex = indexPath.row - 2
        guard landmarkIndex >= 0 && landmarkIndex < landmarks.count else {
            return
        }
        selectedLandmark = landmarks[landmarkIndex]
        performSegue(withIdentifier: "showMapView", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapView" {
            if let destinationVC = segue.destination as? MapViewController {
                if let selectedLandmark = selectedLandmark {
                    destinationVC.cityName = selectedCity?.name
                    destinationVC.cityCoordinates = CLLocationCoordinate2D(latitude: selectedLandmark.latitude, longitude: selectedLandmark.longitude)
                    destinationVC.landmarkName = landmarkName
                    destinationVC.selectedCity = selectedCity
                    destinationVC.selectedLandmark = selectedLandmark
                } else {
                    destinationVC.cityName = selectedCity?.name
                    destinationVC.cityCoordinates = selectedCityCoordinates
                    destinationVC.landmarkName = landmarkName
                    destinationVC.selectedCity = selectedCity
                }
                destinationVC.delegate = self
            }
        }
    }
}
