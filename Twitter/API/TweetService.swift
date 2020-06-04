//
//  TweetService.swift
//  Twitter
//
//  Created by trungnghia on 5/23/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Firebase

struct TweetService {
    
    static let shared = TweetService()
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let time: Int = Int(NSDate().timeIntervalSince1970)
        let prefixID: String = "\(10000000000 - time)-"
        
        var values = ["uid": uid,
                      "timestamp": time,
                      "replies": 0,
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String : Any]
 
        switch type {
            
        case .tweet:
            // childByAutoId() create unique identifier by ramdom
            let ID = prefixID + UUID().uuidString
            kREF_TWEETS.child(ID).updateChildValues(values) { (error, ref) in
                
                // update user-tweets structure after tweet upload completes
                guard let tweetID = ref.key else { return }
                
                //guard let dictionary = ref.value(forKey: "caption") else { return }
                
                kREF_USER_TWEETS.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
                
                
            }
        case .reply(let tweet):
            // add replyingTo key incase .reply
            values["replyingTo"] = tweet.user.username
            let ID = prefixID + UUID().uuidString
            kREF_TWEET_REPLIES.child(tweet.tweetID).child(ID).updateChildValues(values) { (error, ref) in
                
                // upload user-replies
                guard let replyKey = ref.key else { return }
                kREF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetID: replyKey])
                
                // update reply amount
                kREF_TWEETS.child(tweet.tweetID).updateChildValues(["replies": tweet.replies + 1])
                
                //Add notification to database
                NotificationService.shared.uploadNotification(type: .reply, tweet: tweet)
                completion(error, ref)
            }
        }
        
    }
    
    // Fetch all tweets
    func fetchTweets(completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        kREF_TWEETS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            // Fetch user for each tweet
            UserService.shared.fetchUser(uid: uid) { (user) in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    // Fetch tweets belong to users are followed
    func fetchTweetsFollowing(completion: @escaping ([Tweet]) ->Void) {
        var tweets = [Tweet]()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        //Fetch following tweets
        kREF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { (snapshot) in
            let followingUid = snapshot.key
            
            kREF_USER_TWEETS.child(followingUid).observe(.childAdded) { (snapshot) in
                let tweetID = snapshot.key
                self.fetchTweet(withTweetID: tweetID) { (tweet) in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
        //Fetch current user tweets
        kREF_USER_TWEETS.child(currentUid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { (tweet) in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    
    func fetchLikes(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        kREF_USER_LIKES.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            print("Debug: Key is \(tweetID)")
            self.fetchTweet(withTweetID: tweetID) { (tweet) in
                var likedTweet = tweet
                likedTweet.isLiked = true
                tweets.append(likedTweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping([Tweet]) ->Void) {
        var tweets = [Tweet]()
        
        kREF_USER_TWEETS.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetID = snapshot.key
            
            kREF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetID tweetID: String, completion: @escaping (Tweet) -> Void) {
        kREF_TWEETS.child(tweetID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            // Fetch user for tweet
            UserService.shared.fetchUser(uid: uid) { (user) in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                completion(tweet)
            }
        
        }
    }
    
    func fetchReplies(forTweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        kREF_TWEET_REPLIES.child(tweet.tweetID).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            // Fetch user for each tweet
            UserService.shared.fetchUser(uid: uid) { (user) in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        kREF_USER_REPLIES.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            
            if replyKey.contains("retweet") {
                
            } else {
                
            }
            
            kREF_TWEET_REPLIES.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                let replyID = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { (user) in
                    let reply = Tweet(user: user, tweetID: replyID, dictionary: dictionary)
                    tweets.append(reply)
                    completion(tweets)
                }
            }
        }
    }
    
    func likeTweet(tweet: Tweet, completion: @escaping(DatabaseCompletion)){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Add or subtract like on specific tweet
        let likes = tweet.isLiked ? tweet.likes - 1 : tweet.likes + 1
        kREF_TWEETS.child(tweet.tweetID).child("likes").setValue(likes)
        
        if tweet.isLiked {
            // Remove like data from firebase
            kREF_USER_LIKES.child(uid).child(tweet.tweetID).removeValue { (error, ref) in
                if let error = error {
                    completion(error, ref)
                    return
                }
                kREF_TWEET_LIKES.child(tweet.tweetID).child(uid).removeValue(completionBlock: completion)
            }
        } else {
            // Add like data to firebase
            kREF_USER_LIKES.child(uid).updateChildValues([tweet.tweetID: 1]) { (error, ref) in
                if let error = error {
                    completion(error, ref)
                    return
                }
                kREF_TWEET_LIKES.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedTweet(tweet: Tweet, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        kREF_USER_LIKES.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
        
    }
    
    func retweetWithOutComment(tweet: Tweet, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let prefix = tweet.tweetID.components(separatedBy: "-")[0]
        let newPrefix = String(Int(tweet.tweetID.components(separatedBy: "-")[0])! - 1)

        let retweetID = tweet.tweetID.replacingOccurrences(of: prefix, with: newPrefix, options: .literal, range: nil) + "-retweet"
        
        kREF_USER_TWEETS.child(uid).updateChildValues([retweetID: 1])
        kREF_USER_REPLIES.child(uid).updateChildValues([retweetID: tweet.tweetID])
        kREF_TWEET_RETWEETS.child(tweet.tweetID).updateChildValues([uid: 1])
    }
    
    
}
