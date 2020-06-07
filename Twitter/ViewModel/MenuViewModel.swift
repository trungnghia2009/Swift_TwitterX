//
//  MenuViewModel.swift
//  Twitter
//
//  Created by trungnghia on 6/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    var description: String {
        switch self {
            
        case .profile:
            return "Profile"
        case .lists:
            return "Lists"
        case .bookmarks:
            return "Bookmarks"
        case .logout:
            return "Log Out"
        }
    }
    
    case profile
    case lists
    case bookmarks
    case logout
}

struct MenuViewModel {
    
    let option: MenuOptions
    
    var iconImage: UIImage {
        switch option {
            
        case .profile:
            return UIImage(systemName: "person")!
        case .lists:
            return UIImage(systemName: "list.dash")!
        case .bookmarks:
            return UIImage(systemName: "bookmark")!
        case .logout:
            return UIImage(systemName: "escape")!
        
        }
    }
    
    init(option: MenuOptions) {
        self.option = option
    }
}
