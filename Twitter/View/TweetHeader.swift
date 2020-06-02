//
//  TweetDetailHeader.swift
//  Twitter
//
//  Created by trungnghia on 5/25/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import ActiveLabel

protocol TweetHeaderDelegate: class {
    func showActionSheet()
    func handleProfileImageTapped(_ header: TweetHeader)
    func handleFetchUser(withUsername username: String)
    func handleLikedUsersTapped(_ header: TweetHeader)
}

class TweetHeader: UICollectionReusableView {
    
    //MARK: - Properties
    weak var delegate: TweetHeaderDelegate?
    
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
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Peter Paker"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "@spiderman"
        return label
    }()
    
    private let optionButon: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(#imageLiteral(resourceName: "down_arrow_24pt"), for: .normal)
        button.addTarget(self, action: #selector(handleActionSheet), for: .touchUpInside)
        return button
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "6:33 PM - 05/24/2020"
        return label
    }()
    
    private let calenderView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "calender-100")
        view.setDimensions(width: 30, height: 30)
        return view
    }()
    
    private lazy var                                                                                                                                                                            statsView: UIView = {
        let view = UIView()
        
        let upDivider = UIView()
        upDivider.backgroundColor = .systemGroupedBackground
        view.addSubview(upDivider)
        upDivider.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                         paddingLeft: 8, height: 1.0)
        
        let stack = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.centerY(inView: view)
        stack.anchor(left: view.leftAnchor, paddingLeft: 16)
        
        let downDivider = UIView()
        downDivider.backgroundColor = .systemGroupedBackground
        view.addSubview(downDivider)
        downDivider.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                           paddingLeft: 8, height: 1.0)
        
        return view
    }()
    
    private lazy var retweetsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "2 Retweets"
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRetweetsTapped))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0 Likes"
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLikedUsersTapped))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    private let botomDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        view.setHeight(height: 1.0)
        return view
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let labelStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        labelStack.axis = .vertical
        labelStack.spacing = -6
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, labelStack])
        imageCaptionStack.axis = .horizontal
        imageCaptionStack.spacing = 12
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8

        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        
        addSubview(optionButon)
        optionButon.centerY(inView: stack)
        optionButon.anchor(right: rightAnchor, paddingRight: 8)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: stack.bottomAnchor, left: leftAnchor, right: rightAnchor,
                            paddingTop: 20, paddingLeft: 16, paddingRight: 16)
        
        
        addSubview(calenderView)
        calenderView.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 16)
        
        addSubview(dateLabel)
        dateLabel.centerY(inView: calenderView, left: calenderView.rightAnchor, paddingLeft: 12)
        
        addSubview(statsView)
        statsView.anchor(top: calenderView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 20, height: 40)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton,
                                                         retweetButton,
                                                         likeButton,
                                                         shareButton])
        actionStack.axis = .horizontal
        actionStack.distribution = .equalSpacing
        
        addSubview(actionStack)
        actionStack.anchor(top: statsView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32)
        
        addSubview(botomDivider)
        botomDivider.anchor(top: actionStack.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16)
        
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
        fullnameLabel.text = tweet.user.fullname
        usernameLabel.text = "@\(tweet.user.username)"
        captionLabel.text = tweet.caption
        dateLabel.text = viewModel.headerTimestamp
        retweetsLabel.attributedText = viewModel.retweetsAtributedString
        likesLabel.attributedText = viewModel.likesAtributedString
        
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
        
    }
    
    private func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 25, height: 25)
        return button
    }
    
    private func configureMentionHandler() {
        captionLabel.handleMentionTap { (mention) in
            self.delegate?.handleFetchUser(withUsername: mention)
        }
    }
    
    
    //MARK: - Selectors
    @objc private func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc private func handleActionSheet() {
        delegate?.showActionSheet()
    }
    
    @objc private func handleRetweetsTapped() {
         print("Debug: Handle retweets tapped here..")
    }
    
    @objc private func handleLikedUsersTapped() {
        delegate?.handleLikedUsersTapped(self)
    }
    
    @objc private func handleCommentTapped() {
        print("Debug: Handle Comment tapped here..")
    }
    
    @objc private func handleRetweetTapped() {
        print("Debug: Handle Retweet tapped here..")
    }
    
    @objc private func handleLikeTapped() {
        print("Debug: Handle Like tapped here..")
    }
    
    @objc private func handleShareTapped() {
        print("Debug: Handle Share tapped here..")
    }
}
