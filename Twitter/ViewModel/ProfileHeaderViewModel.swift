//
//  ProfileHeaderViewModel.swift
//  Twitter
//
//  Created by trungnghia on 5/24/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable, CustomStringConvertible {
    case tweets
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
}

struct ProfileHeaderViewModel {
    
    private let user: User
    
    var followersString: NSAttributedString? {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "followers")
    }
    
    var followingString: NSAttributedString? {
        return attributedText(withValue: user.stats?.following ?? 0, text: "following")
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var actionButtonTitle: String {
        // if being current user then set to edit profile
        // else figure out following/not following
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        if !user.isFollowed && !user.isCurrentUser {
            return "Follow"
        } else {
            return "Following"
        }
        
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) ->NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
    
    
    init(user: User) {
        self.user = user
    }
}
