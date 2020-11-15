////  ContactsViewController.swift
//  Platica
//
//  Created by Jesus Lopez on 11/15/20.
//  
// 

import UIKit

class ContactsViewController: UIViewController {
    
    
    @IBOutlet weak var topBarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBarView.layer.cornerRadius = K.cornerRadius
        topBarView.layer.shadowColor = UIColor.black.cgColor
        topBarView.layer.shadowOffset = CGSize(width: 1, height: 1)
        topBarView.layer.shadowOpacity = 0.5
    }
}
