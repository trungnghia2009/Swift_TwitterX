//
//  EditProfileCell.swift
//  Twitter
//
//  Created by trungnghia on 5/28/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol EditProfileCellDelegate: class {
    func updateUserInfo(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {

    //MARK: - Properties
    var viewModel: EditProfileViewModel? {
        didSet { configure()  }
    }
    
    weak var delegate: EditProfileCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .left
        tf.textColor = .twitterBlue
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingChanged)
        return tf
    }()
    
    private let bioTextView: CustomEditTextView = {
        let tv = CustomEditTextView()
        tv.textColor = .twitterBlue
        return tv
    }()
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(titleLabel)
        titleLabel.setWidth(width: 100)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 16)
        
        addSubview(infoTextField)
        infoTextField.anchor(top: topAnchor, left: titleLabel.rightAnchor,
                             bottom: bottomAnchor, right: rightAnchor,
                             paddingTop: -4, paddingLeft: 16, paddingRight: 8)
        
        addSubview(bioTextView)
        bioTextView.anchor(top: topAnchor, left: titleLabel.rightAnchor,
                           bottom: bottomAnchor, right: rightAnchor,
                           paddingTop: 4, paddingLeft: 12, paddingRight: 8)
        bioTextView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInfo), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.titleText
        infoTextField.text = viewModel.optionValue
        bioTextView.text = viewModel.optionValue
        
        infoTextField.isHidden = viewModel.shouldHideInfo
        bioTextView.isHidden = viewModel.shouldHideBio
    }
    
    func getInfoTextField() -> String? {
        return infoTextField.text
    }
    
    func getBioTextView() -> String {
        return bioTextView.text
    }
    
    
    //MARK: - Selectors
    @objc private func handleUpdateUserInfo() {
        delegate?.updateUserInfo(self)
    }

}
