//
//  Message.swift
//  Twitter
//
//  Created by trungnghia on 6/5/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation
import Firebase

struct Message {
    let text: String
    let toId: String
    let fromId: String
    var timestamp: Timestamp!  //Form Firebase
    var user: User?
    
    let isFromCurrentUser: Bool
    
    var chatPartnerId: String {
        return isFromCurrentUser ? toId : fromId
    }
    
    init(dictionary: [String: Any]) {
        text = dictionary["text"] as? String ?? ""
        toId = dictionary["toId"] as? String ?? ""
        fromId = dictionary["fromId"] as? String ?? ""
        timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        isFromCurrentUser = fromId == Auth.auth().currentUser?.uid
        
    }
}

struct Conversation {
    let user: User
    let message: Message
}
