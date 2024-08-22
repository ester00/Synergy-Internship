//
//  MapView.swift
//  Travel
//
//  Created by Synergy01 on 10.07.24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @ObservedObject var vm = MapViewModel()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        if let coordinate = vm.cityCoordinate {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            mapView.setRegion(region, animated: true)
            print("Setting map region to city coordinates: \(coordinate.latitude), \(coordinate.longitude)")

        }
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addPin))
        mapView.addGestureRecognizer(gestureRecognizer)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let coordinate = vm.cityCoordinate {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            uiView.setRegion(region, animated: true)
            print("Setting map region to city coordinates: \(coordinate.latitude), \(coordinate.longitude)")
        }
        
        uiView.removeAnnotations(uiView.annotations)
        if let coordinate = vm.pinCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            uiView.addAnnotation(annotation)            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: MapView
        
        init(_ parent: MapView){
            self.parent = parent
        }
                
        @objc func addPin(gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            if let mapView = gestureRecognizer.view as? MKMapView {
                let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
                parent.vm.pinCoordinate = coordinate
                parent.vm.isPinned = true
            }
        }
    }
}
class MapViewModel: ObservableObject {
    @Published var pinCoordinate: CLLocationCoordinate2D?
    @Published var isPinned = false
    @Published var cityCoordinate: CLLocationCoordinate2D?
}
