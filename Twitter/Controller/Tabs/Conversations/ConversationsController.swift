//
//  ConversationsController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol ConversationsControllerDelegate {
    func handleProfileImageTappedForConversations()
}

class ConversationsController: UIViewController {

    //MARK: - Properties
    weak var delegate: NotificationsControllerDelegate?
    
    private let profileImageView = CustomProfileImageView(frame: .zero)
    
    var user: User? {
        didSet { profileImageView.user = user }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    
    //MARK: - Helpers
    private func configureUI() {
        profileImageView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-settings-80"), style: .plain, target: self, action: #selector(handleRightBarTapped))
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        view.backgroundColor = .white
        navigationItem.title = "Messages"
        
    }
    
    //MARK: - Selectors
    @objc private func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            delegate?.handleProfileImageTappedForNotifications()
        }
    }
    
    @objc private func handleRightBarTapped() {
        logger("Handle right bar tapped..")
    }
}


//MARK: - CustomProfileImageViewDelegate
extension ConversationsController: CustomProfileImageViewDelegate {
    func handleProfileImageTapped() {
        delegate?.handleProfileImageTappedForNotifications()
    }
    
    
}
