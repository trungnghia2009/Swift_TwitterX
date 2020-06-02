//
//  UserListCell.swift
//  Twitter
//
//  Created by trungnghia on 6/2/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

protocol UserListCellDelegate: class {
    func handleFollowTapped(_ cell: UserListCell)
}

class UserListCell: UITableViewCell {

    //MARK: - Properties
    weak var delegate: UserListCellDelegate?
    
    var user: User? {
        didSet { configure() }
    }
    
    private let profileImageView: UIImageView = {
           let iv = UIImageView()
           iv.contentMode = .scaleAspectFit
           iv.clipsToBounds = true
           iv.setDimensions(width: 48, height: 48)
           iv.layer.cornerRadius = 24
           iv.backgroundColor = .twitterBlue
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
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Following", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .twitterBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.text = "This is a user bio that will span more than one line for test purposes"
        return label
    }()
    
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 8)
        
        let userDetailStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        userDetailStack.axis = .vertical
        userDetailStack.spacing = 0
        
        addSubview(userDetailStack)
        userDetailStack.anchor(top: topAnchor, left: profileImageView.rightAnchor, right: rightAnchor,
                               paddingTop: 12, paddingLeft: 8, paddingRight: 150)
        
        addSubview(followButton)
        followButton.centerY(inView: userDetailStack)
        followButton.anchor(right: rightAnchor, paddingRight: 12)
        followButton.setDimensions(width: 100, height: 30)
        followButton.layer.cornerRadius = 15
        
        // bio anchor(left: 64, right: 12) ->76
        addSubview(bioLabel)
        bioLabel.anchor(top: userDetailStack.bottomAnchor, left: profileImageView.rightAnchor,
                        right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 12)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let user = user else { return }
        let modelView = UserListViewModel(user: user)
        
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl))
        fullnameLabel.text = user.fullname
        usernameLabel.text = "@\(user.username)"
        bioLabel.text = user.bio
        
        if Auth.auth().currentUser?.uid == user.uid {
            followButton.isHidden = true
        }
        followButton.setTitle(modelView.followButtonTitle, for: .normal)
        
        
    }
    
    
    //MARK: - Selectors    
    @objc private func handleFollowTapped() {
        delegate?.handleFollowTapped(self)
    }
    
    

}
