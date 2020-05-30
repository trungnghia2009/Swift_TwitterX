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

class MainTabController: UITabBarController {
    
    //MARK: - Properties
    private let notifications = NotificationsController()
    
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
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //signOut()
        authenticateUserAndConfigureUI()
        
    }
    
    
    //MARK: - API
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { (user) in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            logger("User is not logged in..")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            logger("User is logged in..")
            configureViewControllers()
            configureUI()
            fetchUser()
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            logger("Failed to sign out with error, \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - Helpers
    private func configureUI() {
        self.delegate = self
        
        view.addSubview(actionButton)
        actionButton.setDimensions(width: 56, height: 56)
        actionButton.layer.cornerRadius = 28
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16)
    }
    
    private func configureViewControllers() {
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav1 = templateNaviationController(image: UIImage(systemName: "house.fill")!, rootViewController: feed)
        
        let explore = SearchController(config: .userSearch)
        let nav2 = templateNaviationController(image: UIImage(systemName: "magnifyingglass")!, rootViewController: explore)
        
        //let notifications = NotificationsController()
        let nav3 = templateNaviationController(image: UIImage(systemName: "heart")!, rootViewController: notifications)
        
        let conversations = ConversationsController()
        let nav4 = templateNaviationController(image: UIImage(systemName: "envelope")!, rootViewController: conversations)

        viewControllers = [nav1, nav2, nav3, nav4]
        tabBar.items![3].badgeValue = "2"
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
