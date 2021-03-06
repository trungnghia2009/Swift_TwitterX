//
//  ContainerController.swift
//  Twitter
//
//  Created by trungnghia on 5/30/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

class ContainerController: UIViewController {
    
    //MARK: - Properties
    private var mainTabController: MainTabController!
    private var menuController: MenuController!
    
    private var blackView = UIView()
    private var isHideStatusBar = false
    
    private var currentActiveNav: UINavigationController?
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            mainTabController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    private var barIndex: Int = 0
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .default
        checkIfUserIsLoggedIn()
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return isHideStatusBar
//    }
//
//    // configure animation for statusBar
//    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
//        return .slide
//    }
    
    
    //MARK: - API
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            logger("User is not logged in..")
            DispatchQueue.main.async {
                PresenterManager.shared.show(vc: .loginController)
            }
        } else {
            logger("User is logged in..")
            fetchUser()
            configureMainTabBarController()
        }
    }
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { (user) in
            self.user = user
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            PresenterManager.shared.show(vc: .loginController)
        } catch let error {
            print("Failed to sign out with error, \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - Helpers
    private func configureMainTabBarController() {
        mainTabController = MainTabController()
        mainTabController.delegateCallBack = self
        addChild(mainTabController)
        mainTabController.didMove(toParent: self)
        view.addSubview(mainTabController.view)
    }
    
    private func configureMenuController(withUser user: User) {
        menuController = MenuController(user: user)
        menuController.delegate = self
        let nav = UINavigationController(rootViewController: menuController)
        nav.didMove(toParent: self)
        view.insertSubview(nav.view, at: 0)
        configureBlackView()
    }
    
    private func configureBlackView() {
        
        blackView.frame = view.bounds
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        mainTabController.view.addSubview(blackView)
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleBlackViewLeftSwipe))
        leftSwipe.direction = .left
        blackView.addGestureRecognizer(leftSwipe)
    
       }
    
    private func animateStatusBar() {
        UIView.animate(withDuration: 0.1) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.mainTabController.view.frame.origin.x = self.view.frame.width - 80
                self.blackView.alpha = 1
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.mainTabController.view.frame.origin.x = 0
                self.blackView.alpha = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    private func presentMenu() {
        isHideStatusBar = true
        animateMenu(shouldExpand: true)
        
        //Fetch stats for follow incase clicking profileImage
        guard let user = user else { return }
        UserService.shared.fetchUserStats(uid: user.uid) { (stats) in
            self.logger("User has \(stats.followers) followers and \(stats.following) following")
            self.menuController.user.stats = stats
        }
    }
    
    private func pushToController(controller: UIViewController) {
        var parentController: UIViewController?
        switch barIndex {
        case 0:
            parentController = mainTabController.feed
        case 1:
            parentController = mainTabController.explore
        case 2:
            parentController = mainTabController.notifications
        case 3:
            parentController = mainTabController.conversations
        default:
            break
        }
        
        parentController?.navigationController?.pushViewController(controller, animated: true)
    }

    
    //MARK: - Selectors
    @objc private func dismissMenu() {
        print("Debug: handle dismissMenu....")
        isHideStatusBar = false
        animateMenu(shouldExpand: false)
    }
    
    @objc private func handleBlackViewLeftSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            animateMenu(shouldExpand: false)
        }
    }

}

//MARK: - MainTabControllerDelegate
extension ContainerController: MainTabControllerDelegate {
    func getIndexOfCurrentTab(index: Int) {
        barIndex = index
    }
    
    func handleProfileImageTappedForFeed() {
        presentMenu()
    }
    
    func handleProfileImageTappedForExplore() {
        presentMenu()
    }
    
    func handleProfileImageTappedForNotifications() {
        presentMenu()
    }
    
    func handleProfileImageTappedForConversation() {
        presentMenu()
    }
    
}

//MARK: - MenuControllerDelegate
extension ContainerController: MenuControllerDelegate {
    func handleLeftSwipe() {
        animateMenu(shouldExpand: false)
    }
    
    func handleMenuOption(_ controller: MenuController, option: MenuOptions) {
        self.isHideStatusBar = false
        animateMenu(shouldExpand: false) { (_) in
            
            switch option {
            case .profile:
                self.pushToController(controller: ProfileController(user: controller.user))
            case .lists:
                self.logger("Show lists..")
            case .logout:
                let alertController = UIAlertController(title: nil, message: "Are you sure you want to log out ?", preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
                    self.logout()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            case .bookmarks:
                self.logger("tapped bookmarks..")
            }
        }
        
    }
    
    func handleProfileImageTapped(_ header: MenuHeader) {
        isHideStatusBar = false
        animateMenu(shouldExpand: false)
        pushToController(controller: ProfileController(user: header.user))
        
    }
    
    func handleFollowersTapped(_ header: MenuHeader) {
        animateMenu(shouldExpand: false)
        pushToController(controller: UserListController(user: header.user, type: .followers))
        
    }
    
    func handleFollowingTapped(_ header: MenuHeader) {
        animateMenu(shouldExpand: false)
        pushToController(controller: UserListController(user: header.user, type: .following))
    }
    
    
}
