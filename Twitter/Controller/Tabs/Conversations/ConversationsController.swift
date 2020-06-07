//
//  ConversationsController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ConversationCell"

protocol ConversationsControllerDelegate {
    func handleProfileImageTappedForConversations()
}

class ConversationsController: UIViewController {

    //MARK: - Properties
    weak var delegate: NotificationsControllerDelegate?
    
    private let profileImageView = CustomProfileImageView(frame: .zero)
    
    var user: User? {
        didSet { profileImageView.user = user }
    }
    
    private let tableView = UITableView()
    private var conversations = [Conversation]()
    private var converstaionsDictionary = [String: Conversation]()  // this for avoding duplicate message because of addSnapshotListener
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
        fetchConversations()
    }

    //MARK: - API
    private func fetchConversations() {
        MessageService.shared.fetchConversation { (conversations, error) in
            conversations.forEach { (conversation) in
                let message = conversation.message
                self.converstaionsDictionary[message.chatPartnerId] = conversation
            }
            
            self.conversations = Array(self.converstaionsDictionary.values).sorted(by: { $0.message.timestamp.dateValue() > $1.message.timestamp.dateValue() })
            self.tableView.reloadData()
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
        navigationItem.title = "Messages"
        
    }
    
    private func configureTableView() {
        tableView.backgroundColor = #colorLiteral(red: 0.9474738261, green: 0.9474738261, blue: 0.9474738261, alpha: 1)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.register(ConversationCell.self, forCellReuseIdentifier: reuseIdentifier) //Define reuseCell identifier
        tableView.tableFooterView = UIView() //Remove the separation between cells
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
    
    
    //MARK: - Selectors
    @objc private func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            delegate?.handleProfileImageTappedForNotifications()
        }
    }
    
    @objc private func handleRightBarTapped() {
        logger("Handle right bar tapped..")
    }
    
}


//MARK: - CustomProfileImageViewDelegate
extension ConversationsController: CustomProfileImageViewDelegate {
    func handleProfileImageTapped() {
        delegate?.handleProfileImageTappedForNotifications()
    }
}

//MARK: - UITableViewDataSource
extension ConversationsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ConversationCell
        cell.conversation = conversations[indexPath.row]
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ConversationsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = conversations[indexPath.row].user
        let controller = MessageController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
