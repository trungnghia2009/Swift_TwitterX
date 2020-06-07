//
//  TweetCell.swift
//  Twitter
//
//  Created by trungnghia on 5/23/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import ActiveLabel

protocol TweetCellDelegate: class {
    func handleProfileImageTapped(_ cell: TweetCell)
    func handleReplyTapped(_ cell: TweetCell)
    func handleLikeTapped(_ cell: TweetCell)
    func handleShareTapped(_ cell: TweetCell)
    func handleRetweetTapped(_ cell: TweetCell)
    func handleFetchUser(withUsername username: String)
    func handleActionSheet(_ cell: TweetCell)
}

class TweetCell: UICollectionViewCell {
    
    //MARK: - Properties
    weak var delegate: TweetCellDelegate?
    
    var tweet: Tweet? {
        didSet { configure() }
    }
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .twitterBlue
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 24
        iv.backgroundColor = .twitterBlue
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true // By default UIImageView has no interaction
        
        return iv
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    private let infoLabel = UILabel()
    
    private lazy var optionButon: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "down_arrow_24pt"), for: .normal)
        button.setDimensions(width: 40, height: 30)
        button.addTarget(self, action: #selector(handleActionSheet), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withSystemName: "message")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private let commentAmount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = createButton(withSystemName: "repeat")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    
    private let retweetAmount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withSystemName: "heart")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private let likeAmount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(withSystemName: "square.and.arrow.up")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    
    private let underlineView: UIView = {
        let underline = UIView()
        underline.backgroundColor = .systemGroupedBackground
        return underline
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let replyStack = UIStackView(arrangedSubviews: [replyLabel])
        addSubview(replyStack)
        replyStack.anchor(top: topAnchor, left: leftAnchor, paddingLeft: 8)
        replyLabel.isHidden = true
        
        addSubview(profileImageView)
        profileImageView.anchor(top: replyStack.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        // captionLabel constrains(left: 68, right: 12)
        let stack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, right: rightAnchor,
                     paddingLeft: 12, paddingRight: 12)
        
        addSubview(optionButon)
        optionButon.centerY(inView: infoLabel)
        optionButon.anchor(right: rightAnchor, paddingRight: 0)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton,
                                                         retweetButton,
                                                         likeButton,
                                                         shareButton])
        actionStack.axis = .horizontal
        actionStack.distribution = .equalSpacing
        
        addSubview(actionStack)
        actionStack.anchor(left: stack.leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                           paddingLeft: -20, paddingBottom: 8, paddingRight: 48)
        
        addSubview(commentAmount)
        commentAmount.centerY(inView: commentButton, left: commentButton.rightAnchor, paddingLeft: -15)
        
        addSubview(retweetAmount)
        retweetAmount.centerY(inView: retweetButton, left: retweetButton.rightAnchor, paddingLeft: -15)
        
        addSubview(likeAmount)
        likeAmount.centerY(inView: likeButton, left: likeButton.rightAnchor, paddingLeft: -15)
        
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        underlineView.setHeight(height: 1)
        
        configureMentionHandler()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    private func configure() {
        guard let tweet = tweet else { return }
        let viewModel = TweetViewModel(tweet: tweet)
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        infoLabel.attributedText = viewModel.userInfoText
        captionLabel.text = tweet.caption
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
        
        likeAmount.text = "\(tweet.likes)"
        likeAmount.textColor = viewModel.likeAmountColor
        commentAmount.text = "\(tweet.replies)"
        retweetAmount.text = "\(tweet.retweets)"
        
    }
    
    private func configureMentionHandler() {
        captionLabel.handleMentionTap { (mention) in
            self.delegate?.handleFetchUser(withUsername: mention)
        }
    }
    
    private func createButton(withSystemName systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .darkGray
        button.setDimensions(width: 60, height: 20)
        return button
    }
    
    func shouldEnableLikeButton(_ value: Bool) {
        likeButton.isEnabled = value
    }
    
    
    //MARK: - Selectors
    @objc private func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc private func handleActionSheet() {
        delegate?.handleActionSheet(self)
    }
    
    @objc private func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    
    @objc private func handleRetweetTapped() {
        delegate?.handleRetweetTapped(self)
    }
    
    @objc private func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    
    @objc private func handleShareTapped() {
        delegate?.handleShareTapped(self)
    }
    
}
