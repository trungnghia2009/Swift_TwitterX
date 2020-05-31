//
//  ProfileController.swift
//  Twitter
//
//  Created by trungnghia on 5/24/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifer = "TweetCell"
private let headerIndentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    //MARK: - Properties
    private var user: User
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet { collectionView.reloadData() }
    }
    
    private var tweets = [Tweet]()
    private var likedTweets = [Tweet]()
    private var replies = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
            
        case .tweets:
            return tweets
        case .replies:
            return replies
        case .likes:
            return likedTweets
        }
    }
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchTweets()
        fetchReplies()
        fetchLikedTweets()
        checkIfUserIsFollowed()
        fetchUserStats()
        logger("User is \(user.fullname)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black // adjust status bar color into white
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - API
    private func fetchTweets() {
        TweetService.shared.fetchTweets(forUser: user) { (tweets) in
            self.tweets = tweets
        }
    }
    
    private func fetchReplies() {
        TweetService.shared.fetchReplies(forUser: user) { (tweets) in
            self.replies = tweets
        }
    }
    
    private func fetchLikedTweets() {
        TweetService.shared.fetchLikes(forUser: user) { (tweets) in
            self.likedTweets = tweets
            self.logger("LikedTweets count is \(tweets.count)")
        }
    }
    
    private func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { (bool) in
            self.user.isFollowed = bool
            self.collectionView.reloadData()
        }
    }
    
    private func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { (stats) in
            self.logger("User has \(stats.followers) followers and \(stats.following) following")
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    
    //MARK: - Helpers
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never // cover header into status bar
        collectionView.showsVerticalScrollIndicator = false
        
        // Register cell and header
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifer)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIndentifier)
        
        //Fix tabBar overlapping collectionView content
        //guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        //collectionView.contentInset.bottom = tabHeight
    }
    
    //MARK: - Selectors
}

//MARK: - UICollectionViewDataSource/Delegate for cell
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifer, for: indexPath) as! TweetCell
        cell.tweet = currentDataSource[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweet = currentDataSource[indexPath.item]
        let controller = TweetController(tweet: tweet)
        navigationController?.pushViewController(controller, animated: true)
        
    }
}


//MARK: - UICollectionViewDataSource/Delegate for header
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIndentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
}

//MARK: - UICollectionViewFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    //Size for header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat = 350
        if user.bio == nil {
            height -= 50
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    //Size for cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var height = viewModel.size(forWidth: view.frame.width).height
        
        if currentDataSource[indexPath.row].isReply {
            height = height + 15
        }
        
        return CGSize(width: view.frame.width, height: height + 72)
    }
}

//MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    func showProfileImage(_ header: ProfileHeader) {
        logger("Handle profile image tapped..")
        guard let user = header.user else { return }
        let controller = ProfileImageController(user: user)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // Get callback data from 2 level ProfileFilterView->ProfileHeader->ProfileController
    func didSelect(filter: ProfileFilterOptions) {
        logger("Did select filter: \(filter.description)")
        self.selectedFilter = filter
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
        logger("User is followed is \(user.isFollowed) before button tap")
        
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                if let error = error {
                    self.showError(withText: error.localizedDescription)
                    return
                }
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (error, ref) in
                if let error = error {
                    self.showError(withText: error.localizedDescription)
                    return
                }
                self.user.isFollowed = true
                self.collectionView.reloadData()
            }
        }
    }
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    
}

//MARK: - EditProfileControllerDelegate
extension ProfileController: EditProfileControllerDelegate {
    func handleLogout() {
        
        do {
            try Auth.auth().signOut()
            PresenterManager.shared.show(vc: .loginController)
        } catch let error {
            print("Failed to sign out with error, \(error.localizedDescription)")
        }
        
    }
    
    func controller(_ controller: EditProfileController, wantsToUpdate user: User) {
        self.user = user
        self.collectionView.reloadData()
    }
}

//MARK: - ProfileImageControllerDelegate
extension ProfileController: ProfileImageControllerDelegate {
    func controller(_ controller: ProfileImageController, wantsToUpdate user: User) {
        self.user = user
        self.collectionView.reloadData()
    }
}
