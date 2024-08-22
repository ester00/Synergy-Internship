//
//  VacationsView.swift
//  VacationsApp
//
//  Created by Synergy01 on 15.07.24.
//

import SwiftUI
import CoreData
import PhotosUI

struct VacationsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DesiredVacations.name, ascending: true)],
        animation: .default)
    private var vacations: FetchedResults<DesiredVacations>
    
    @StateObject var vm = VacationsViewViewModel()

    var body: some View {
        NavigationView {
            VStack{
                Text("Desired Vacations")
                    .font(.title)
                
                VStack {
                    HStack {
                        Text("Add new vacation:")
                            .font(.title3)
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: vm.isFormExpanded ? "minus.circle.fill" : "plus.circle.fill")
                            .onTapGesture {
                                withAnimation {
                                    if vm.isFormExpanded {
                                        vm.clearForm()
                                        vm.showError = false
                                    }
                                    vm.isFormExpanded.toggle()
                                }
                            }
                    }
                    if vm.isFormExpanded {
                        VStack {
                            TextField("Vacation name...", text: $vm.vacationName)
                                .padding(6)
                                .background(vm.showError && vm.vacationName.isEmpty ? Color.red.opacity(0.3) : Color.clear)
                            TextField("Hotel name...", text: $vm.hotelName)
                                .padding(6)
                                .background(vm.showError && vm.hotelName.isEmpty ? Color.red.opacity(0.3) : Color.clear)
                            TextField("Location...", text: $vm.location)
                                .padding(6)
                                .background(vm.showError && vm.location.isEmpty ? Color.red.opacity(0.3) : Color.clear)
                            TextField("Necessary money amount...", text: $vm.necessaryMoney)
                                .padding(6)
                                .background(vm.showError && vm.necessaryMoney.isEmpty ? Color.red.opacity(0.3) : Color.clear)
                            TextField("Description...", text: $vm.description)
                                .padding(6)
                                .background(vm.showError && vm.description.isEmpty ? Color.red.opacity(0.3) : Color.clear)
                            TextField("Image name...", text: $vm.imageName)
                                .padding(6)
                                .background(vm.showError && vm.imageName.isEmpty ? Color.red.opacity(0.3) : Color.clear)
                        }
                        .padding()
                        
                        PhotosPicker(selection: $vm.selectedItem, matching: .images) {
                            Spacer()
                            Text("Upload Image")
                                .padding(6)
                                .foregroundColor(vm.showError && vm.selectedImage == nil ? Color.red : Color.blue)
                            Spacer()
                        }
                        
                        if let selectedImage = vm.selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                if (vm.vacationName.isEmpty) || (vm.hotelName.isEmpty) || (vm.imageName.isEmpty) || (vm.location.isEmpty) || (vm.necessaryMoney.isEmpty) || (vm.imageName.isEmpty) || (vm.selectedImage == nil) {
                                    vm.showError = true
                                } else {
                                    vm.showError = false
                                    addVacation()
                                }
                            }) {
                                Text("Save")
                                    .padding()
                            }
                            Spacer()
                        }
                        if vm.showError {
                            Text("Fields can't be empty.")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                }
                .padding()
                
                List {
                    ForEach(vacations) { vacation in
                        NavigationLink(destination: VacationDetailsView(vacation: vacation)) {
                            VStack(alignment: .leading) {
                                if let imageData = vacation.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                }
                                Text(vacation.name ?? " ")
                                    .font(.headline)
                                Text(vacation.location ?? " ")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deleteVacation)
                }
            }
            .padding()
        }
    }
    
    private func addVacation() {
        if vm.vacationName.isEmpty {
            print("Vacation name can't be empty")
            return
        }
        withAnimation {
            let newVacation = DesiredVacations(context: viewContext)
            newVacation.name = vm.vacationName
            newVacation.hotelName = vm.hotelName
            newVacation.location = vm.location
            newVacation.vDescription = vm.description
            newVacation.imageName = vm.imageName
            newVacation.imageData = vm.selectedImage?.jpegData(compressionQuality: 1.0)
            if let moneyAmount = Decimal(string: vm.necessaryMoney) {
                newVacation.necessaryMoneyAmount = NSDecimalNumber(decimal: moneyAmount)
            } else {
                newVacation.necessaryMoneyAmount = 0
            }
            do{
                try viewContext.save()
                print("Vacation saved.")
                vm.clearForm()
                vm.isFormExpanded = false
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteVacation(at offsets: IndexSet) {
        for index in offsets {
            let vacation = vacations[index]
            viewContext.delete(vacation)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

class VacationsViewViewModel: ObservableObject{
    @Published var vacationName: String = ""
    @Published var hotelName: String = ""
    @Published var location: String = ""
    @Published var necessaryMoney: String = ""
    @Published var description: String = ""
    @Published var imageName: String = ""
    @Published var isFormExpanded: Bool = false
    @Published var showError: Bool = false
    @Published var selectedImage: UIImage? = nil
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            if let selectedItem = selectedItem {
                Task {
                    await loadImage(from: selectedItem)
                }
            }
        }
    }
    
    func loadImage(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = uiImage
                }
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
    
    func clearForm() {
        vacationName = ""
        hotelName = ""
        location = ""
        necessaryMoney = ""
        description = ""
        imageName = ""
        selectedImage = nil
        selectedItem = nil
    }
}

#Preview {
    VacationsView()
}
