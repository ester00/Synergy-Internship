//
//  TestDetailViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 31.07.24.
//

import UIKit

class TestDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var speedField: UITextField!
    @IBOutlet weak var fuelLevelField: UITextField!
    @IBOutlet weak var fuelConsumptionField: UITextField!
    @IBOutlet weak var breakDurationLabel: UILabel!
    @IBOutlet weak var breakStepper: UIStepper!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var terrainLabel: UILabel!
    @IBOutlet weak var terrainPicker: UIPickerView!
    let terrainType: [TerrainType] = [.flat, .downhill, .uphill]
    var selectedTerrainType: TerrainType = .flat
    var transportation: String!
    var breakDuration: Int = 0
    var travelTime: Double?
    var fuelNeeded: Double?
    var isFuelEnough: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        terrainPicker.delegate = self
        terrainPicker.dataSource = self
        distanceField.delegate = self
        speedField.delegate = self
        fuelLevelField.delegate = self
        fuelConsumptionField.delegate = self
        
        updateFieldVisibility()
        breakDurationLabel.text = "\(breakDuration) min"
    }
    
    func updateFieldVisibility() {
        switch transportation {
        case "Vehicle":
            distanceField.isHidden = false
            speedField.isHidden = false
            fuelLevelField.isHidden = false
            fuelConsumptionField.isHidden = false
            terrainLabel.isHidden = true
            terrainPicker.isHidden = true
        case "Bike":
            distanceField.isHidden = false
            speedField.isHidden = false
            terrainLabel.isHidden = false
            terrainPicker.isHidden = false
            fuelLevelField.isHidden = true
            fuelConsumptionField.isHidden = true
        case "Walking":
            distanceField.isHidden = false
            speedField.isHidden = false
            fuelLevelField.isHidden = true
            fuelConsumptionField.isHidden = true
            terrainLabel.isHidden = true
            terrainPicker.isHidden = true
        
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharachters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharachters.isSuperset(of: characterSet) {
            return false
        }
        if string == "." {
            if textField.text?.contains(".") == true {
                return false
            }
        }
        return true
    }
    
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let breakDuration = Int(sender.value)
        breakDurationLabel.text = "\(breakDuration) min"
        self.breakDuration = breakDuration
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return terrainType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return terrainType[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTerrainType = terrainType[row]
        print("terrain type: \(selectedTerrainType)")
    }
    
    @IBAction func calculateButton(_ sender: Any) {
        guard let distanceText = distanceField.text, let distance = Double(distanceText), distance > 0 else {
            showAlert(message: "Please enter a valid value for distance.")
            return
        }
              
        guard let speedText = speedField.text, let speed = Double(speedText), speed > 0 else {
            showAlert(message: "Please enter a valid value for speed.")
            return
        }
        
        var fuelLevel: Double? = nil
        var fuelConsumptionRate: Double? = nil
        
        if transportation == "Vehicle" {
            guard let fuelLevelText = fuelLevelField.text, let fuelLevelValue = Double(fuelLevelText), fuelLevelValue > 0 else {
                showAlert(message: "Please enter a valid value for fuel level.")
                return
            }
            guard let fuelConsumptionRateText = fuelConsumptionField.text, let fuelConsumptionValue = Double(fuelConsumptionRateText), fuelConsumptionValue > 0 else {
                showAlert(message: "Please enter a valid value for fuel consumption.")
                return
            }
            fuelLevel = fuelLevelValue
            fuelConsumptionRate = fuelConsumptionValue
        }
                
        switch transportation {
        case "Vehicle":
            let vehicle = Vehicle(speed: speed, fuelConsumptionRate: fuelConsumptionRate!, fuelLevel: fuelLevel!, startTime: timePicker.date, stopDuration: [Double(breakDuration)])
            travelTime = vehicle.calculateTime(to: distance)
            
            let fuelCheck = vehicle.isFuelEnough(for: distance)
            fuelNeeded = round(fuelCheck.requiredFuel * 100) / 100
            isFuelEnough = fuelCheck.isEnough
            
        case "Bike":
            let bike = Bike(speed: speed, startTime: timePicker.date, stopDuration: [Double(breakDuration)])
            bike.terrainType = selectedTerrainType
            travelTime = bike.calculateTime(to: distance)
        case "Walking":
            let walking = Walking(speed: speed, startTime: timePicker.date, stopDuration: [Double(breakDuration)])
            travelTime = walking.calculateTime(to: distance)
        default:
            break
        }
        
        let arrivalTime = Calendar.current.date(byAdding: .minute, value: Int(travelTime! * 60), to: timePicker.date)
        
        performSegue(withIdentifier: "showPopoverView", sender: (transportation, travelTime, fuelNeeded, isFuelEnough, fuelLevel, arrivalTime))
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPopoverView" {
            segue.destination.preferredContentSize = CGSize(width: 300, height: 400)
            if let presentationController = segue.destination.popoverPresentationController {
                presentationController.delegate = self
            }
            if let destinationVC = segue.destination as? ResultViewController {
                
                if let (transportation, travelTime, fuelNeeded, isFuelEnough, fuelLevel, arrivalTime) = sender as? (String?, Double?, Double?, Bool?, Double?, Date?) {
                    destinationVC.transportation = transportation
                    destinationVC.travelTime = travelTime
                    destinationVC.fuelNeeded = fuelNeeded
                    destinationVC.isFuelEnough = isFuelEnough
                    destinationVC.fuelLevel = fuelLevel
                    destinationVC.arrivalTime = arrivalTime
                }
            }
        }
    }
}

extension TestDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection trairCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
