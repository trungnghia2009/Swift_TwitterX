//
//  CustomInputAccessoryView.swift
//  FireChat
//
//  Created by trungnghia on 5/5/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol CustomInputAccessoryViewDelegate: class {
    func inputView(_ inputView: CustomInputAccessoryView, _ message: String)
    func didBeginEditting()
    func didEndEditting()
}

class CustomInputAccessoryView: UIView {
    
    //MARK: - Properties
    weak var delegate: CustomInputAccessoryViewDelegate?
    
    private let messageInputTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.lightGray, for: .normal)
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter message..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 4, paddingRight: 8)
        sendButton.setDimensions(width: 50, height: 50)
        
        messageInputTextView.delegate = self
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top: topAnchor, left: leftAnchor,
                                    bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor,
                                    paddingTop: 12, paddingLeft: 4, paddingBottom: 8, paddingRight: 8)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(left: messageInputTextView.leftAnchor, paddingLeft: 4)
        placeholderLabel.centerY(inView: messageInputTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    //MARK: - Selectors
    @objc func handleSendMessage() {
        guard let text = messageInputTextView.text else { return }
        delegate?.inputView(self, text)
        setupAfterSendingMessage()
    }
    
    @objc func handleTextInputChange() {
        placeholderLabel.isHidden = messageInputTextView.text.count > 0
        sendButton.isUserInteractionEnabled = messageInputTextView.text.count > 0
        
        if messageInputTextView.text.count > 0 {
            sendButton.setTitleColor(.twitterBlue, for: .normal)
        } else {
            sendButton.setTitleColor(.lightGray, for: .normal)
        }
        
    }
    
    //MARK: - Helpers
    func setupAfterSendingMessage() {
        messageInputTextView.text = ""
        placeholderLabel.isHidden = false
        sendButton.isUserInteractionEnabled = false
        sendButton.setTitleColor(.lightGray, for: .normal)
    }
    
}

//MARK: - UITextViewDelegate
extension CustomInputAccessoryView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.didBeginEditting()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didEndEditting()
    }
}
