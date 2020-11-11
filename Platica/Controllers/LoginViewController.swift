//
//  LoginViewController.swift
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var credentialView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add shadows and round edges to credentialView
        credentialView.layer.cornerRadius = K.cornerRadius
        credentialView.layer.shadowColor = UIColor.black.cgColor
        credentialView.layer.shadowOffset = CGSize(width: 1, height: 1)
        credentialView.layer.shadowOpacity = 0.2
        
        // Add shadows and round edges to complete button
        loginButton.layer.cornerRadius = K.cornerRadius
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        loginButton.layer.shadowOpacity = 0.2
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let e = error {
                    let alert = UIAlertController(title: "Sorry, theres an error...", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    // Navigate to Chatview Controller
                    self.performSegue(withIdentifier: K.loginToConversationsSegue, sender: self)
                }
            }
        }
    }
    
}
