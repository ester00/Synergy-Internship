//
//  ReadArticlesCount.swift
//  NewsApp
//
//  Created by Synergy01 on 28.07.24.
//

import Foundation
import Combine

class ReadArticlesCount: ObservableObject {
    @Published var count: Int {
        didSet {
            UserDefaults.standard.set(count, forKey: "ReadArticlesCount")
        }
    }

    init() {
        self.count = UserDefaults.standard.integer(forKey: "ReadArticlesCount")
    }
}

