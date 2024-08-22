//
//  ArticleDetailsView.swift
//  NewsApp
//
//  Created by Synergy01 on 17.07.24.
//

import SwiftUI

struct ArticleDetailsView: View {
    let article: Article
    @EnvironmentObject var readArticlesCount: ReadArticlesCount

    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                Text(article.title)
                    .font(.largeTitle)
                    .padding(.bottom)
                if let urlToImage = article.urlToImage, let url = URL (string: urlToImage) {
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
                Text(article.description ?? "No descriprion")
                    .padding(.vertical)
                Button(action: {
                    if let url = URL (string: article.url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open in web")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("ArticleDetails")
        .onAppear() {
            incrementCount()
        }
    }
    
    private func incrementCount() {
        readArticlesCount.count += 1
    }
}

struct ArticleDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleDetailsView(article: .sampleArticle)
            .environmentObject(ReadArticlesCount())
    }
}
