//
//  RegisterViewController.swift
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVFoundation
import Photos

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var credentialView: UIView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    var textFields: [UITextField]?
    let photoCameraPermission = PCPermissions()

    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        self.addChild(photoCameraPermission)


        firstName.delegate = self
        lastName.delegate = self
        password.delegate = self
        email.delegate = self

        textFields = [firstName, lastName, email, password]


        // Set contactView to be half that of the screen

        contactView.layer.cornerRadius = K.cornerRadius
        contactView.layer.shadowColor = UIColor.black.cgColor
        contactView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contactView.layer.shadowOpacity = K.shadowOpacity

        // Add shadows and round edges to credentialView
        credentialView.layer.cornerRadius = K.cornerRadius
        credentialView.layer.shadowColor = UIColor.black.cgColor
        credentialView.layer.shadowOffset = CGSize(width: 1, height: 1)
        credentialView.layer.shadowOpacity = K.shadowOpacity

        // Add shadows and round edges to complete button
        completeButton.layer.cornerRadius = K.cornerRadius
        completeButton.layer.shadowColor = UIColor.black.cgColor
        completeButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        completeButton.layer.shadowOpacity = K.shadowOpacity
        
        // Crop image for profile
        profilePic.layer.borderWidth = 1.0
        profilePic.layer.masksToBounds = false
        profilePic.layer.borderColor = UIColor.black.cgColor
        profilePic.layer.cornerRadius = profilePic.frame.size.height / 2
        profilePic.clipsToBounds = true
       
    }



    @IBAction func imagePressed(_ sender: UIButton) {
        photoCameraPermission.getImage(image: profilePic)
    }

    @IBAction func completePressed(_ sender: Any) {
        completeButton.isEnabled = false
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (data, error) in
            if((error) != nil) {
                let alert = UIAlertController(title: "Error creating your account", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true) {
                    self.completeButton.isEnabled = true
                }
            } else {
                let imageData = self.profilePic.image!.jpegData(compressionQuality: 0.75)
                if let userId = Auth.auth().currentUser?.uid {
                    self.db.collection("profileImages").addDocument(data: ["image" : imageData!, "type": "profile", "owner": userId]) { (error) in
                        if((error) != nil) {
                            print(error!.localizedDescription)
                        } else {
                            // Segue into the conversations page
                            self.performSegue(withIdentifier: K.registerToConversationsSegue, sender: self)
                        }
                    }
                }
                
                
            }
        }
    }


}


extension RegisterViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField.tag == 2) {
            textField.textColor = UIColor.black
            textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.tag == 3){
            self.view.endEditing(true)
        } else {
            textField.resignFirstResponder()
            self.textFields?[textField.tag + 1].becomeFirstResponder()
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        if(textField.tag == 2) {
            if(!Helper.isValidEmail(email: textField.text!)) {
                textField.textColor = UIColor.red
                textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                completeButton.isEnabled = false
            }
        }

        if(firstName.text! != "" && lastName.text! != "" && Helper.isValidEmail(email: email.text!) && password.text! != ""){
            completeButton.isEnabled = true
        } else {
            completeButton.isEnabled = false
        }

    }
    
}
