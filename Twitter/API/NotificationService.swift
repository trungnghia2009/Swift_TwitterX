//
//  NotificationService.swift
//  Twitter
//
//  Created by trungnghia on 5/26/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Firebase

struct NotificationService {
    
    static let shared = NotificationService()
    
    private init() {}
    
    func uploadNotification(type: NotificationType,
                            tweet: Tweet? = nil,
                            userID: String? = nil) {
        print("Debug: Type is \(type)")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let time: Int = Int(NSDate().timeIntervalSince1970)
        let prefixID: String = "\(10000000000 - time)-"
        
        var values: [String: Any] = ["timestamp": time,
                                     "uid": uid,
                                     "type": type.rawValue]
        
        let ID = prefixID + UUID().uuidString
        
        // Add tweetID key incase having tweet
        if let tweet = tweet {
            values["tweetID"] = tweet.tweetID
            kREF_NOTIFICATION.child(tweet.user.uid).child(ID).updateChildValues(values)
        } else if let userID = userID {
            kREF_NOTIFICATION.child(userID).child(ID).updateChildValues(values)
        }
    }
    
    func fetchNotifications(completion: @escaping ([Notification]) -> Void) {
        var notifications = [Notification]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Make sure notification exists for user
        kREF_NOTIFICATION.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                // This means user has no notifications
                completion(notifications)
            } else {
                kREF_NOTIFICATION.child(uid).observe(.childAdded) { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    guard let uid = dictionary["uid"] as? String else { return }
                    let notificationID = snapshot.key
                    
                    UserService.shared.fetchUser(uid: uid) { (user) in
                        let notification = Notification(notificationID: notificationID, user: user, dictionary: dictionary)
                        notifications.append(notification)
                        completion(notifications)
                    }
                }
            }
        }
    }
    
    func getNumberOfNotifications(completion: @escaping (UInt) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        kREF_NOTIFICATION.child(uid).observe(.value) { (snapshot) in
            completion(snapshot.childrenCount)
        }
    }
    
    func removeNotification(notificationID: String, completion: @escaping (DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        kREF_NOTIFICATION.child(uid).child(notificationID).removeValue(completionBlock: completion)
    }
    
    func removeAllNotifications(completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        kREF_NOTIFICATION.child(uid).removeValue(completionBlock: completion)
    }
    
    func removeNotificationObserver() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        kREF_NOTIFICATION.child(uid).removeAllObservers()
    }

    
}
