//
//  MessageViewModel.swift
//  FireChat
//
//  Created by trungnghia on 5/6/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

struct MessageViewModel {
    
    private let message: Message
    
    var messageBackgroundColor: UIColor {
        return message.isFromCurrentUser ? #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) : .twitterBlue
    }
    
    var messageTextColor: UIColor {
        return message.isFromCurrentUser ? .black : .white
    }
    
    var rightAnchorActive: Bool {
        return message.isFromCurrentUser
    }
    
    var leftAnchorActive: Bool {
        return !message.isFromCurrentUser
    }
    
    var shouldHideProfileImage: Bool {
        return message.isFromCurrentUser
    }
    
    var profileImageUrl: URL? {
        guard let user = message.user else { return nil }
        return URL(string: user.profileImageUrl)
    }
    
    var timestamp: String {
        let calendar = Calendar.current
        let messageDate = message.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(messageDate) {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "dd/MM"
        }
        
        return dateFormatter.string(from: messageDate)
    }
    
    init(message: Message) {
        self.message = message
    }
}

