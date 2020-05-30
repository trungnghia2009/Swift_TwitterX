//
//  UploadTweetController.swift
//  Twitter
//
//  Created by trungnghia on 5/23/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import ActiveLabel

class UploadTweetController: UIViewController {
    
    //MARK: - Properties
    private let user: User
    private let config: UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    private lazy var actionButton: UIButton = { // Need lazy keyword to get action for navigationItem.rightBarButtonItem
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 24
        iv.backgroundColor = .twitterBlue
        iv.sd_setImage(with: URL(string: user.profileImageUrl))
        return iv
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.mentionColor = .twitterBlue
        return label
    }()
    
    private let captionTextView = CaptionTextView()
    
    //MARK: - Lifecycle
    init(user: User, config: UploadTweetConfiguration) {
        self.config = config
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch config {
            
        case .tweet:
            replyLabel.isHidden = true
        case .reply(_):
            replyLabel.isHidden = false
            
        }
        
        configureUI()
        configureMentionHandler()
        
        
    }
    
    //MARK: - API
    
    
    //MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar()
        
        let imageAndCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        imageAndCaptionStack.axis = .horizontal
        imageAndCaptionStack.spacing = 12
        imageAndCaptionStack.alignment = .leading // Return the default size for captionTextView
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageAndCaptionStack])
        stack.axis = .vertical
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        
        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        captionTextView.inputText = viewModel.placeholderText
        replyLabel.text = viewModel.replyText
    
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
    private func configureMentionHandler() {
        replyLabel.handleMentionTap { (mention) in
            self.logger("Memtion user is \(mention  )")
        }
    }
    
    
    //MARK: - Selectors
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleUploadTweet() {
        guard captionTextView.text.count > 0 else { return }
        
        TweetService.shared.uploadTweet(caption: captionTextView.text, type: config) { (error, ref) in
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
//            if case .reply(let tweet) = self.config {
//                NotificationService.shared.uploadNotification(type: .reply, tweet: tweet)
//            }
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
}
