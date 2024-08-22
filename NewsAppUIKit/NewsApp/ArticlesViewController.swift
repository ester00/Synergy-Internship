//
//  ArticlesViewController.swift
//  NewsApp
//
//  Created by Synergy01 on 25.07.24.
//

import UIKit

class ArticlesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var topic: String!
    var articles: [Article] = []
    var currentPage = 1
    var isLoading = false
    var totalResults = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 150
        
        fetchArticles(page: currentPage)
    }
    
    func fetchArticles(page: Int, pageSize: Int = 10) {
        print("Fetching articles for page: \(page)")
        let apiKey = "9af5edb69232441daf34f25c997ae5d1"
        let urlString = "https://newsapi.org/v2/everything?q=\(String(describing: topic))&page=\(page)&pageSize=\(pageSize)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                print("Invalid URL")
            }
            return
        }
        
        isLoading = true
        updatePageControl()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Failed to fetch articles: \(error.localizedDescription)")
                    self.isLoading = false
                    self.updatePageControl()
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data returned.")
                    self.isLoading = false
                    self.updatePageControl()
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                self.totalResults = response.totalResults
                self.articles = response.articles
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.isLoading = false
                    self.updatePageControl()
                    
                    if !self.articles.isEmpty {
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error decoding JSON: \(error.localizedDescription)")
                    self.isLoading = false
                    self.updatePageControl()
                }
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < articles.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
            let article = articles[indexPath.row]
            
            cell.titleLabel.text = article.title
            
            if let urlToImage = article.urlToImage, let url = URL(string: urlToImage) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data else { return }
                    DispatchQueue.main.async {
                        cell.imagePreview.image = UIImage(data: data)
                        cell.setNeedsLayout()
                    }
                }.resume()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PageCell", for: indexPath) as! PageTableViewCell
            cell.pageNumberLabel.text = "Page \(currentPage)"
            cell.previousPageButton.isEnabled = currentPage > 1
            cell.nextPageButton.isEnabled = !isLoading && (articles.count == 10)
            
            cell.previousPageButton.addTarget(self, action: #selector(previousPage(_:)), for: .touchUpInside)
            cell.nextPageButton.addTarget(self, action: #selector(nextPage(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < articles.count {
            let article = articles[indexPath.row]
            performSegue(withIdentifier: "ShowDetails", sender: article)
            incrementReadArticlesCount()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            if let destinationVC = segue.destination as? DetailsViewController {
                if let article = sender as? Article {
                    destinationVC.article = article
                }
            }
        }
    }
    
    func incrementReadArticlesCount() {
        let defaults = UserDefaults.standard
        var readArticlesCount = defaults.integer(forKey: "totalReadArticles")
        readArticlesCount += 1
        defaults.set(readArticlesCount, forKey: "totalReadArticles")
        
        NotificationCenter.default.post(name: Notification.Name("ReadArticlesCountUpdated"), object: nil)
    }
    
    @objc func nextPage(_ sender: UIButton) {
        if !isLoading && (articles.count == 10) {
            currentPage += 1
            fetchArticles(page: currentPage)
        }
    }
    
    @objc func previousPage(_ sender: UIButton) {
        if !isLoading && currentPage > 1 {
            currentPage -= 1
            fetchArticles(page: currentPage)
        }
    }
    
    func updatePageControl() {
        guard let pageCell = tableView.cellForRow(at: IndexPath(row: articles.count, section: 0)) as? PageTableViewCell else { return }
        pageCell.pageNumberLabel.text = "Page \(currentPage)"
        pageCell.previousPageButton.isEnabled = currentPage > 1
        pageCell.nextPageButton.isEnabled = !isLoading && (articles.count == 10)
    }
}
