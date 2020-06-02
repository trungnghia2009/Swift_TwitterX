//
//  TweetViewModel.swift
//  Twitter
//
//  Created by trungnghia on 5/23/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

struct TweetViewModel {
    
    //MARK: - Properties
    private let tweet: Tweet
    private let user: User
    
    var profileImageUrl: URL? {
        return URL(string: tweet.user.profileImageUrl)
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timestamp, to: now) ?? "2m"
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ‣ MM/dd/yyyy"
        return formatter.string(from: tweet.timestamp)
    }
    
    var retweetsAtributedString: NSAttributedString {
        return attributedText(withValue: tweet.retweets, text: "Retweets")
    }
    
    var likesAtributedString: NSAttributedString {
        return attributedText(withValue: tweet.likes, text: "Likes")
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(user.username)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                .foregroundColor: UIColor.lightGray]))
        title.append(NSAttributedString(string: " ‣ \(timestamp)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                .foregroundColor: UIColor.lightGray]))
        return title
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.isLiked ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage {
        let imageName = tweet.isLiked ? "like_filled" : "like"
        return UIImage(named: imageName)!
    }
    
    var shouldHideReplyLabel: Bool {
        return !tweet.isReply
    }
    
    var replyText: String? {
        guard let username = tweet.replyingTo else { return nil}
        return "→ replying to @\(username)"
    }
    
    
    
    //MARK: - Lifecycle
    init(tweet: Tweet) {
        self.tweet = tweet
        user = tweet.user
    }
    
    
    //MARK: - Helpers
    func sizeForTweetCaption(forWidth width: CGFloat, fontSize size: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = tweet.caption
        measurementLabel.numberOfLines = 0
        measurementLabel.font = UIFont.systemFont(ofSize: size)
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) ->NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
