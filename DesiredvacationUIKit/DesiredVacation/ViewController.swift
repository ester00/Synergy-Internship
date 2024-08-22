//
//  ViewController.swift
//  DesiredVacation
//
//  Created by Synergy01 on 25.07.24.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {


    var vacations: [DesiredVacation] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController: NSFetchedResultsController<DesiredVacation>!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "All Vacations"
        
        let nib = UINib(nibName: "VacationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "VacationTableViewCell")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchVacations()
        
        print(vacations.count)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vacations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vacation = vacations[indexPath.row] 
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VacationTableViewCell", for: indexPath) as? VacationTableViewCell else {
            fatalError("The dequeued cell is not an instance of VacationTableViewCell.")
        }
        
        cell.vacationNameLabel?.text = vacation.name
        cell.vacationLocationLabel?.text = vacation.location
        if let imageData = vacation.imageData {
            cell.vacationImageView?.image = UIImage(data: imageData)
        } else {
            cell.vacationImageView.image = nil
        }
        
        print("Name: \(vacation.name ?? "No Name")")
        print("Location: \(vacation.location ?? "no location")")
        print("Image data exists: \(vacation.imageData != nil)")

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            deleteVacation(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "toVacationDetails", sender: vacations[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVacationDetails"
        {
            if let destinationVC = segue.destination as? VacationDetailsViewController{
                if let selectedVacation = sender as? DesiredVacation{
                    destinationVC.vacation = selectedVacation
                }
            }
        }
    }
    
    
    @IBAction func notificationButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toNotifications", sender: nil)
    }
    
    private func fetchVacations()
    {
        let fetchRequest: NSFetchRequest<DesiredVacation> = DesiredVacation.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                vacations = fetchedObjects
                }
            print("Fetched \(vacations.count) vacations")
            } catch {
                print("Failed to fetch objects: \(error)")
            }
    }
    
    private func deleteVacation(at indexPath: IndexPath) {
        let vacation = vacations[indexPath.row]
        context.delete(vacation)
        
        do {
            try context.save()
            vacations.remove(at: indexPath.row)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

