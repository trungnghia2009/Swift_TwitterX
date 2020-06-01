//
//  MenuHeader.swift
//  Twitter
//
//  Created by trungnghia on 5/31/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol MenuHeaderDelegate: class {
    func handleProfileImageTapped(_ header: MenuHeader)
}

class MenuHeader: UIView {

    //MARK: - Properties
    weak var delegate: MenuHeaderDelegate?
    
    var user: User {
        didSet {
            let viewModel = ProfileHeaderViewModel(user: user)
            followersLabel.attributedText = viewModel.followersString
            followingLabel.attributedText = viewModel.followingString
        }
    }
    
    private lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFit
        view.setDimensions(width: 64, height: 64)
        view.layer.cornerRadius = 32
        view.clipsToBounds = true
        view.sd_setImage(with: URL(string: user.profileImageUrl))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = user.fullname
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "@\(user.username)"
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    private let underline: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.setHeight(height: 1.25)
        return view
    }()
    
    
    //MARK: - Lifecycle
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 10, paddingLeft: 12)
        
        let userDetailStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        userDetailStack.axis = .vertical
        userDetailStack.spacing = 4
        
        addSubview(userDetailStack)
        userDetailStack.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.spacing = 8
        
        addSubview(followStack)
        followStack.anchor(top: userDetailStack.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        
        addSubview(underline)
        underline.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingBottom: 12)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    
    
    //MARK: - Selectors
    @objc private func handleFollowersTapped() {
        logger("Handle followers tapped")
    }
    
    @objc private func handleFollowingTapped() {
        logger("Handle following tapped")
    }
    
    @objc private func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
}
