//
//  ContentView.swift
//  TravelApp
//
//  Created by Synergy01 on 9.07.24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \City.name, ascending: true)],
        animation: .default)
    private var cities: FetchedResults<City>
    
    @StateObject var vm = ContentViewViewViewModel()
    
    var body: some View {
        NavigationView {
            VStack{
                Text("Cities")
                    .font(.title)
                HStack{
                    Text("Add city: ")
                    TextField("name...", text: $vm.cityName)
                        .padding(6)
                        .border(vm.isValidCityName ? Color.gray : Color.red)
                }
                .padding()
                
                if vm.showError {
                    Text(vm.cityName.isEmpty ? "City name can't be empty" : "Invalid city name. Only letters and spaces are allowed.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                List {
                    ForEach(cities) { city in
                        NavigationLink(destination: LandmarkView(city: city)) {
                            Text(city.name ?? "")
                        }
                    }
                    .onDelete(perform: confirmDeleteCity)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading){
                        Text("Travel App")
                            .foregroundStyle(.blue)
                    }
                    ToolbarItem(placement: .principal) {
                        Image(systemName: "map.fill")
                            .foregroundStyle(.blue)
                    }
                    ToolbarItem {
                        Button(action: {
                            if vm.cityName.isEmpty {
                                vm.showError = true
                            } else if vm.isValidCityName {
                                addCity()
                                vm.showError = false
                            } else {
                                vm.showError = true
                            }
                        }) {
                            Label("Add City", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .alert(isPresented: $vm.showAlert) {
            Alert(
                title: Text("Delete City"),
                message: Text("This city has landmarks. Are you sure you want to delete it?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let city = vm.selectedCity {
                        deleteCity(city)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func addCity() {
        if vm.cityName.isEmpty || !vm.isValidCityName {
            print("City name is invalid or empty")
            return
        }
        withAnimation {
            let newCity = City(context: viewContext)
            newCity.name = vm.cityName
            
            do {
                try viewContext.save()
                vm.cityName = ""
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func confirmDeleteCity(at offsets: IndexSet) {
        for index in offsets {
            let city = cities[index]
            if city.landmarks?.count ?? 0 > 0 {
                vm.selectedCity = city
                vm.showAlert = true
                return
            }
        }
        deleteCity(at: offsets)
    }
    
    private func deleteCity(_ city: City) {
            viewContext.delete(city)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }


    private func deleteCity(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let city = cities[index]
                if city.landmarks?.count ?? 0 > 0 {
                    return
                }
                viewContext.delete(city)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

class ContentViewViewViewModel: ObservableObject{
    @Published var cityName: String = "" {
        didSet {
            if !cityName.isEmpty {
                validateCityName()
            } else {
                isValidCityName = true
            }
        }
    }
    
    @Published var isValidCityName: Bool = true
    @Published var showError: Bool = false
    @Published var showAlert = false
    @Published var selectedCity: City?
        
    func validateCityName() {
        let pattern = "^[a-zA-Z\\s]+$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: cityName.utf16.count)
        isValidCityName = (regex.firstMatch(in: cityName, options: [], range: range) != nil)
        showError = !isValidCityName || cityName.isEmpty
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
