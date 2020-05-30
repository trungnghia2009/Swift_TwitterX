//
//  RegistrationViewModel.swift
//  FireChat
//
//  Created by trungnghia on 5/4/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct RegistrationViewModel: AuthenticationProtocol {

    var email: String?
    var fullname: String?
    var username: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
            && fullname?.isEmpty == false
            && password?.isEmpty == false
            && username?.isEmpty == false
    }
    
}
