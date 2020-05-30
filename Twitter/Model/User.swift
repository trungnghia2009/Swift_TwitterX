//
//  User.swift
//  Twitter
//
//  Created by trungnghia on 5/23/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Firebase

struct User {
    
    let email: String
    var fullname: String
    var username: String
    var profileImageUrl: String
    let uid: String
    var isFollowed = false
    var stats: UserRelationStates?
    var bio: String?
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid  == uid
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
    }
}

struct UserRelationStates {
    var followers: Int
    var following: Int
    
    
}
