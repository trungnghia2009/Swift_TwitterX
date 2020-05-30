//
//  Notification.swift
//  Twitter
//
//  Created by trungnghia on 5/26/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

enum NotificationType: Int {
    case follow = 0
    case like = 1
    case reply = 2
    case retweet = 3
    case mention = 4
}

struct Notification {
    
    let notificationID: String
    var tweetID: String?
    var timestamp: Date!
    var user: User
    var tweet: Tweet?
    var type: NotificationType!
    
    // optional Tweet because notifications don't always have a tweet associated with them, example is follow
    
    init(notificationID: String, user: User, dictionary: [String: Any]) {
        self.notificationID = notificationID
        self.user = user
        
        if let tweetID = dictionary["tweetID"] as? String {
            self.tweetID = tweetID
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
        
    }
}
