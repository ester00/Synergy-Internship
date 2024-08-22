//
//  ResultViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 30.07.24.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var fuelNeededLabel: UILabel!
    @IBOutlet weak var additionalFuelLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var transportation: String?
    var travelTime: Double?
    var fuelNeeded: Double?
    var isFuelEnough: Bool?
    var fuelLevel: Double?
    var arrivalTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateFieldVisibility()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") {
            saveButton.isHidden = false
        } else {
            saveButton.isHidden = true
        }
    }
    
    func updateUI() {
        guard let transportation = transportation else {return}
        
        switch transportation {
        case "Vehicle":
            travelTimeLabel.text = "Travel time: \(formatTime(travelTime ?? 0))"
            if let fuelNeeded = fuelNeeded {
                fuelNeededLabel.text = "Fuel Needed: \(fuelNeeded) liters"
                if let isFuelEnough = isFuelEnough {
                    additionalFuelLabel.text = isFuelEnough ? "You have enough fuel to reach your destination." : "You need additional \(fuelNeeded - (fuelLevel ?? 0)) liters to reach your destination."
                }
            }
        case "Bike":
            travelTimeLabel.text = "Travel time: \(formatTime(travelTime ?? 0))"
        case "Walking":
            travelTimeLabel.text = "Travel time: \(formatTime(travelTime ?? 0))"
        default:
            break
        }
        if let arrivalTime = arrivalTime {
            arrivalTimeLabel.text = "Arrival Time: \(formatArrivalTime(arrivalTime))"
        }
    }
    
    func formatTime(_ timeInHours: Double) -> String {
        let hours = Int(timeInHours)
        let minutes = Int((timeInHours - Double(hours)) * 60)
        return "\(hours) hour\(hours != 1 ? "s" : "") and \(minutes) minute\(minutes != 1 ? "s" : "")"
    }
    
    func formatArrivalTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func updateFieldVisibility() {
        print("Transportation type: \(transportation ?? "nil")")

        switch transportation {
        case "Vehicle":
            travelTimeLabel.isHidden = false
            fuelNeededLabel.isHidden = false
            additionalFuelLabel.isHidden = false
        case "Bike":
            travelTimeLabel.isHidden = false
            fuelNeededLabel.isHidden = true
            additionalFuelLabel.isHidden = true
        case "Walking":
            travelTimeLabel.isHidden = false
            fuelNeededLabel.isHidden = true
            additionalFuelLabel.isHidden = true
        default:
            break
        }
    }
    
    @IBAction func okClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTripClicked(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") {
            performSegue(withIdentifier: "showSaveTrip", sender: self)
        } else {
            let alert = UIAlertController(title: "Not logged in", message: "You need to be logged in to save trips.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSaveTrip" {
            if let destinationVC = segue.destination as? SaveTripViewController {
                destinationVC.transportation = transportation
                destinationVC.travelTime = travelTime
                destinationVC.fuelNeeded = fuelNeeded
                destinationVC.fuelNeeded = fuelNeeded
                destinationVC.isFuelEnough = isFuelEnough
                destinationVC.fuelLevel = fuelLevel
                
                destinationVC.modalPresentationStyle = .pageSheet
                if let presentationController = destinationVC.presentationController as? UISheetPresentationController {
                    presentationController.detents = [.medium()]
                    presentationController.preferredCornerRadius = 25
                }
            }
        }
    }
}
