//
//  Models.swift
//  NewsApp
//
//  Created by Synergy01 on 17.07.24.
//

import Foundation

struct Article: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    

    static var sampleArticle: Article {
        return Article(title: "Sample Article", description: "This is a sample description.", url: "https://example.com", urlToImage: nil)
    }
}

struct NewsResponse: Decodable {
    let articles: [Article]
}

