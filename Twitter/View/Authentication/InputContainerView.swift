//
//  ContainerView.swift
//  FireChat
//
//  Created by trungnghia on 5/4/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class InputContainerView: UIView {
    
    init(image: UIImage?, textField: UITextField, showButton: UIButton? = nil) {
        super.init(frame: .zero)
        
        setHeight(height: 50)
        
        let iv = UIImageView()
        iv.image = image
        iv.tintColor = .white
        iv.alpha = 0.87
        
        addSubview(iv)
        iv.centerY(inView: self)
        iv.anchor(left: self.leftAnchor, paddingLeft: 8)
        iv.setDimensions(width: 24, height: 24)
        
        if let button = showButton {
            addSubview(button)
            button.centerY(inView: self)
            button.anchor(right: self.rightAnchor)
            button.setDimensions(width: 20, height: 15)
            
            addSubview(textField)
            textField.centerY(inView: self)
            textField.anchor(left: iv.rightAnchor, right: button.leftAnchor, paddingLeft: 10, paddingRight: 10)
            
        } else {
            addSubview(textField)
            textField.centerY(inView: self)
            textField.anchor(left: iv.rightAnchor, right: self.rightAnchor, paddingLeft: 8)
            
        }
        
        addSubview(textField)
        textField.centerY(inView: self)
        textField.anchor(left: iv.rightAnchor, right: self.rightAnchor, paddingLeft: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .white
        addSubview(dividerView)
        dividerView.anchor(left: self.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, height: 0.75)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

