//
//  FeedController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "TweetCell"

protocol FeedControllerDelegate: class {
    func handleProfileImageTappedForFeed()
}

class FeedController: UICollectionViewController {

    //MARK: - Properties
    weak var delegate: FeedControllerDelegate?
    
    private let profileImageView = CustomProfileImageView(frame: .zero)
    
    var user: User? {
        didSet { profileImageView.user = user }
    }
    
    private var tweets = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
    
    private var isHideStatusBar = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweetsFollowing()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - API
    private func fetchTweetsFollowing() {
        // First, fetch all tweets
        // Second, fetch all likes
        collectionView.refreshControl?.beginRefreshing()
        TweetService.shared.fetchTweetsFollowing { (tweets) in
            self.collectionView.refreshControl?.endRefreshing()
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
               self.checkIfUserLikedTweets()
            }

        }
    }
    
    private func checkIfUserLikedTweets() {
        self.tweets.forEach { (tweet) in
            TweetService.shared.checkIfUserLikedTweet(tweet: tweet) { (bool) in
                if bool == false { return }
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.tweets[index].isLiked = true
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
        
        //Register cell
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0) //set spacing between collectionView and navigationBar is 10
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTweetLogoTapped))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        navigationItem.titleView = imageView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    
    //MARK: - Selectors
    @objc private func handleRefresh() {
        fetchTweetsFollowing()
    }
    
    @objc private func handleTweetLogoTapped() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc private func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            delegate?.handleProfileImageTappedForFeed()
        }
    }
    
    @objc private func handleRightBarTapped() {
        logger("Handle right bar tapped..")
    }

}


//MARK: - UICollectionViewDataSource
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.item]
        cell.delegate = self
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweet = tweets[indexPath.item]
        let controller = TweetController(tweet: tweet)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension FeedController: UICollectionViewDelegateFlowLayout {
    
    // Return the size for each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.sizeForTweetCaption(forWidth: view.frame.width - 80, fontSize: 14).height
        
        return CGSize(width: view.frame.width, height: height + 72)
    }
}
 
//MARK: - CustomProfileImageViewDelegate
extension FeedController: CustomProfileImageViewDelegate {
    func handleProfileImageTapped() {
        delegate?.handleProfileImageTappedForFeed()
    }
    
}

//MARK: - TweetCellDelegate
extension FeedController: TweetCellDelegate {
    func handleShareTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let shareContent = "From \(tweet.user.username) \n\(tweet.caption)"
        
        didSelectShareTweetAction({ (_) in
            self.logger("Handle Send via Direct message")
        }, { (_) in
            self.logger("Handle Add tweet to bookmarks")
        }, { (_) in
            self.logger("Handle Copy link to tweet")
        }) { (_) in
            UIApplication.share(shareContent)
        }
    }
    
    func handleActionSheet(_ cell: TweetCell) {
        guard let username = cell.tweet?.user.username else { return }
        guard let uid = cell.tweet?.user.uid else { return }
        
        if Auth.auth().currentUser?.uid != uid {
            didSelectTweetActionButton(forUsername: username, { (_) in
                self.logger("Handle Not interested..")
            }, { (_) in
                self.logger("Handle Unfollow..")
            }, { (_) in
                self.logger("Handle Mute..")
            }, { (_) in
                self.logger("Handle Block..")
            }) { (_) in
                self.logger("Handle Report..")
            }
        } else {
            didSelectUserTweetAction({ (_) in
                self.logger("Handle Pin to profile")
            }) { (_) in
                self.logger("Handle delele tweet")
            }
        }

    }
    
    func handleRetweetTapped(_ cell: TweetCell) {
        didSelectRetweet({ (_) in
            self.logger("Retweet..")
        }) { (_) in
            self.logger("Retweet with comment..")
        }
    
    }
    
    func handleFetchUser(withUsername username: String) {
        self.logger("Go to user profile for \(username)")
        UserService.shared.fetchUser(withUsername: username) { (user) in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let tweetID = tweet.tweetID
        cell.shouldEnableLikeButton(false)
        
        TweetService.shared.likeTweet(tweet: tweet) { (error, ref) in
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            let likes = tweet.isLiked ? tweet.likes - 1 : tweet.likes + 1
            
            for (index, tweet) in self.tweets.enumerated() {
                if tweet.tweetID == tweetID {
                    
                    //Only upload notification if tweet is being liked
                    if !tweet.isLiked {
                        NotificationService.shared.uploadNotification(type: .like, tweet: tweet)
                    }
                    
                    //Update object after Api call
                    self.tweets[index].likes = likes
                    self.tweets[index].isLiked.toggle()
                    cell.shouldEnableLikeButton(true)
                }
            }
        }
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}


//MARK: - TabBarReselectHandling
extension FeedController: TabBarReselectHandling {
    func handleReselect() {
        logger("Select feed Controller")
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
}

//MARK: - UploadTweetControllerDelegate
extension FeedController: UploadTweetControllerDelegate {
    func updateInfo(_ tweetID: String) {
        for (index, tweet) in self.tweets.enumerated() {
            if tweet.tweetID == tweetID {
                self.tweets[index].replies += 1
                return
            }
        }
    }
    
}

