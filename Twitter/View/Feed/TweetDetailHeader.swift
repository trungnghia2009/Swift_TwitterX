//
//  TweetDetailHeader.swift
//  Twitter
//
//  Created by trungnghia on 5/25/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class TweetHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    
    //MARK: - Selectors
}
