//
//  InputTextView.swift
//  Twitter
//
//  Created by trungnghia on 5/28/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class CustomEditTextView: UITextView {
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "Bio"
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = .white
        font = UIFont.systemFont(ofSize: 14)
        isScrollEnabled = false
        textContainer?.maximumNumberOfLines = 4
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    override func layoutSubviews() {
        perform(#selector(handleTextInputChange))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selectors
    @objc private func handleTextInputChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
}


