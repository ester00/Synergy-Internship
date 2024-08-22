//
//  tripDetailsViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 5.08.24.
//

import UIKit

class tripDetailsViewController: UIViewController {

    var trip: Trip?
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var transportationLabel: UILabel!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var fuelNeededLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tripNameLabel.text = "Trip name: \(trip?.name ?? "")"
        destinationLabel.text = "Destination: \(trip?.destination ?? "")"
        transportationLabel.text = "Transportation: \(trip?.transportation ?? "")"
        travelTimeLabel.text = "Travel time: \(formatTime(trip?.travelTime ?? 00))"
        fuelNeededLabel.text = "Fuel needed: \(trip?.fuelNeeded ?? 00) liters"
        arrivalTimeLabel.text = "Arrival time: \(formatArrivalTime(trip?.arrivalTime ?? Date()))"
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

    func updateVisibility() {
        guard let transportation = trip?.transportation else {return}
        
        switch transportation {
        case "Vehicle":
            fuelNeededLabel.isHidden = false
        case "Bike":
            fuelNeededLabel.isHidden = true
        case "Walking":
            fuelNeededLabel.isHidden = true
        default:
            break
        }
    }
}
