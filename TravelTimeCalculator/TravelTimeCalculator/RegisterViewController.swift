//
//  RegisterViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 2.08.24.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if stackView.arrangedSubviews.count > 1 {
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[1])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[3])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[5])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[7])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[9])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[11])
            stackView.setCustomSpacing(20, after: stackView.arrangedSubviews[12])
        }
    }
    
    @IBAction func registerTapped(_ sender: Any) {

        guard let firstNametext = firstNameLabel.text, !firstNametext.isEmpty,
              let lastNametext = lastNameLabel.text, !lastNametext.isEmpty,
              let emailText = emailField.text, !emailText.isEmpty,
              let passwordText = passwordField.text, !passwordText.isEmpty,
              let confirmPasswordText = confirmPasswordField.text, !confirmPasswordText.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }
            
        let emailRegPatern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "self matches %@", emailRegPatern)
        if !emailPredicate.evaluate(with: emailText) {
            showAlert(message: "Pleae enter a valid email address.")
        }
        
        let passwordRegPattern = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "self matches %@", passwordRegPattern)
        if !passwordPredicate.evaluate(with: passwordText) {
            showAlert(message: "Password must be at least 8 characters long and contain a letter, a number, and a special character.")
        }
            
        if passwordField.text != confirmPasswordField.text {
            showAlert(message: "Passwords don't match.")
            return
        }
            
        if let emailTextCheck = emailField.text, isEmailRegistered(email: emailTextCheck) {
            showAlert(message: "This email is already registered.Please use a different one.")
            return
        }
        addUser()
        
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    func isEmailRegistered(email: String) -> Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("failed to fetch user")
            return false
        }
    }
    
    func addUser() {
        let newUser = User(context: context)
        
        newUser.firstName = firstNameLabel.text
        newUser.lastName = lastNameLabel.text
        newUser.email = emailField.text
        newUser.password = passwordField.text
        
        if let placeholderImage = UIImage(named: "profilePlaceholder") {
            newUser.imageData = placeholderImage.pngData()
        }
        
        do {
            try context.save()
            print("user saved")
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            if let destinationVC = segue.destination as? ProfileViewController {
                destinationVC.firstName = firstName
                destinationVC.lastName = lastName
                destinationVC.email = email
                destinationVC.password = password
            }
        }
    }
    
    
    @IBAction func logInTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = loginVC
            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromRight], animations: nil, completion: nil)
        }
    }
}
