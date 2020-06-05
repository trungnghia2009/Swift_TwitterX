//
//  NotificationsController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

protocol NotificationsControllerDelegate: class {
    func handleProfileImageTappedForNotifications()
}

class NotificationsController: UITableViewController {

    //MARK: - Properties
    weak var delegate: NotificationsControllerDelegate?
    
    private let profileImageView = CustomProfileImageView(frame: .zero)
    
    var user: User? {
        didSet { profileImageView.user = user }
    }
    
    var isRemoveObserver = false
    
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationService.shared.getNumberOfNotifications { (count) in
            self.tabBarController?.tabBar.items![2].badgeValue = count != 0 ? "\(count)" : nil
        }
    }

    
    //MARK: - API
    func fetchNotifications() {
        refreshControl?.beginRefreshing()
        NotificationService.shared.fetchNotifications { (notifications) in
            self.refreshControl?.endRefreshing()
            self.logger("Notifications count: \(notifications.count)")
            self.isRemoveObserver = true
            self.notifications = notifications.reversed()
            self.checkIfUserIsFollowed(notifications: self.notifications)
            
        }
    }
    
    //MARK: - Helpers
    private func configureUI() {
        profileImageView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Remove All", style: .plain, target: self, action: #selector(handleRightBarButtonTapped))
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func checkIfUserIsFollowed(notifications: [Notification]) {
        guard notifications.count != 0 else {
            logger("There is no notifications")
            return
        }
        
        for (index, notification) in notifications.enumerated() {
            if notification.type.rawValue == 0 {
                self.logger("Configure user followed for \(notification.user.username)")
                UserService.shared.checkIfUserIsFollowed(uid: notification.user.uid) { (bool) in
                    self.notifications[index].user.isFollowed = bool
                }
            }
        }
    }
    
    //MARK: - Selectors
    @objc private func handleRefresh() {
        fetchNotifications()
    }
    
    @objc private func handleRightBarButtonTapped() {
        logger("Handle right bar button tapped..")
        let alertController = UIAlertController(title: "Remove all notifications", message: "Are you sure you want to remove all notifications ?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Remove all", style: .destructive, handler: { (_) in
            NotificationService.shared.removeAllNotifications { (error, ref) in
                if let error = error {
                    self.showAlert(withMessage: error.localizedDescription)
                    return
                }
                self.notifications = []
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            delegate?.handleProfileImageTappedForNotifications()
        }
    }

}

//MARK: - UITableViewDataSource
extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notifications.count == 0 {
            logger("isRemoveObserver is \(isRemoveObserver)")
            navigationItem.rightBarButtonItem?.isEnabled = false
            if isRemoveObserver { NotificationService.shared.removeNotificationObserver() }
            tableView.setEmptyMessage("There is no notifications \nPlease come back to check later!")
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            tableView.restore()
        }
        
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notfication = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    
    //Remove notification
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notification = notifications[indexPath.row]
            
            NotificationService.shared.removeNotification(notificationID: notification.notificationID) { (error, ref) in
                self.notifications.remove(at: indexPath.row)
                self.fetchNotifications()
            }
            
        }
    }
    
    
}

//MARK: - UITableViewDelegate
extension NotificationsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let notification = notifications[indexPath.row]
        guard let tweetID = notification.tweetID else { return }
 
        TweetService.shared.fetchTweet(withTweetID: tweetID) { (tweet) in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}


//MARK: - CustomProfileImageViewDelegate
extension NotificationsController: CustomProfileImageViewDelegate {
    func handleProfileImageTapped() {
        delegate?.handleProfileImageTappedForNotifications()
    }
}

//MARK: - NotificationCellDelegate
extension NotificationsController: NotificationCellDelegate {
    func handleFollowTapped(_ cell: NotificationCell) {
        guard let user = cell.notfication?.user else { return }
        logger("Handle follow tapped for \(user.username)")
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                if let error = error {
                    self.showError(withText: error.localizedDescription)
                    return
                }
                cell.notfication?.user.isFollowed = false
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (error, ref) in
                if let error = error {
                    self.showError(withText: error.localizedDescription)
                    return
                }
                cell.notfication?.user.isFollowed = true
            }
        }
    }
    
    func handleProfileImageTapped(_ cell: NotificationCell) {
        logger("Handle profile image tapped..")
        guard let user = cell.notfication?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
