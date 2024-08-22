//
//  ViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 30.07.24.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let transportation = ["Vehicle", "Bike", "Walking"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transportation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transportCell", for: indexPath)
        cell.textLabel?.text = transportation[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transportation = transportation[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: transportation)
    }
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showLogIn", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let destinationVC = segue.destination as? TestDetailViewController {
                if let transportation = sender as? String {
                    destinationVC.transportation = transportation
                }
            }
        }
        if segue.identifier == "showLogIn" {
            
        }
    }
    
}

