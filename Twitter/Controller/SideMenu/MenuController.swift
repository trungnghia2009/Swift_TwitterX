//
//  MenuController.swift
//  Twitter
//
//  Created by trungnghia on 5/30/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MenuCell"

protocol MenuControllerDelegate: class {
    func handleProfileImageTapped(_ header: MenuHeader)
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
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
        menuHeader.delegate = self
    }
    
    
    //MARK: - Selectors
    
}


//MARK: - UITableViewDataSource
extension MenuController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Option \(indexPath.row)"
        return cell
    }
   
}

//MARK: - UITableViewDelegate
extension MenuController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logger("Selected Option \(indexPath.row)")
    }
}


//MARK: - MenuHeaderDelegate
extension MenuController: MenuHeaderDelegate {
    func handleProfileImageTapped(_ header: MenuHeader) {
        delegate?.handleProfileImageTapped(header)
    }
    
    
}
