//
//  VacationDetailsViewController.swift
//  DesiredVacation
//
//  Created by Synergy01 on 29.07.24.
//

import UIKit

class VacationDetailsViewController: UIViewController {

    var vacation: DesiredVacation?
    @IBOutlet weak var vacNameL: UILabel!
    @IBOutlet weak var hotelNameL: UILabel!
    @IBOutlet weak var locationL: UILabel!
    @IBOutlet weak var moneyL: UILabel!
    @IBOutlet weak var descL: UILabel!
    @IBOutlet weak var vacImageV: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vacNameL.text = "Vacation name: \(vacation?.name ?? "")"
        hotelNameL.text = "Hotel name: \(vacation?.hotelName ?? "")"
        locationL.text = "Location: \(vacation?.location ?? "")"
        moneyL.text = "Money needed: \(vacation?.necessryMoneyAmount ?? 0.0)"
        descL.text = "Description: \(vacation?.vcationDescription ?? "")"
        
        vacImageV.image = UIImage(data: (vacation?.imageData)!)
    }
    
    @IBAction func EditButtonClick(_ sender: Any) {
        if let vacation = vacation {
            print("Performing segue with vacation: \(vacation)")
            print("Vacation type: \(type(of: vacation))")
            performSegue(withIdentifier: "toEditVacation", sender: vacation)
        } else {
            print("vacation is nil or not of type DesiredVacation")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditVacation" {
            if let destinationVC = segue.destination as? EditVacationViewController {
                if let selectedVacation = sender as? DesiredVacation {
                    destinationVC.vacation = selectedVacation
                } else {
                    print("Sender is not a DesiredVacation object: \(String(describing: sender))")
                }
            } else {
                print("Destination is not EditVacationViewController")
            }
        } else {
            print("Segue identifier is not toEditVacation")
        }
    }
}
