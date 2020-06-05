//
//  ExploreController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "UserCell"

enum SearchControllerConfiguration {
    case messages
    case userSearch
}

protocol SearchControllerDelegate: class {
    func handleProfileImageTappedForExplore()
}

class SearchController: UITableViewController {

    //MARK: - Properties
    weak var delegate: SearchControllerDelegate?
    
    private let profileImageView = CustomProfileImageView(frame: .zero)
    
    var user: User? {
        didSet { profileImageView.user = user }
    }
    
    private let config: SearchControllerConfiguration
    
    private var users = [User]() {
        didSet { tableView.reloadData() }
    }
    
    private var filteredUsers = [User]() {
        didSet { tableView.reloadData() }
    }
    
    private var isSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController()
    
    
    //MARK: - Lifecycle
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - API
    private func fetchUsers() {
        logger("Call API for fetching all users..")
        UserService.shared.fetchUsers { (users) in
            self.users = users
            
            //Remove current UI if being in messages
            if self.config == .messages {
                for (index, user) in self.users.enumerated() {
                    if user.uid == AuthService.shared.currentUid {
                        self.users.remove(at: index)
                    }
                }
            }
            
        }
    }

    
    //MARK: - Helpers
    private func configureUI() {
        profileImageView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-settings-80"), style: .plain, target: self, action: #selector(handleRightBarTapped))
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        view.backgroundColor = .white
        navigationItem.title = config == .userSearch ? "Explore" : "New Messages"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissal))
            navigationItem.rightBarButtonItem = UIBarButtonItem()
        }
        
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user..."
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    
    //MARK: - Selectors
    @objc private func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            delegate?.handleProfileImageTappedForExplore()
        }
    }
    
    @objc private func handleRightBarTapped() {
        logger("Handle right bar tapped..")
    }

}

//MARK: - UITableViewDataSource
extension SearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        let user = isSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SearchController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = isSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UISearchResultsUpdating
extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        filteredUsers = users.filter({ $0.username.localizedCaseInsensitiveContains(searchText) || $0.fullname.localizedCaseInsensitiveContains(searchText) })
        tableView.reloadData()
        
    }
}

//MARK: - CustomProfileImageViewDelegate
extension SearchController: CustomProfileImageViewDelegate {
    func handleProfileImageTapped() {
        delegate?.handleProfileImageTappedForExplore()
    }
}
