//
//  NewsAppApp.swift
//  NewsApp
//
//  Created by Synergy01 on 17.07.24.
//

import SwiftUI

@main
struct NewsAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NewsTopicsView()
                .environmentObject(ReadArticlesCount())
        }
    }
}
