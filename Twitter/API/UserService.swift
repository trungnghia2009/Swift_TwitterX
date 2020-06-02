//
//  UserService.swift
//  Twitter
//
//  Created by trungnghia on 5/23/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Firebase

typealias DatabaseCompletion = ((Error?, DatabaseReference) ->Void)

struct UserService {
    
    static let shared = UserService()
    
    private init() {}
    
    func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        kREF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
           
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping ([User]) -> Void) {
        var users = [User]()
        
        kREF_USERS.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(uid: String, completion: @escaping (DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        print("Debug: Current uid \(currentUid) started following \(uid)")
        print("Debug: Uid \(uid) gained \(currentUid) as a follower")

        kREF_USER_FOLLOWING.child(currentUid).updateChildValues([uid: 1]) { (error, ref) in
            if let error = error {
                print("Debug: Error updating data to user-following, \(error.localizedDescription)")
                completion(error, ref)
                return
            }
            kREF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: 1]) { (error, ref) in
                NotificationService.shared.uploadNotification(type: .follow, userID: uid)
                completion(error, ref)
            }
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping (DatabaseCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        kREF_USER_FOLLOWING.child(currentUid).child(uid).removeValue { (error, ref) in
            if let error = error {
                completion(error, ref)
                return
            }
            kREF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        kREF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            print("Debug: User is followed is \(snapshot.exists())")
            completion(snapshot.exists())
        }
    }
    
    func fetchUserStats(uid: String, completion: @escaping(UserRelationStates) -> Void) {
        kREF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let folowers = snapshot.children.allObjects.count
            
            kREF_USER_FOLLOWING.child(uid).observe(.value) { (snapshot) in
                let folowing = snapshot.children.allObjects.count
                let stats = UserRelationStates(followers: folowers, following: folowing)
                completion(stats)
            }
        }
    }
    
    func saveUserData(user: User, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["fullname": user.fullname,
                     "username": user.username,
                     "bio": user.bio ?? "",
                     "profileImageUrl": user.profileImageUrl]
        
        kREF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        
    }
    
    func fetchUser(withUsername username: String, completion: @escaping(User) -> Void) {
        kREF_USER_USERNAMES.child(username).observeSingleEvent(of: .value) { (snapshot) in
            guard let uid = snapshot.value as? String else { return }
            
            self.fetchUser(uid: uid) { (user) in
                completion(user)
            }
        }
    }
    
    func fetchFollowing(withUser user: User, completion: @escaping([User]) -> Void) {
        var users = [User]()
        
        kREF_USER_FOLLOWING.child(user.uid).observe(.childAdded) { (snapshot) in
            let followingID = snapshot.key
            
            kREF_USERS.child(followingID).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var user = User(uid: followingID, dictionary: dictionary)
                user.isFollowed = true
                users.append(user)
                completion(users)
            }
        }
    }
    
    func fetchFollowers(withUser user: User, completion: @escaping([User]) -> Void) {
        var users = [User]()
        
        kREF_USER_FOLLOWERS.child(user.uid).observe(.childAdded) { (snapshot) in
            let followerID = snapshot.key
            
            kREF_USERS.child(followerID).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let uid = snapshot.key
                self.checkIfUserIsFollowed(uid: uid) { (bool) in
                    var user = User(uid: followerID, dictionary: dictionary)
                    user.isFollowed = bool
                    users.append(user)
                    completion(users)
                }
            }
        }
    }
    
    func fetchLikedUsers(withTweetID tweetID: String, completion: @escaping([User]) -> Void) {
        var users = [User]()
        
        kREF_TWEET_LIKES.child(tweetID).observe(.childAdded) { (snapshot) in
            let likedUserID = snapshot.key
            
            kREF_USERS.child(likedUserID).observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return}
                let uid = snapshot.key
                self.checkIfUserIsFollowed(uid: uid) { (bool) in
                    var user = User(uid: likedUserID, dictionary: dictionary)
                    user.isFollowed = bool
                    users.append(user)
                    completion(users)
                }
            }
        }
        
        
        
        
    }
    
    
    
}
