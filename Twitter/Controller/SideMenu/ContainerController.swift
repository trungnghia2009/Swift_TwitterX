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
    
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            mainTabController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHideStatusBar
    }
    
    // configure animation for statusBar
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    
    //MARK: - API
    func checkIfUserIsLoggedIn() {
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
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { (user) in
            self.user = user
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
       }
    
    private func animateStatusBar() {
        UIView.animate(withDuration: 0.5) {
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
    
    
    //MARK: - Selectors
    @objc private func dismissMenu() {
        print("Debug: handle dismissMenu....")
        isHideStatusBar = false
        animateMenu(shouldExpand: false)
    }

}

//MARK: - MainTabControllerDelegate
extension ContainerController: MainTabControllerDelegate {
    func handleProfileImageTapped(_ controller: FeedController) {
        isHideStatusBar = true
        animateMenu(shouldExpand: true)
        
        //Fetch stats for follow incase clicking profileImage
        guard let user = user else { return }
        UserService.shared.fetchUserStats(uid: user.uid) { (stats) in
            self.logger("User has \(stats.followers) followers and \(stats.following) following")
            self.menuController.user.stats = stats
        }
    }
    
}

//MARK: - MenuControllerDelegate
extension ContainerController: MenuControllerDelegate {
    func handleProfileImageTapped(_ header: MenuHeader) {
        animateMenu(shouldExpand: false) { (_) in
            let controller = ProfileController(user: header.user)
            let nav = UINavigationController(rootViewController: controller)
            self.navigationController?.pushViewController(nav, animated: true)
            
        }
        
    }
    
    
}
