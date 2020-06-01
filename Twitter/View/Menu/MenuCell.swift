//
//  MenuCell.swift
//  Twitter
//
//  Created by trungnghia on 5/31/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    //MARK: - Properties
    var option: MenuOptions? {
        didSet { configure() }
    }
    
    private let iconButton: UIButton = {
        let button = UIButton()
        button.setDimensions(width: 30, height: 30)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        button.isEnabled = false
        button.tintColor = .black
        return button
    }()
    
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(iconButton)
        iconButton.centerY(inView: self, left: leftAnchor, paddingLeft: 12)
        
        addSubview(menuLabel)
        menuLabel.centerY(inView: iconButton, left: iconButton.rightAnchor, paddingLeft: 8)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let option = option else { return }
        let viewModel = MenuViewModel(option: option)
        iconButton.setImage(viewModel.iconImage, for: .normal)
        menuLabel.text = option.description
    }
    
    //MARK: - Selectors

}
