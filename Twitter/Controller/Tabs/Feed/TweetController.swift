//
//  TweetDetailController.swift
//  Twitter
//
//  Created by trungnghia on 5/25/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let headerIndentifier = "TweetHeader"
private let reuseIdentifier = "TweetCell"

class TweetController: UICollectionViewController {
    
    //MARK: - Properties
    private let tweet: Tweet
    private var actionSheetLauncher: ActionSheetLauncher!
    var replies = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
    
    //MARK: - Lifecycle
    init(tweet: Tweet) {
        self.tweet = tweet
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchReplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    
    //MARK: - API
    private func fetchReplies() {
        TweetService.shared.fetchReplies(forTweet: tweet) { (replies) in
            self.replies = replies
        }
    }
    

    //MARK: - Helpers
    private func configureCollectionView(){
        collectionView.backgroundColor = .white
        navigationItem.title = "Tweet"
        
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIndentifier)
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
    }
    
    private func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
    
    //MARK: - Selectors
}


//MARK: - UICollectionViewDataSoure for Cell
extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = replies[indexPath.item]
        return cell
    }
}

//MARK: - UICollectionViewDataSource for Header
extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIndentifier, for: indexPath) as! TweetHeader
        header.tweet = tweet
        header.delegate = self
        return header
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TweetController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: tweet)
        //let height = viewModel.size(forWidth: view.frame.width).height
        let height = viewModel.sizeForTweetCaption(forWidth: view.frame.width - 32, fontSize: 18).height
        return CGSize(width: view.frame.width, height: height + 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

//MARK: - TweetHeaderDelegate
extension TweetController: TweetHeaderDelegate {
    func handleLikedUsersTapped(_ header: TweetHeader) {
        guard let tweetID = header.tweet?.tweetID else { return }
        let controller = UserListController(tweetID: tweetID, type: .liked, from: .others)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleFetchUser(withUsername username: String) {
        self.logger("Go to user profile for \(username)")
        UserService.shared.fetchUser(withUsername: username) { (user) in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleProfileImageTapped(_ header: TweetHeader) {
        guard let user = header.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // Remember to initilize ActionSheetLauncher() after tapping actionSheet button
    func showActionSheet() {
        logger("Handle action sheet..")
        if tweet.user.isCurrentUser {
            showActionSheet(forUser: tweet.user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: tweet.user.uid) { (bool) in
                var user = self.tweet.user
                user.isFollowed = bool
                self.showActionSheet(forUser: user)
            }
        }
        
    }
}

//MARK: - ActionSheetLauncherDelegate
extension TweetController: ActionSheetLauncherDelegate {
    func didSelectOption(option: ActionSheetOptions) {
        logger("Handle action sheet option..")
        switch option {
            
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { (error, ref) in
                if let error = error {
                    self.showError(withText: error.localizedDescription)
                    return
                }
                self.logger("Did follow \(user.username)")
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                if let error = error {
                    self.showError(withText: error.localizedDescription)
                    return
                }
                self.logger("Did unfollow \(user.username)")
            }
        case .report:
            logger("Report tweet")
        case .delete:
            logger("Delete tweet")
        }
    }
    
    
}
