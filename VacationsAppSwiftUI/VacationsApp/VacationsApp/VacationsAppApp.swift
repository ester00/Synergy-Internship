//
//  VacationsAppApp.swift
//  VacationsApp
//
//  Created by Synergy01 on 15.07.24.
//

import SwiftUI

@main
struct VacationsAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            VacationsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
