//
//  NewsTopicsViewController.swift
//  NewsApp
//
//  Created by Synergy01 on 25.07.24.
//

import UIKit

class NewsTopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var BarButton: UIBarButtonItem!
    
    let topics = ["Business", "Technology", "Sports", "Entertainment", "General Health", "Science"]
    var totalReadArticles = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadReadArticlesCount()
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(readArticlesCountUpdated), name: Notification.Name("ReadArticlesCountUpdated"), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ReadArticlesCountUpdated"), object: nil)
    }
    
    func loadReadArticlesCount() {
        totalReadArticles = UserDefaults.standard.integer(forKey: "totalReadArticles")
        updateBarButton()
    }

    func updateBarButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.setTitle(" \(totalReadArticles)", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(showReadCount(_:)), for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @IBAction func showReadCount(_ sender: UIBarButtonItem) {
        let popoverContent = UIViewController()
        let label = UILabel()
        label.text = "Total number of read articles: \(totalReadArticles)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        popoverContent.view = label
        popoverContent.preferredContentSize = CGSize(width: 200, height: 50)
        popoverContent.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContent.popoverPresentationController {
            popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.delegate = self
        }
        present(popoverContent, animated: true, completion: nil)
    }
    
    @objc func readArticlesCountUpdated() {
        loadReadArticlesCount()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath)
        cell.textLabel?.text = topics[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt called for row \(indexPath.row): \(topics[indexPath.row])")
        let topic = topics[indexPath.row]
        performSegue(withIdentifier: "ShowArticles", sender: topic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue .identifier == "ShowArticles" {
            if let destinationVC = segue.destination as? ArticlesViewController {
                if let topic = sender as? String {
                    destinationVC.topic = topic
                }
            }
        }
    }
}

