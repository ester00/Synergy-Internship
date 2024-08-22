//
//  Models.swift
//  NewsApp
//
//  Created by Synergy01 on 25.07.24.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let content: String?
}
