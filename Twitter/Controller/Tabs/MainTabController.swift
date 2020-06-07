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
    func handleProfileImageTappedForFeed()
    func handleProfileImageTappedForExplore()
    func handleProfileImageTappedForNotifications()
    func handleProfileImageTappedForConversation()
    func getIndexOfCurrentTab(index: Int)
}

class MainTabController: UITabBarController {
    
    //MARK: - Properties
    weak var delegateCallBack: MainTabControllerDelegate?
    var isFlip = false
    
    let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
    let explore = SearchController(config: .userSearch)
    let notifications = NotificationsController()
    let conversations = ConversationsController()
    
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
    var user: User? {
        didSet {
            guard let nav1 = viewControllers![0] as? UINavigationController else { return }
            guard let feed = nav1.viewControllers[0] as? FeedController else { return }
            feed.user = user
            
            guard let nav2 = viewControllers![1] as? UINavigationController else { return }
            guard let explore = nav2.viewControllers[0] as? SearchController else { return }
            explore.user = user
            
            guard let nav3 = viewControllers![2] as? UINavigationController else { return }
            guard let notifications = nav3.viewControllers[0] as? NotificationsController else { return }
            notifications.user = user
            
            guard let nav4 = viewControllers![3] as? UINavigationController else { return }
            guard let conversations = nav4.viewControllers[0] as? ConversationsController else { return }
            conversations.user = user
        }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0.05965350568, green: 0.5876290798, blue: 0.9076900482, alpha: 1)
        button.setImage(#imageLiteral(resourceName: "new_tweet"), for: .normal)
        button.addShadow()
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    //Add tabBar bounce effect
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }
        
        let timeInterval: TimeInterval = 0.3
        let propertyAnimator = UIViewPropertyAnimator(duration: timeInterval, dampingRatio: 0.5) {
            barItemView.transform = CGAffineTransform.identity.scaledBy(x: 1.25, y: 1.25)
        }
        propertyAnimator.addAnimations({ barItemView.transform = .identity }, delayFactor: CGFloat(timeInterval))
        propertyAnimator.startAnimation()
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        configureUI()
        fetchNotifications()
    }
    
    
    //MARK: - API
    private func fetchNotifications() {
        NotificationService.shared.getNumberOfNotifications { (count) in
            self.tabBar.items![2].badgeValue = count != 0 ? "\(count)" : nil
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
        feed.delegate = self
        explore.delegate = self
        notifications.delegate = self
        conversations.delegate = self
        
        let nav1 = templateNaviationController(image: UIImage(systemName: "house.fill")!, rootViewController: feed)
        let nav2 = templateNaviationController(image: UIImage(systemName: "magnifyingglass")!, rootViewController: explore)
        let nav3 = templateNaviationController(image: UIImage(systemName: "bell")!, rootViewController: notifications)
        let nav4 = templateNaviationController(image: UIImage(systemName: "envelope")!, rootViewController: conversations)

        viewControllers = [nav1, nav2, nav3, nav4]
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
        delegateCallBack?.getIndexOfCurrentTab(index: index!)
        let imageName = index == 3 ? #imageLiteral(resourceName: "mail")  : #imageLiteral(resourceName: "new_tweet")
        
        buttonConfig = index == 3 ? .message : .tweet
        
        if index == 2 {
            notifications.fetchNotifications()
            tabBar.items![2].badgeValue = nil
        }
        
        if index == 3 {
            if !isFlip {
                UIView.animate(withDuration: 0, animations: {
                    self.actionButton.clearShadow()
                }) { (_) in
                    UIView.transition(with: self.actionButton, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                        self.actionButton.setImage(imageName, for: .normal)
                    }){ (_) in
                        self.actionButton.addShadow()
                    }
                }
            }
            isFlip = true
        } else {
            if isFlip {
                UIView.animate(withDuration: 0, animations: {
                    self.actionButton.clearShadow()
                }) { (_) in
                    UIView.transition(with: self.actionButton, duration: 0.3, options: .transitionFlipFromRight, animations: {
                        self.actionButton.setImage(imageName, for: .normal)
                    }){ (_) in
                        self.actionButton.addShadow()
                    }
                }
            }
            isFlip = false
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

//MARK: - FeedControllerDelegate
extension MainTabController: FeedControllerDelegate {
    func handleProfileImageTappedForFeed() {
        delegateCallBack?.handleProfileImageTappedForFeed()
    }
}

//MARK: - FeedControllerDelegate
extension MainTabController: SearchControllerDelegate {
    func handleProfileImageTappedForExplore() {
        delegateCallBack?.handleProfileImageTappedForExplore()
    }
}

extension MainTabController: NotificationsControllerDelegate {
    func handleProfileImageTappedForNotifications() {
        delegateCallBack?.handleProfileImageTappedForNotifications()
    }
}

extension MainTabController: ConversationsControllerDelegate {
    func handleProfileImageTappedForConversations() {
        delegateCallBack?.handleProfileImageTappedForConversation()
    }
}
