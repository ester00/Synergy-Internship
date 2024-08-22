//
//  VacationCreationViewController.swift
//  DesiredVacation
//
//  Created by Synergy01 on 29.07.24.
//

import UIKit

class VacationCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var vacNameTV: UITextField!
    @IBOutlet weak var hotelNameTV: UITextField!
    @IBOutlet weak var locationTV: UITextField!
    @IBOutlet weak var moneyNeededTV: UITextField!
    @IBOutlet weak var descriptionTV: UITextField!
    @IBOutlet weak var vacImageView: UIImageView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectImageButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            present(imagePickerController, animated: true, completion: nil)
        } else {
            print("Photo library is not available.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Image selected")
        if let selectedImage = info[.originalImage] as? UIImage {
            vacImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker canceled")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveVacationButton(_ sender: Any) {
        guard let vacationName = vacNameTV.text, !vacationName.isEmpty,
              let hotelName = hotelNameTV.text, !hotelName.isEmpty,
              let location = locationTV.text, !location.isEmpty,
              let moneyNeeded = moneyNeededTV.text, !moneyNeeded.isEmpty,
              let description = descriptionTV.text, !description.isEmpty,
              vacImageView.image != nil else {
            
            showAlert(message: "Fields can't be empty and an image mus be selected")
            return
        }

        addVacation()
        _ = navigationController?.popViewController(animated: true)
        print("save button pressed")
    }
    
    func addVacation() {
        let newVacation = DesiredVacation(context: context)
        
        newVacation.name = vacNameTV.text
        newVacation.hotelName = hotelNameTV.text
        newVacation.location = locationTV.text
        newVacation.necessryMoneyAmount = Double(moneyNeededTV.text!) ?? 0.0
        newVacation.vcationDescription = descriptionTV.text
        
        newVacation.imageData = vacImageView.image?.pngData()
        
        do {
            try context.save()
            print("vacation saved")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
