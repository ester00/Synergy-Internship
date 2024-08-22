//
//  SaveTripViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 2.08.24.
//

import UIKit
import CoreData

class SaveTripViewController: UIViewController {

    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var tripDestinationLabel: UITextField!
    
    @IBOutlet weak var stackView: UIStackView!
    var transportation: String?
    var travelTime: Double?
    var fuelNeeded: Double?
    var fuelLevel: Double?
    var isFuelEnough: Bool?
    var arrivalTime: Date?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        print("Transportation in SaveTripViewController: \(String(describing: transportation))")
         print("Travel Time in SaveTripViewController: \(String(describing: travelTime))")
         print("Fuel Needed in SaveTripViewController: \(String(describing: fuelNeeded))")
         print("Fuel Level in SaveTripViewController: \(String(describing: fuelLevel))")
         print("Is Fuel Enough in SaveTripViewController: \(String(describing: isFuelEnough))")
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let nameText = tripNameField.text, !nameText.isEmpty,
        let destination = tripDestinationLabel.text, !destination.isEmpty else {
            showAlert(message: "Trip name and destination can't be empty.")
            return
        }
        addTrip()
        dismiss(animated: true)

    }
    
    func fetchLoggedInUser() -> User? {
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else {
            print("No logged-in user found")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Failed to fetch logged-in user: \(error.localizedDescription)")
            return nil
        }
    }

    
    func addTrip() {
        
        guard let loggedInUser = fetchLoggedInUser() else {
            print("No logged-in user, cannot save trip")
            return
        }
        
        let newTrip = Trip(context: context)
        newTrip.name = tripNameField.text
        newTrip.destination = tripDestinationLabel.text
        newTrip.transportation = transportation
        newTrip.travelTime = travelTime ?? 0
        newTrip.fuelNeeded = fuelNeeded ?? 0
        newTrip.fuelLevel = fuelLevel ?? 0
        newTrip.isFuelEnough = isFuelEnough ?? false
        newTrip.arrivalTime = arrivalTime
        
        newTrip.user = loggedInUser
        
        do {
            try context.save()
            
            if let profileVC = navigationController?.viewControllers.first(where: { $0 is ProfileViewController }) as? ProfileViewController {
                profileVC.appendTrip(newTrip)
            }
            
            navigationController?.popViewController(animated: true)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
