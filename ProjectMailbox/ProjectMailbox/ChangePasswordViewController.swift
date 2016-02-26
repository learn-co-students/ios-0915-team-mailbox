//
//  ChangePasswordViewController.swift
//  ProjectMailbox
//
//  Created by Joseph Kiley on 12/6/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        
        NSLog("I'M IN THE VIEW DID LOAD, CHANGE PASSWORD VIEW CONTROLLER");

    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        let emailAddress = emailTextField.text
        
        if (emailAddress!.isEmpty) {
            
            let noEmailAlert = UIAlertController(title: "Invalid Email", message: "Please provide a valid email address", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            noEmailAlert.addAction(defaultAction)
            
            presentViewController(noEmailAlert, animated: true, completion: nil)
        }
        
        PFUser.requestPasswordResetForEmailInBackground(emailAddress!) { (success, error) -> Void in
            if (error != nil) {
                let noEmailAlert = UIAlertController(title: "Invalid Email", message: "Please provide a valid email address", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                noEmailAlert.addAction(defaultAction)
                
                self.presentViewController(noEmailAlert, animated: true, completion: nil)
                
            } else {
                let checkEmailAlert = UIAlertController(title: "Please check your email", message: "", preferredStyle: .Alert)
                


                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                checkEmailAlert.addAction(defaultAction)


                
                self.presentViewController(checkEmailAlert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func dismissViewControllerHandler(alert: UIAlertAction!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
