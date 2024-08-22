//
//  DetailsViewController.swift
//  NewsApp
//
//  Created by Synergy01 on 26.07.24.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var openButton: UIButton!
    
    var article: Article?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        guard let article = article else { return }
        
        titleLabel.text = article.title
        contentLabel.text = article.content
        
        if let urlToImage = article.urlToImage, let url = URL(string: urlToImage) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }.resume()
        }
        
        openButton.addTarget(self, action: #selector(openButtonTapped), for: .touchUpInside)
    }

    @objc func openButtonTapped() {
        guard let urlString = article?.url, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

