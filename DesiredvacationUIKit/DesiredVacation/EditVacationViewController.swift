//
//  EditVacationViewController.swift
//  DesiredVacation
//
//  Created by Synergy01 on 29.07.24.
//

import UIKit

class EditVacationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var vacation: DesiredVacation?
    
    @IBOutlet weak var vacationNameText: UITextField!
    @IBOutlet weak var hotelNameText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var moneyNeededText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var vacImageView: UIImageView!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Vacation object in viewDidLoad: \(String(describing: vacation))")
        print("Vacation name: \(String(describing: vacation?.name))")
        print("Vacation hotelName: \(String(describing: vacation?.hotelName))")
        print("Vacation location: \(String(describing: vacation?.location))")
        print("Vacation necessary money amount: \(String(describing: vacation?.necessryMoneyAmount))")
        print("Vacation description: \(String(describing: vacation?.vcationDescription))")
        print("Vacation image data: \(String(describing: vacation?.imageData))")
        
        vacationNameText.text = vacation?.name
        hotelNameText.text = vacation?.hotelName
        locationText.text = vacation?.location
        moneyNeededText.text = "\(vacation?.necessryMoneyAmount ?? 0.0)"
        descriptionText.text = vacation?.vcationDescription
              
        if let imageData = vacation?.imageData {
            vacImageView.image = UIImage(data: imageData)
        } else {
            vacImageView.image = nil
        }
    }
    
    @IBAction func selectImageButtonClick(_ sender: Any) {
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
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        editVacation()
        navigationController?.popViewController(animated: true)
    }
    
    func editVacation()
    {
        vacation?.name = vacationNameText.text
        vacation?.hotelName = hotelNameText.text
        vacation?.location = locationText.text
        vacation?.necessryMoneyAmount = Double(moneyNeededText.text!) ?? 0.0
        vacation?.vcationDescription = descriptionText.text
        
        if let image = vacImageView.image {
            vacation?.imageData = image.pngData()
        } else {
            vacation?.imageData = nil
        }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
