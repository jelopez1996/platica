//
//  Helper.swift
//  Flash Chat iOS13
//
//  Created by Jesus Lopez on 9/9/20.
//  Copyright © 2020 Angela Yu. All rights reserved.
//

import Foundation

struct Helper {
    
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

}
