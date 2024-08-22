//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Synergy01 on 18.07.24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchArticles(for topic: String, page: Int, pageSize: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
        let apiKey = "1aef82be99c14df793c0de03cdb26889"
        let urlString = "https://newsapi.org/v2/everything?q=\(topic)&apiKey=\(apiKey)&page=\(page)&pageSize=\(pageSize)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                completion(.success(response.articles))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

