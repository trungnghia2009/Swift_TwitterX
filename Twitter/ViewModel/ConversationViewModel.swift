//
//  ConversationViewModel.swift
//  FireChat
//
//  Created by trungnghia on 5/6/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct ConversationViewModel {
    
    private let conversation: Conversation
    
    var profileImageUrl: URL? {
        return URL(string: conversation.user.profileImageUrl)
    }
    
    var timestamp: String {
        let calendar = Calendar.current
        let date = conversation.message.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "hh:mm a"
        } else {
            dateFormatter.dateFormat = "dd/MM hh:mm a"
        }
        
        return dateFormatter.string(from: date)
    }
    
    init(conversation: Conversation) {
        self.conversation = conversation
    }
}
