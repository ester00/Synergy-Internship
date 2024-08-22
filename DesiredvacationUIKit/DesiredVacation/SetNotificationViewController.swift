//
//  SetNotificationViewController.swift
//  DesiredVacation
//
//  Created by Synergy01 on 29.07.24.
//

import UIKit
import UserNotifications


class SetNotificationViewController: UIViewController {

    @IBOutlet weak var notifNameText: UITextField!
    @IBOutlet weak var notifDescText: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if let error = error {
                    print("Request Authorization Failed: \(error)")
                }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        guard let notifName = notifNameText.text, !notifName.isEmpty,
              let notifDesc = notifDescText.text, !notifDesc.isEmpty else {
            
            showAlert(message: "Notification name and description can't be empty")
            return
        }
                
        let content = UNMutableNotificationContent()
        content.title = notifName
        content.subtitle = notifDesc
        content.sound = .default
        
        let date = timePicker.date
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to add notification: \(error)")
                } else {
                    print("Notification scheduled for \(date)")
                    self.dismissViewController()
                }
            }
        }
    }
    
    private func dismissViewController() {
        print("Dismissing view controller")
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
