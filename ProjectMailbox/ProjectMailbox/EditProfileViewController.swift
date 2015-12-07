//
//  EditProfileViewController.swift
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/6/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }
    
    @IBAction func changePhotoButtonTapped(sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.contentMode = .ScaleAspectFit
            profileImageView.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        if let currentUser = PFUser.currentUser() {
            if ((firstNameField.text?.isEmpty) == false) {
                currentUser["First_Name"] = firstNameField.text
                currentUser.saveInBackground()
            }
            if ((lastNameField.text?.isEmpty) == false) {
                currentUser["Last_Name"] = lastNameField.text
                currentUser.saveInBackground()
            }
            if ((emailField.text?.isEmpty) == false) {
                currentUser["email"] = emailField.text
                currentUser.saveInBackground()
            }
            if (profileImageView.image != nil) {
                
                let profileImageData = UIImageJPEGRepresentation(profileImageView.image!, 1)
                
                let profileImageObject = PFFile(data:profileImageData!)
                currentUser.setObject(profileImageObject!, forKey: "profileImage")
                currentUser.saveInBackground()
                
            }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
