//
//  ProfileViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 2.08.24.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var pulldownButton: UIButton!
    
    var trips: [Trip] = []
    var user: User?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchedResultsController: NSFetchedResultsController<Trip>!
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        
        let nib = UINib(nibName: "tripTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "tripTableViewCell")
        
        let editAction = UIAction(title: "Edit Profile", image: UIImage(systemName: "pencil")) { action in
            self.performSegue(withIdentifier: "showEdit", sender: self)
        }
        let logoutAction = UIAction(title: "Logout", image: UIImage(systemName: "rectangle.portrait.and.arrow.right")) { action in
            self.logout()
        }
        
        let menu = UIMenu(title: "", children: [editAction, logoutAction])
        
        pulldownButton.menu = menu
        pulldownButton.showsMenuAsPrimaryAction = true
        
        imagePreview.setRounded()
        fetchUserDetails()
        fetchTripsForLoggedInUser()
    }
        
    func fetchUserDetails() {
        guard let email = email else {
            print("User not found.")
            return
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                displayUserDetails(user)
            }
        } catch {
            print("Failed to fetch user details: \(error.localizedDescription)")
        }
    }
    
    func displayUserDetails(_ user: User) {
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        
        if let imageData = user.imageData {
            imagePreview.image = UIImage(data: imageData)
        } else {
            imagePreview.image = UIImage(named: "profilePlaceholder")
        }
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
    
    func fetchTripsForLoggedInUser() {
        guard let loggedInUser = fetchLoggedInUser() else {
            print("No logged-in user found")
            return
        }
        
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", loggedInUser)
        
        do {
            let fetcheTrips = try context.fetch(fetchRequest)
            print("Fetched trips: \(fetcheTrips.count)")
            trips = fetcheTrips
            tableView.reloadData()
        } catch {
            print("Failed to fetch trips: \(error.localizedDescription)")
        }
    }

    func appendTrip(_ trip: Trip) {
        trips.append(trip)
        tableView.reloadData()
    }
    
    func logout() {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        
        if !UserDefaults.standard.bool(forKey: "rememberMeSelected") {
            UserDefaults.standard.removeObject(forKey: "userEmail")
            if let email = UserDefaults.standard.string(forKey: "userEmail") {
                KeychainHelper.delete(service: "com.yourapp.service", account: email)
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tripTableViewCell", for: indexPath) as? tripTableViewCell else {
            fatalError("The dequeued cell is not an instance of tripTableViewCell")
        }
        let trip = trips[indexPath.row]
        cell.tripNameLabel?.text = trip.name
        cell.destinationLabel?.text = trip.destination
        
        print("Name: \(trip.name ?? "No Name")")
        print("Destination: \(trip.destination ?? "no destination")")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteTrip(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTripDetails", sender: trips[indexPath.row])
    }
    
    private func deleteTrip(at indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        context.delete(trip)
        
        do {
            try context.save()
            trips.remove(at: indexPath.row)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEdit" {
            if let destinationVC = segue.destination as? EditViewController {
                destinationVC.email = self.email
            }
        } else if segue.identifier == "showTripDetails" {
            if let destVC = segue.destination as? tripDetailsViewController {
                if let selectedTrip = sender as? Trip {
                    destVC.trip = selectedTrip
                    
                    destVC.modalPresentationStyle = .pageSheet
                    if let presentationController = destVC.presentationController as? UISheetPresentationController {
                        presentationController.detents = [.medium()]
                        presentationController.preferredCornerRadius = 25
                    }
                }
            }
        }
    }
    
}
extension UIImageView {

   func setRounded() {
      let radius = CGRectGetWidth(self.frame) / 2
      self.layer.cornerRadius = radius
      self.layer.masksToBounds = true
   }
}
