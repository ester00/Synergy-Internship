//
//  MapViewController.swift
//  TravelApp
//
//  Created by Synergy01 on 19.07.24.
//

import UIKit
import MapKit
import CoreData

protocol MapViewControllerDelegate: AnyObject {
    func didAddNewLandmark()
}

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var cityName: String?
    var cityCoordinates: CLLocationCoordinate2D?
    var landmarkName: String?
    var selectedCity: City?
    var selectedLandmark: Landmark?
    weak var delegate: MapViewControllerDelegate?
    
    var selectedCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        if let coordinates = cityCoordinates {
            let region = MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            mapView.setRegion(region, animated: true)
            
            if let selectedLandmark = selectedLandmark {
                addAnnotation(for: selectedLandmark)
            } else {
                mapView.removeAnnotations(mapView.annotations)
            }
            
            if let selectedLandmark = selectedLandmark {
                let annotation = MKPointAnnotation()
                annotation.title = selectedLandmark.name
                annotation.coordinate = CLLocationCoordinate2D(latitude: selectedLandmark.latitude, longitude: selectedLandmark.longitude)
                mapView.addAnnotation(annotation)
            }
        } else {
            print("city coordinates nil")
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    func addAnnotation(for landmark: Landmark) {
        let annotation = MKPointAnnotation()
        annotation.title = landmark.name
        annotation.coordinate = CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude)
        mapView.addAnnotation(annotation)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                        
            mapView.removeAnnotations(mapView.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            selectedCoordinate = coordinate
            print("Pin placed at: \(coordinate.latitude), \(coordinate.longitude)")

        }
    }
    
    @IBAction func savePin(_ sender: Any) {
        guard let coordinate = selectedCoordinate else {
            print("no pin selected")
            return
        }
        print("Saving pin at coordinate: \(coordinate.latitude), \(coordinate.longitude)")
        saveNewLandmark(coordinate: coordinate)
        navigationController?.popViewController(animated: true)
    }
    
    func saveNewLandmark(coordinate: CLLocationCoordinate2D) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext,
              let landmarkName = landmarkName,
              let selectedCity = selectedCity else {
                print("failed to unwrap")
                return
        }
        
        let newLandmark = Landmark(context: context)
        newLandmark.name = landmarkName
        newLandmark.latitude = coordinate.latitude
        newLandmark.longitude = coordinate.longitude
        newLandmark.city = selectedCity
                
        do {
            try context.save()
            print("landmark saved")
            
            delegate?.didAddNewLandmark()
        } catch {
            print("Failed to save new landmark: \(error.localizedDescription)")
        }
    }
    
}
