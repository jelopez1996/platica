//
//  WelcomeViewController.swift
//

import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Edit title font and size
        titleLabel.text = K.appName
        titleLabel.font = UIFont(name: "SanMarinoBeach", size: 75)
        
        // Round the buttons and add a shadow
        loginButton.layer.cornerRadius = K.cornerRadius
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        loginButton.layer.shadowOpacity = K.shadowOpacity
        
        signUpButton.layer.cornerRadius = K.cornerRadius
        signUpButton.layer.shadowColor = UIColor.black.cgColor
        signUpButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        signUpButton.layer.shadowOpacity = K.shadowOpacity
        

    }
    

}
