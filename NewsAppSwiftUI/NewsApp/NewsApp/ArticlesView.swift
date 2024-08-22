//
//  ArticlesView.swift
//  NewsApp
//
//  Created by Synergy01 on 17.07.24.
//

import SwiftUI

struct ArticlesView: View {
    let topic: String
    @State private var articles: [Article] = []
    @State private var errorMessage: String?
    @State private var currentPage = 1
    @EnvironmentObject var readArticlesCount: ReadArticlesCount
    private let pageSize = 10

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            ScrollViewReader { scrollViewProxy in
                List(articles) { article in
                    NavigationLink(destination: ArticleDetailsView(article: article).environmentObject(readArticlesCount)) {
                        VStack(alignment: .leading) {
                            Text(article.title)
                                .font(.headline)
                                .padding()
                            if let urlToImage = article.urlToImage, let url = URL(string: urlToImage) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 150)
                                        .cornerRadius(8)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                    .id(article.id)
                }
                .navigationTitle(topic)
                .onAppear {
                    fetchArticles(for: topic)
                }
                .onChange(of: currentPage) { _ in
                    withAnimation {
                        scrollViewProxy.scrollTo(articles.first?.id, anchor: .top)
                    }
                }
            }

            HStack {
                Button(action: {
                    if currentPage > 1 {
                        currentPage -= 1
                        fetchArticles(for: topic)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(currentPage > 1 ? .blue : .gray)
                }
                .disabled(currentPage == 1)

                Text("Page \(currentPage)")
                    .font(.headline)
                    .padding(.horizontal)

                Button(action: {
                    currentPage += 1
                    fetchArticles(for: topic)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }

    private func fetchArticles(for topic: String) {
        let apiKey = "1aef82be99c14df793c0de03cdb26889"
        let urlString = "https://newsapi.org/v2/everything?q=\(topic)&apiKey=\(apiKey)&page=\(currentPage)&pageSize=\(pageSize)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from server."
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from the server."
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.articles = response.articles
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error decoding response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct ArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        ArticlesView(topic: "Technology")
            .environmentObject(ReadArticlesCount())
    }
}
