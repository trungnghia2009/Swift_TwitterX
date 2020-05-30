//
//  NotificationsController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {

    //MARK: - Properties
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

    
    //MARK: - API
    func fetchNotifications() {
        refreshControl?.beginRefreshing()
        NotificationService.shared.fetchNotifications { (notifications) in
            self.refreshControl?.endRefreshing()
            self.logger("Notifications count: \(notifications.count)")
            self.notifications = notifications
            self.checkIfUserIsFollowed(notifications: notifications)
            
        }
    }
    
    //MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func checkIfUserIsFollowed(notifications: [Notification]) {
        guard !notifications.isEmpty else {
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

}

//MARK: - UITableViewDataSource
extension NotificationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notifications.count == 0 {
            NotificationService.shared.removeNotificationObserver()
            tableView.setEmptyMessage("There is no notifications \nPlease come back to check later!")
        } else {
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
            
            NotificationService.shared.deleteNotification(notificationID: notification.notificationID) { (error, ref) in
                self.notifications.remove(at: indexPath.row)
                self.tableView.reloadData()
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
