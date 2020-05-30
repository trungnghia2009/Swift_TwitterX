//
//  CaptionTextView.swift
//  Twitter
//
//  Created by trungnghia on 5/23/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class CaptionTextView: UITextView {
    
    //MARK: - Properties
    var inputText: String? {
        didSet { placeholderLabel.text = inputText}
    }
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        //label.text = "What's happening ?"
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = .white
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        heightAnchor.constraint(equalToConstant: 150).isActive = true
        textContainer?.maximumNumberOfLines = 0
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 4)
        becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selectors
    @objc private func handleTextInputChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
