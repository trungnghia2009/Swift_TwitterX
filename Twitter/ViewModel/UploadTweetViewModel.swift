//
//  UploadTweetViewModel.swift
//  Twitter
//
//  Created by trungnghia on 5/25/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

enum UploadTweetConfiguration {
    case tweet
    case reply(Tweet)
}

struct UploadTweetViewModel {
    
    let actionButtonTitle: String
    let placeholderText: String
    var replyText: String?
    
    init(config: UploadTweetConfiguration) {
        switch config {
            
        case .tweet:
            actionButtonTitle = "Tweet"
            placeholderText = "What's happening ?"
        case .reply(let tweet):
            actionButtonTitle = "Reply"
            placeholderText = "Tweet your reply"
            replyText = "Replying to @\(tweet.user.username)"
        }
    }
}
