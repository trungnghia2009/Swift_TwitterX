//
//  Tweer.swift
//  Twitter
//
//  Created by trungnghia on 5/23/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct Tweet {
    let caption: String
    let tweetID: String
    var likes: Int
    let retweets: Int
    var timestamp: Date!
    var user: User
    var isLiked = false
    var replyingTo: String?
    
    var isReply: Bool { return replyingTo != nil }
    
    init(user: User, tweetID: String, dictionary: [String: Any]) {
        self.tweetID = tweetID
        self.user = user
        
        caption = dictionary["caption"] as? String ?? ""
        likes = dictionary["likes"] as? Int ?? 0
        retweets = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}
