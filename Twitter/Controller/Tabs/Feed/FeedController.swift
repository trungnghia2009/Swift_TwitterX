//
//  FeedController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "TweetCell"

protocol FeedControllerDelegate: class {
    func handleProfileImageTapped(_ controller: FeedController)
}

class FeedController: UICollectionViewController {

    //MARK: - Properties
    weak var delegate: FeedControllerDelegate?
    
    private let profileImageView = UIImageView()
    
    var user: User? {
        didSet { configureLeftBarButton() }
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
    
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
//            navigationController?.setNavigationBarHidden(true, animated: true)
//
//        } else {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//            isHideStatusBar = false
//        }
//    }
    
    
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
        
        profileImageView.backgroundColor = .white
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureLeftBarButton() {
        guard let user = user else { return }
        let url = URL(string: user.profileImageUrl)
        logger("Print \(user.profileImageUrl)")
        profileImageView.sd_setImage(with: url)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLeftBarButtonTapped))
        profileImageView.addGestureRecognizer(tap)
    }
    
    
    //MARK: - Selectors
    @objc private func handleLeftBarButtonTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc private func handleRefresh() {
        fetchTweetsFollowing()
    }
    
    @objc private func handleTweetLogoTapped() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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

//MARK: - TweetCellDelegate
extension FeedController: TweetCellDelegate {
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
