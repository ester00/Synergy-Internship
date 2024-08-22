//
//  AddRemainderView.swift
//  VacationsApp
//
//  Created by Synergy01 on 16.07.24.
//

import SwiftUI
import CoreData

struct AddRemainderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var vacation: DesiredVacations
    @State private var remainderTitle = ""
    @State private var remainderDate = Date()
    @Environment(\.presentationMode) var presentationMode
    @State private var showError = false

    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("New Remainder")
                .font(.title2)
                .padding()
            Divider()
            HStack{
                Text("Title:")
                    .padding(.trailing)
                TextField("", text: $remainderTitle)
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            if showError {
                Text("Title can't be empty.")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            DatePicker("Date:", selection: $remainderDate, displayedComponents: [.date, .hourAndMinute])
                .padding()
            Divider()
            Button("Save") {
                if remainderTitle.isEmpty {
                    showError = true
                } else {
                    showError = false
                    saveRemainder()
                }
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .padding()
        .frame(width: 350, height: 50, alignment: .center)
    }
    
    private func saveRemainder () {
        if remainderTitle.isEmpty {
            print("Remainder name can't be empty")
            return
        }
        let notification = Notifications(context: viewContext)
        notification.title = remainderTitle
        notification.date = remainderDate
        notification.vacation = vacation
        do {
            try viewContext.save()
            NotificationManager.shared.scheduleNotification(title: remainderTitle, date: remainderDate, id: UUID().uuidString)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("failed to save remainder")
        }
    }   
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleVacation = DesiredVacations(context: context)
    sampleVacation.name = "Sample Vacation"
    sampleVacation.location = "Sample location"
    sampleVacation.hotelName = "Sample hotel"
    sampleVacation.necessaryMoneyAmount = 1000
    sampleVacation.vDescription = "Sample description"
    
    return AddRemainderView(vacation: sampleVacation).environment(\.managedObjectContext, context)
}
