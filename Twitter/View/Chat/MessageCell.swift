//
//  MessageCell.swift
//  FireChat
//
//  Created by trungnghia on 5/5/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {

    //MARK: - Properties
    var message: Message? {
        didSet { configure() }
    }

    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.textColor = .white
        return tv
    }()

    private let bubbleContainer: UIView = {
        let view = UIView()
        return view
    }()

    private let lefTimestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Next", size: 12)
        label.text = "2h"
        return label
    }()

    private let rightTimestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Next", size: 12)
        label.text = "30:99"
        return label
    }()

    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 8, paddingBottom: -4)
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 16

        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true

        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
        bubbleLeftAnchor.isActive = false

        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false

        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor,
                        bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor,
                        paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)

        addSubview(lefTimestampLabel)

        addSubview(rightTimestampLabel)
        rightTimestampLabel.anchor(right: bubbleContainer.leftAnchor, paddingRight: 12)
        rightTimestampLabel.centerY(inView: bubbleContainer)



    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Helpers
    func configure() {
        guard let message = message else { return }
        let viewModel = MessageViewModel(message: message)
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.textColor = viewModel.messageTextColor
        textView.text = message.text

        lefTimestampLabel.text = viewModel.timestamp
        if viewModel.leftAnchorActive {
            rightTimestampLabel.isHidden = true
            lefTimestampLabel.centerY(inView: bubbleContainer, left: bubbleContainer.rightAnchor, paddingLeft: 12)
        }
        
        if viewModel.rightAnchorActive {
            rightTimestampLabel.text = viewModel.timestamp
            rightTimestampLabel.isHidden = false
        }

        profileImageView.isHidden = viewModel.shouldHideProfileImage
        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive

        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
}
