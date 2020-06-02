//
//  UserListViewModel.swift
//  Twitter
//
//  Created by trungnghia on 6/2/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct UserListViewModel {
    
    let user: User
    
    var followButtonTitle: String {
        return user.isFollowed ? "Following" : "Follow"
    }
    
    init(user: User) {
        self.user = user
    }
    
}
