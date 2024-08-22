//
//  ContentView.swift
//  NewsApp
//
//  Created by Synergy01 on 17.07.24.
//

import SwiftUI
import CoreData


struct NewsTopicsView: View {
    @StateObject private var readArticlesCount = ReadArticlesCount()
    @State private var showPopover = false
    
    let topics = ["Business", "Technology", "Sports", "Entertainment", "General Health", "Science"]
    
    var body: some View {
        NavigationView {
            List(topics, id: \.self) { topic in
                NavigationLink(destination: ArticlesView(topic: topic).environmentObject(readArticlesCount)) {
                    Text(topic)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Text("News Topics")
                        .font(.title)
                        .padding(.all)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showPopover = true
                    }) {
                        HStack {
                            Image(systemName: "eye")
                            Text("\(readArticlesCount.count)")
                        }
                    }
                    .popover(isPresented: $showPopover, arrowEdge: .top) {
                        Text("Total number of read articles: \(readArticlesCount.count)")                            .presentationCompactAdaptation((.popover))
                            .padding()
                    }
                }
            }
        }
    }
}

struct NewsTopicsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsTopicsView()
            .environmentObject(ReadArticlesCount())
    }
}

