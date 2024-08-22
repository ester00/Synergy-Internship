//
//  TravelApp.swift
//  Travel
//
//  Created by Synergy01 on 9.07.24.
//

import SwiftUI

@main
struct TravelApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
