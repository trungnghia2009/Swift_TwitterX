//
//  MenuController.swift
//  Twitter
//
//  Created by trungnghia on 5/30/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "MenuCell"

protocol MenuControllerDelegate: class {
    func handleProfileImageTapped(_ header: MenuHeader)
    func handleFollowersTapped(_ header: MenuHeader)
    func handleFollowingTapped(_ header: MenuHeader)
    
    func handleMenuOption(_ controller: MenuController, option: MenuOptions)
    func handleLeftSwipe()
}

class MenuController: UITableViewController {

    //MARK: - Properties
    weak var delegate: MenuControllerDelegate?
    
    var user: User {
        didSet {
            menuHeader.user = user
        }
    }
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0, y: 0,
                           width: view.frame.width - 80, height: 200)
        let view = MenuHeader(user: user, frame: frame)
        logger(withDebug: "in menuHeader with email \(user.email)..")
        return view
    }()
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        fetchUserStats()
    }
    
    
    //MARK: - API
    private func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { (stats) in
            self.logger("User has \(stats.followers) followers and \(stats.following) following")
            self.user.stats = stats
        }
    }
    
    //MARK: - Helpers
    private func configureUI() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(MenuCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
        menuHeader.delegate = self
    }
    
    
    //MARK: - Selectors
    @objc private func handleLeftSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            delegate?.handleLeftSwipe()
        }
    }
}


//MARK: - UITableViewDataSource
extension MenuController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuCell
        cell.option = MenuOptions.allCases[indexPath.row]
        return cell
    }
   
}

//MARK: - UITableViewDelegate
extension MenuController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = MenuOptions.allCases[indexPath.row]
        delegate?.handleMenuOption(self, option: option)
        
    }
}


//MARK: - MenuHeaderDelegate
extension MenuController: MenuHeaderDelegate {
    
    func handleProfileImageTapped(_ header: MenuHeader) {
        delegate?.handleProfileImageTapped(header)
    }
    
    func handleFollowersTapped(_ header: MenuHeader) {
        delegate?.handleFollowersTapped(header)
    }
    
    func handleFollowingTapped(_ header: MenuHeader) {
        delegate?.handleFollowingTapped(header)
    }
    
    
    
}
