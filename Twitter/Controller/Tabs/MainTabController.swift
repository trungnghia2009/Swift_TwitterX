//
//  MainTabController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

enum ActionButtonConfiguration {
    case tweet
    case message
}

protocol TabBarReselectHandling {
    func handleReselect()
}

protocol MainTabControllerDelegate: class {
    func handleProfileImageTapped(_ controller: FeedController)
}

class MainTabController: UITabBarController {
    
    //MARK: - Properties
    weak var delegateCallBack: MainTabControllerDelegate?
    
    private let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
    private let explore = SearchController(config: .userSearch)
    private let notifications = NotificationsController()
    private let conversations = ConversationsController()
    
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
    var user: User? {
        didSet {
            guard let nav = viewControllers![0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers[0] as? FeedController else { return }
            feed.user = user
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0.05965350568, green: 0.5876290798, blue: 0.9076900482, alpha: 1)
        button.setImage(#imageLiteral(resourceName: "new_tweet"), for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        configureUI()
    }
    
    
    //MARK: - API
    
    
    //MARK: - Helpers
    private func configureUI() {
        self.delegate = self
        
        view.addSubview(actionButton)
        actionButton.setDimensions(width: 56, height: 56)
        actionButton.layer.cornerRadius = 28
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16)
    }
    
    private func configureViewControllers() {
        feed.delegate = self
        
        let nav1 = templateNaviationController(image: UIImage(systemName: "house.fill")!, rootViewController: feed)
        let nav2 = templateNaviationController(image: UIImage(systemName: "magnifyingglass")!, rootViewController: explore)
        let nav3 = templateNaviationController(image: UIImage(systemName: "bell")!, rootViewController: notifications)
        let nav4 = templateNaviationController(image: UIImage(systemName: "envelope")!, rootViewController: conversations)

        viewControllers = [nav1, nav2, nav3, nav4]
        tabBar.items![2].badgeValue = "3"
    }
    
    private func templateNaviationController(image: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController) // Add navigationBar
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        
        return nav
    }
    
    
    //MARK: - Selectors
    @objc private func actionButtonTapped() {
        let controller: UIViewController
        
        switch buttonConfig {
    
        case .tweet:
            guard let user = user else { return }
            controller = UploadTweetController(user: user, config: .tweet)
            
        case .message:
            controller = SearchController(config: .messages)

        }
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }

}


//MARK: - UITabBarControllerDelegate
extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let imageName = index == 3 ? #imageLiteral(resourceName: "mail")  : #imageLiteral(resourceName: "new_tweet")
        actionButton.setImage(imageName, for: .normal)
        buttonConfig = index == 3 ? .message : .tweet
        
        if index == 2 {
            notifications.fetchNotifications()
        }
        
    }
    
    //Handle shouldSelect
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let navigationController = viewController as? UINavigationController else { return true }
        guard navigationController.viewControllers.count <= 1,
            let handler = navigationController.viewControllers.first as? TabBarReselectHandling else { return true }
        handler.handleReselect()
       
        return true
    }
}

extension MainTabController: FeedControllerDelegate {
    func handleProfileImageTapped(_ controller: FeedController) {
        delegateCallBack?.handleProfileImageTapped(controller)
    }
    
    
}
