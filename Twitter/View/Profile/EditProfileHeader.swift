//
//  EditProfileHeader.swift
//  Twitter
//
//  Created by trungnghia on 5/28/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol EditProfileHeaderDelegate: class {
    func didTapChangeProfilePhoto()
}

class EditProfileHeader: UIView {
    
    //MARK: - Properties
    weak var delegate: EditProfileHeaderDelegate?
    
    private let user: User
    
    var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 3.0
        return iv
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        
        backgroundColor = .twitterBlue
        
        addSubview(profileImageView)
        profileImageView.center(inView: self, yConstant: -25)
        profileImageView.setDimensions(width: 100, height: 100)
        profileImageView.layer.cornerRadius = 50
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl))
        
        addSubview(changePhotoButton)
        changePhotoButton.centerX(inView: self, top: profileImageView.bottomAnchor, paddingTop: 8)
        
        let whiteView = UIView()
        whiteView.backgroundColor = .white
        addSubview(whiteView)
        whiteView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 15)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    
    //MARK: - Selectors
    @objc private func handleChangeProfilePhoto() {
        delegate?.didTapChangeProfilePhoto()
    }
}
