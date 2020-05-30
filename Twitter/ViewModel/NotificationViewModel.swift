//
//  NotificationViewModel.swift
//  Twitter
//
//  Created by trungnghia on 5/26/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

struct NotificationViewModel {
    
    private let notification: Notification
    private let type: NotificationType
    private let user: User
    
    var profileImageUrl: URL? {
        return URL(string: notification.user.profileImageUrl)
    }
    
    var timestamp: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: notification.timestamp, to: now) ?? "2m"
    }
    
    var notificationMessage: String {
        switch type {
            
        case .follow:
            return " started following you"
        case .like:
            return " liked your tweet"
        case .reply:
            return " replied to your tweet"
        case .retweet:
            return " retweeted your tweet"
        case .mention:
            return " mentioned you in a tweet"
        }
    }
    
    var notificationText: NSAttributedString? {
        guard let timestamp = timestamp else { return nil }
        let attributtedText = NSMutableAttributedString(string: user.username,
                                                        attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributtedText.append(NSAttributedString(string: notificationMessage,
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributtedText.append(NSAttributedString(string: " ‣ \(timestamp)",
            attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributtedText
    }
    
    var shouldHideFollowButton: Bool {
        return type != .follow
    }
    
    var followButtonTitle: String {
        return user.isFollowed ? "Following" : "Follow"
    }
    
    init(notification: Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
}
