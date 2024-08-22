//
//  EditViewController.swift
//  TravelTimeCalculator
//
//  Created by Synergy01 on 5.08.24.
//

import UIKit
import CoreData

class EditViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var email: String?
    var user: User?

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.setRounded()
        fetchUserDetails()
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
        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
        emailField.text = user.email
        
        if let imageData = user.imageData {
            profileImageView.image = UIImage(data: imageData)
        } else {
            profileImageView.image = UIImage(named: "profilePlaceholder")
        }
    }
    
    @IBAction func uploadImageTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            present(imagePickerController, animated: true, completion: nil)
            print("image uploaded")
        } else {
            print("Photo library is not available.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let firstNametext = firstNameField.text, !firstNametext.isEmpty,
              let lastNametext = lastNameField.text, !lastNametext.isEmpty,
              let emailText = emailField.text, !emailText.isEmpty else {
            showAlert(message: "First name, last name and email fields can't be empty.")
            return
        }
        let emailRegPatern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "self matches %@", emailRegPatern)
        if !emailPredicate.evaluate(with: emailText) {
            showAlert(message: "Pleae enter a valid email address.")
        }
        if let passwordText = passwordField.text, !passwordText.isEmpty {
            let passwordRegPattern = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
            let passwordPredicate = NSPredicate(format: "self matches %@", passwordRegPattern)
            if !passwordPredicate.evaluate(with: passwordText) {
                showAlert(message: "Password must be at least 8 characters long and contain a letter, a number, and a special character.")
            }
        }
        
        if passwordField.text != confirmPasswordField.text {
            showAlert(message: "Passwords don't match.")
            return
        }
        
        editUser()
        dismiss(animated: true)
    }
    
    func editUser() {
        if let firstNameText = firstNameField.text, firstNameText != user?.firstName {
            user?.firstName = firstNameText
        }
        if let lastNameText = lastNameField.text, lastNameText != user?.lastName {
            user?.lastName = lastNameText
        }
        if let emailText = emailField.text, emailText != user?.email {
            user?.email = emailText
        }
        
        if let passwordText = passwordField.text, !passwordText.isEmpty {
            user?.password = passwordText
        }
        if let image = profileImageView.image {
            let imageData = image.pngData()
            if imageData != user?.imageData {
                user?.imageData = imageData
            } else {
                user?.imageData = nil
            }
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
