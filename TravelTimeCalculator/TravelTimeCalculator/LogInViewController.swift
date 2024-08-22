//
//  LogInViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 2.08.24.
//

import UIKit
import CoreData

class LogInViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rememberMeButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if stackView.arrangedSubviews.count > 1 {
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[1])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[3])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[6])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[7])
        }
        
        let smallConfig = UIImage.SymbolConfiguration(scale: .small)
        
        let uncheckedImage = UIImage(systemName: "circle", withConfiguration: smallConfig)
        let checkedImage = UIImage(systemName: "checkmark.circle", withConfiguration: smallConfig)
        
        rememberMeButton.isSelected = false
        
        rememberMeButton.setImage(uncheckedImage, for: .normal)
        rememberMeButton.setImage(checkedImage, for: .selected)
        
        prefillFields()
    }
    
    func prefillFields() {
        if let savedEmail = UserDefaults.standard.string(forKey: "userEmail"), UserDefaults.standard.bool(forKey: "rememberMeSelected") {
            emailField.text = savedEmail
            rememberMeButton.isSelected = true
            
            if let passwordData = KeychainHelper.load(service: "com.yourapp.service", account: savedEmail),
               let savedPassword = String(data: passwordData, encoding: .utf8) {
                passwordField.text = savedPassword
            }
        } else {
            print("No saved credentials found")
        }
    }
    
    @IBAction func logInPressed(_ sender: Any) {
        let users = User(context: context)
        
        guard let emailText = emailField.text, !emailText.isEmpty,
              let passwordText = passwordField.text, !passwordText.isEmpty else {
            showAlert(message: "Email and Password fields can't be empty.")
            return
        }
        logIn(email: emailText, password: passwordText)
        
    }
    
    func logIn(email: String, password: String) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)
        
        do {
            let users = try context.fetch(fetchRequest)
            if users.count > 0 {
                print("Log in successful.")
                
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.set(email, forKey: "userEmail")
                
                UserDefaults.standard.set(rememberMeButton.isSelected, forKey: "rememberMeSelected")
                
                if rememberMeButton.isSelected {
                    let passwordData = password.data(using: .utf8)!
                    KeychainHelper.save(service: "com.yourapp.service", account: email, data: passwordData)
                } else {
                    KeychainHelper.delete(service: "com.yourapp.service", account: email)
                }
                print("Performing segue to ProfileViewController \(email) and password: \(password)")
                performSegue(withIdentifier: "showProfile", sender: (email, password))
            } else {
                print("Invalid email or password.")
                showAlert(message: "Invalid email or password.")
            }
        } catch {
            print("Failed to fetch user: \(error)")
            showAlert(message: "An error occurred. Please try again.")
        }
    }

    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func rememberMeBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            print("Remember Me selected")
        } else {
            print("Remember Me deselected")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            if let destinationVC = segue.destination as? ProfileViewController {
                print("Destination view controller cast successful")
                if let credentials = sender as? (String, String) {
                    print("Passing email and password to ProfileViewController")
                    destinationVC.email = credentials.0
                    destinationVC.password = credentials.1
                }
            }
        }
    }
    
    
}
