//
//  VacationDetailsView.swift
//  VacationsApp
//
//  Created by Synergy01 on 15.07.24.
//

import SwiftUI
import CoreData

struct VacationDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var vacation: DesiredVacations
    @FetchRequest var notifications: FetchedResults<Notifications>
    @State private var isEditing = false
    @State private var isAddingRemainder = false
    @State private var permissionGranted = false
    
    init(vacation: DesiredVacations) {
        self.vacation = vacation
        _notifications = FetchRequest<Notifications>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Notifications.date, ascending: true)],
            predicate: NSPredicate(format: "vacation == %@", vacation)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                Spacer()
                if let imageData = vacation.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
                Spacer()
            }

            Text("Vacation name: \(vacation.name ?? " ")")
            Divider()
            Text("Location: \(vacation.location ?? " ")")
            Divider()
            Text("Hotel name: \(vacation.hotelName ?? " ")")
            Divider()
            Text("Necessary money amount: \(vacation.necessaryMoneyAmount?.description ?? " ")")
            Divider()
            Text("Description: \(vacation.vDescription ?? " ")")
            Divider()
            Spacer()
            Text("My Remainders:")
                .padding(6)
                .font(.headline)
                .background(.yellow)
            List {
                ForEach (notifications, id: \.self) { notification in
                    VStack(alignment: .leading) {
                        Text(notification.title ?? " ")
                            .font(.headline)
                        Text("\(notification.date ?? Date(), formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                .onDelete(perform: deleteNotification)
            }
        }
        .padding()
        .navigationTitle("Vacation Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button( action: {
                    isEditing.toggle()
                }) {
                    Text("Edit")
                }
            }
            ToolbarItem {
                Button(action: requestPermission) {
                 Label(" ", systemImage: "calendar.badge.plus")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditVacationView(vacation: vacation)
                .presentationDetents([.height(550)])
        }
        .sheet(isPresented: $isAddingRemainder) {
         AddRemainderView(vacation: vacation)
                .presentationDetents([.height(350)])
        }
    }
    
    private func requestPermission() {
        NotificationManager.shared.requestPermission { granted in
            permissionGranted = granted
            if granted {
                isAddingRemainder = true
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func deleteNotification(at offsets: IndexSet) {
        for index in offsets {
            let notification = notifications[index]
            viewContext.delete(notification)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
    
    return VacationDetailsView(vacation: sampleVacation).environment(\.managedObjectContext, context)
    }
