//
//  UserListController.swift
//  Twitter
//
//  Created by trungnghia on 6/2/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "UserListCell"

enum ListType: CustomStringConvertible {
    case following
    case followers
    case retweeted
    case liked
    
    var description: String {
        switch self {
        case .following:
            return "Following"
        case .followers:
            return "Fllowers"
        case .retweeted:
            return "Retweeted by"
        case .liked:
            return "Liked by"
        }
    }
}

protocol UserListControllerDelegate: class {
    func didSelect(user: User)
}

class UserListController: UITableViewController {
    
    //MARK: - Properties
    weak var delegate: UserListControllerDelegate?
    
    private var user: User?
    private var tweetID: String?
    private let type: ListType
    
    private var users = [User]() {
        didSet { tableView.reloadData() }
    }
    

    //MARK: - Lifecycle
    init(user: User? = nil, tweetID: String? = nil, type: ListType) {
        self.user = user
        self.tweetID = tweetID
        self.type = type
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    
    //MARK: - API
    private func fetchFollowing() {
        guard let user = user else { return }
        UserService.shared.fetchFollowing(withUser: user) { (users) in
            self.users = users
        }
    }
    
    private func fetchFollowers() {
        guard let user = user else { return }
        UserService.shared.fetchFollowers(withUser: user) { (users) in
            self.users = users
            
        }
    }
    
    private func fetchLikedUsers() {
        guard let tweetID = tweetID else { return }
        UserService.shared.fetchLikedUsers(withTweetID: tweetID) { (users) in
            self.users = users
        }
    }
    
    
    
    //MARK: - Helpers
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"),
                                                           style: .plain, target: self, action: #selector(handleLeftBarTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.badge.plus"),
                                                            style: .plain, target: self, action: #selector(handleRightBarTapped))
        navigationItem.title = type.description
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UserListCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func fetchUsers() {
        switch type {
            
        case .following:
            fetchFollowing()
        case .followers:
            fetchFollowers()
        case .retweeted:
            break
        case .liked:
            fetchLikedUsers()
        }
    }
    
    
    //MARK: - Selectors
    @objc private func handleRightBarTapped() {
        logger("Handle right bar button tapped..")
    }
    
    @objc private func handleLeftBarTapped() {
        navigationController?.popViewController(animated: true)
    }

}


//MARK: - UITableViewDataSource
extension UserListController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count == 0 {
            tableView.setEmptyMessage("There is no \(type.description)\nPlease come back to check later!")
        } else {
            tableView.restore()
        }
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserListCell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let user = users[indexPath.row]
        var bioHeight = sizeForText(withText: user.bio ?? "", forWidth: view.frame.width - 76, fontSize: 14).height
        if user.bio != nil {
            bioHeight -= 5
        }
        
        return bioHeight + 70
    }
}


//MARK: - UITableDelegate
extension UserListController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logger("Selected cell \(indexPath.row)")
        let controller = ProfileController(user: users[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = #colorLiteral(red: 0.6719374925, green: 0.894341426, blue: 0.9568627477, alpha: 1)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (_) in
            cell?.contentView.backgroundColor = .white
        }
    }
}


//MARK: - UserListCellDelegate
extension UserListController: UserListCellDelegate {
    func handleFollowTapped(_ cell: UserListCell) {
        guard let uid = cell.user?.uid else { return }
        
        for (index, user) in users.enumerated() {
            if user.uid == uid {
                if self.users[index].isFollowed {
                    //unfollow
                    UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                        if let error = error {
                            self.showAlert(withMessage: error.localizedDescription)
                            return
                        }
                        self.users[index].isFollowed.toggle()
                    }
                } else {
                    //follow
                    UserService.shared.followUser(uid: user.uid) { (error, ref) in
                        if let error = error {
                            self.showAlert(withMessage: error.localizedDescription)
                            return
                        }
                        self.users[index].isFollowed.toggle()
                    }
                }
            }
        }
        
    }
    

    
    
}
