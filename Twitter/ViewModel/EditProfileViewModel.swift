//
//  EditProfileViewModel.swift
//  Twitter
//
//  Created by trungnghia on 5/28/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable, CustomStringConvertible {
    
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
            
        case .fullname:
            return "Name"
        case .username:
            return "Username"
        case .bio:
            return "Bio"
        }
    }
    
}

struct EditProfileViewModel {
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
            
        case .fullname:
            return user.fullname
        case .username:
            return user.username
        case .bio:
            return user.bio
        }
    }
    
    var shouldHideInfo: Bool {
        return option == .bio
    }
    
    var shouldHideBio: Bool {
        return option != .bio
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
