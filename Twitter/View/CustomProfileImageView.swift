//
//  CustomProfileImageView.swift
//  Twitter
//
//  Created by trungnghia on 6/4/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol CustomProfileImageViewDelegate: class {
    func handleProfileImageTapped()
}

class CustomProfileImageView: UIImageView {
    
    //MARK: - Properties
    weak var delegate: CustomProfileImageViewDelegate?
    
    var user: User? {
        didSet { configure() }
    }
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setDimensions(width: 30, height: 30)
        layer.cornerRadius = 15
        clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTappped))
        addGestureRecognizer(tap)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let user = user else { return }
        sd_setImage(with: URL(string: user.profileImageUrl))
    }
    
    //MARK: - Selectors
    @objc private func handleProfileImageTappped() {
        delegate?.handleProfileImageTapped()
    }
    
    
}
