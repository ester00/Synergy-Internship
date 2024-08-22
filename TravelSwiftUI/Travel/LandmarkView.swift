//
//  LandmarksView.swift
//  TravelApp
//
//  Created by Synergy01 on 9.07.24.
//

import SwiftUI
import CoreData
import MapKit

struct LandmarkView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var city: City
    @FetchRequest var landmarks: FetchedResults<Landmark>
    @StateObject var vm = LandmarkViewViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    
    init(city: City) {
        self.city = city
        self._landmarks = FetchRequest(
            entity: Landmark.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Landmark.name, ascending: true)],
            predicate: NSPredicate(format: "city == %@", city)
        )
    }
    
    var body: some View {
        VStack{
            HStack{
                Text("Add landmark: ")
                TextField("name...", text: $vm.landmarkName)
                    .padding(6)
                    .border(vm.isValidLandmarkName ? Color.gray : Color.red)
            }
            .padding()
            
            if vm.showError {
                Text(vm.landmarkName.isEmpty ? "Landmark name can't be empty." : "Invalid landmark name. Only letters and spaces are allowed.")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            List {
                ForEach(landmarks) {landmark in
                    NavigationLink(destination: MapView(vm: mapViewModel)) {
                        Text(landmark.name ?? "")
                    }
                    .onAppear {
                        mapViewModel.pinCoordinate = CLLocationCoordinate2D(
                            latitude: landmark.latitude,
                            longitude: landmark.longitude
                        )
                        mapViewModel.isPinned = true
                    }
                }
                .onDelete(perform:
                            deleteLandmark(offsets:))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button (action: {
                        if vm.landmarkName.isEmpty{
                            vm.showError = true
                        } else if vm.isValidLandmarkName {
                            vm.showMap = true
                            mapViewModel.pinCoordinate = nil
                            mapViewModel.isPinned = false
                            vm.showError = false
                        } else {
                            vm.showMap = false
                            vm.showError = true
                        }
                    }) {
                        Label("Add Landmark", systemImage: "plus")
                    }
                }
            }
        }
        .navigationTitle("Landmarks in \(city.name ?? " ")")
        .sheet(isPresented: $vm.showMap) {
            VStack{
                MapView(vm: mapViewModel)
                if mapViewModel.isPinned {
                    Button(action: {
                        if let coordinate = mapViewModel.pinCoordinate {
                            addLandmark(coordinate: coordinate)
                            vm.showMap = false
                        }
                    }) {
                        Text("Save")
                    }
                    .padding()
                } else {
                    Button(action: {
                        vm.showMap = false
                    }) {
                        Text("Cancel")
                    }
                    .padding()
                }
            }
            }
            .onAppear {
                geocodeCity(name: city.name ?? " ") { coordinate in
                    if let coordinate = coordinate {
                        print("map region to city coordinates: \(coordinate.latitude), \(coordinate.longitude)")
                        mapViewModel.cityCoordinate = coordinate
                    } else {
                        print("Failed to geocode city name")
                    }
                }
            }
    }   
    
    private func addLandmark(coordinate: CLLocationCoordinate2D) {
        if vm.landmarkName.isEmpty || !vm.isValidLandmarkName {
            print("Landmark name is invalid or empty")
            return
        }
        withAnimation {
            let newLandmark = Landmark(context: viewContext)
            newLandmark.name = vm.landmarkName
            newLandmark.city = city
            newLandmark.latitude = coordinate.latitude
            newLandmark.longitude = coordinate.longitude
            do {
                try viewContext.save()
                vm.landmarkName = ""
                mapViewModel.pinCoordinate = nil
                mapViewModel.isPinned = false
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteLandmark(offsets: IndexSet) {
        withAnimation {
            offsets.map { landmarks[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func geocodeCity(name: String, completion: @escaping(CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
    class LandmarkViewViewModel: ObservableObject{
        @Published var landmarkName: String = "" {
            didSet {
                validateLandmarkName()
            }
        }
        @Published var isValidLandmarkName: Bool = true
        @Published var showMap: Bool = false
        @Published var showError: Bool = false
        @Published var pinCoordinate: CLLocationCoordinate2D?
        @Published var isPinAdded = false
        @Published var cityCoordinate: CLLocationCoordinate2D?
        
        func validateLandmarkName() {
            let pattern = "^[a-zA-Z\\s]+$"
            let regex = try!NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: landmarkName.utf16.count)
            isValidLandmarkName = regex.firstMatch(in: landmarkName, options: [], range: range) != nil
            showError = !isValidLandmarkName || landmarkName.isEmpty
        }
    }
    
    #Preview {
        let context = PersistenceController.preview.container.viewContext
        let sampleCity = City(context: context)
        sampleCity.name = "Sample City"
        
        return LandmarkView(city: sampleCity).environment(\.managedObjectContext, context)
    }
}

