//
//  EditVacationView.swift
//  VacationsApp
//
//  Created by Synergy01 on 15.07.24.
//

import SwiftUI
import CoreData
import PhotosUI

struct EditVacationView: View {
    @Environment(\.managedObjectContext) private var parentContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vacation: DesiredVacations
    @StateObject private var vm: EditVacationViewModel
    @State private var editContext: NSManagedObjectContext
    
    init(vacation: DesiredVacations) {
        self.vacation = vacation
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = vacation.managedObjectContext
        _editContext = State(initialValue: context)
        _vm = StateObject(wrappedValue: EditVacationViewModel(vacation: vacation))
    }
    
    var body: some View {
        VStack {
            if let selectedImage = vm.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            
            PhotosPicker(selection: $vm.selectedItem, matching: .images) {
                Text("Upload Image")
            }
            
            TextField("Vacation name", text: $vm.tempVacationName)
            Divider()
            
            TextField("Location", text: $vm.tempLocation)
            Divider()
            
            TextField("Hotel name", text: $vm.tempHotelName)
            Divider()
            
            TextField("Necessary money amount", text: $vm.tempNecessaryMoney)
            Divider()
            
            TextField("Description", text: $vm.tempDescription)
            Divider()
            
            Button(action: saveChanges) {
                Text("Save")
            }
            .buttonStyle(.bordered)
            .padding()
            Spacer()
        }
        .padding()
        .onAppear {
            if let imageData = vacation.imageData, let uiImage = UIImage(data: imageData) {
                vm.selectedImage = uiImage
            }
        }
        .onChange(of: vm.selectedItem) {
            Task {
                if let newItem = vm.selectedItem {
                    await loadImage(from: newItem)
                }
            }
        }
    }
    
    private func saveChanges() {
        vacation.name = vm.tempVacationName
        vacation.location = vm.tempLocation
        vacation.hotelName = vm.tempHotelName
        vacation.necessaryMoneyAmount = NSDecimalNumber(string: vm.tempNecessaryMoney)
        vacation.vDescription = vm.tempDescription
        vacation.imageData = vm.selectedImage?.jpegData(compressionQuality: 1.0)
        
        do {
            try editContext.save()
            try parentContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func loadImage(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.vm.selectedImage = uiImage
                }
            }
        } catch {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
}

class EditVacationViewModel: ObservableObject {
    @Published var tempVacationName: String
    @Published var tempLocation: String
    @Published var tempHotelName: String
    @Published var tempNecessaryMoney: String
    @Published var tempDescription: String
    @Published var selectedImage: UIImage? = nil
    @Published var selectedItem: PhotosPickerItem? = nil
    
    init(vacation: DesiredVacations) {
        self.tempVacationName = vacation.name ?? ""
        self.tempLocation = vacation.location ?? ""
        self.tempHotelName = vacation.hotelName ?? ""
        self.tempNecessaryMoney = vacation.necessaryMoneyAmount?.stringValue ?? ""
        self.tempDescription = vacation.vDescription ?? ""
    }}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleVacation = DesiredVacations(context: context)
    sampleVacation.name = "Sample Vacation"
    sampleVacation.location = "Sample location"
    sampleVacation.hotelName = "Sample hotel"
    sampleVacation.necessaryMoneyAmount = 1000
    sampleVacation.vDescription = "Sample description"
    
    return EditVacationView(vacation: sampleVacation).environment(\.managedObjectContext, context)
}
