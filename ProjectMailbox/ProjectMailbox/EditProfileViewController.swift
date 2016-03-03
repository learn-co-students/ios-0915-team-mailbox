//
//  EditProfileViewController.swift
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/6/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        NSLog("I'M IN THE VIEW DID LOAD, EDIT PRFILE VIEW CONTROLLER");

        super.viewDidLoad()
        
        imagePicker.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        
//        profileImageView.contentMode = .ScaleAspectFill;
//        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
//        profileImageView.clipsToBounds = true
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @IBAction func changePhotoButtonTapped(sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = pickedImage
//            profileImageView.contentMode = .ScaleAspectFit
//            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
//            profileImageView.clipsToBounds = true
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
            
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName("UserDidEditProfileNotification", object: nil)
            
        }
        
        let userDetailsChangedAlert = UIAlertController(title: "You've successfully changed your profile", message: "", preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        userDetailsChangedAlert.addAction(defaultAction)
        
        self.presentViewController(userDetailsChangedAlert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}
