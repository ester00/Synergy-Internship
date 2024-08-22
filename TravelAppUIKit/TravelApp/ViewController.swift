//
//  ViewController.swift
//  TravelApp
//
//  Created by Synergy01 on 18.07.24.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableViewVC: UITableView!
    
    var cities: [City] = []
    var selectedCity: City?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableViewVC.delegate = self
        TableViewVC.dataSource = self
        fetchCities()
    }
    
    func fetchCities() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<City>(entityName: "City")
        
        do {
            cities = try managedContext.fetch(fetchRequest)
            TableViewVC.reloadData()
        } catch {
            print("Failed to fetch cities: \(error.localizedDescription)")
        }
    }
    
    @IBAction func addOnTap(_ sender: UIBarButtonItem) {
        let textFieldIndexPath = IndexPath(row: 1, section: 0)
        guard let textFieldCell = TableViewVC.cellForRow(at: textFieldIndexPath) as? TextFieldTableViewCell,
              let cityName = textFieldCell.cityNameTextField.text, !cityName.isEmpty else {
            showAlert(message: "City name can't be empty")
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to retrieve AppDelegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let city = City(context: managedContext)
        city.name = cityName
        
        do {
            try managedContext.save()
            cities.append(city)
            TableViewVC.reloadData()
            textFieldCell.cityNameTextField.text = ""
        } catch {
            print("Failed to save city")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            return cell
        } else if indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as? TextFieldTableViewCell else {
                return UITableViewCell()
            }
            return cell
        } else {
            let cityIndex = indexPath.row - 2
            let city = cities[cityIndex]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
            cell.textLabel?.text = city.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cityIndex = indexPath.row - 2
            
            if cityIndex >= 0 && cityIndex < cities.count {
                let city = cities[cityIndex]
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    fatalError("unable to retrieve appDelegate")
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                managedContext.delete(city)
                
                do {
                    try managedContext.save()
                    cities.remove(at: cityIndex)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } catch {
                    print("failed to delete city: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityIndex = indexPath.row - 2
        guard cityIndex >= 0 && cityIndex < cities.count else {
            return
        }
        
        selectedCity = cities[cityIndex]
        performSegue(withIdentifier: "showLandmarkView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLandmarkView" {
            if let destinationVC = segue.destination as? LandmarkViewController {
                destinationVC.selectedCity = selectedCity
            }
        }
    }
}
