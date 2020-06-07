//
//  MessageService.swift
//  Twitter
//
//  Created by trungnghia on 6/5/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Firebase

struct MessageService {
    
    static let shared = MessageService()
    
    private init() {}
    
    func uploadMessage(_ message: String, toUser user: User, completion: ((Error?) -> Void)?) {
        guard  let currentUid = Auth.auth().currentUser?.uid else { return }
        let data = ["text": message,
                    "fromId": currentUid,
                    "toId": user.uid,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { (_) in
            COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data, completion: completion)
            
            //upload recent message for sender and receiver, overide to latest message
            COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)
            COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data)
            
        }
    }
    
    
    func fetchMessages(forUser user: User, completion: @escaping (_ messages: [Message], _ error: Error?) -> Void) {
        var messages = [Message]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        print("Debug: CurrentUid is \(currentUid)")
        let query = COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(messages, error)
                return
            }
            
            snapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let dictionary = change.document.data()
                    messages.append(Message(dictionary: dictionary))
                }
            })
            completion(messages, error)
        }
    }
    
    func fetchConversation(completion: @escaping (_ conversations: [Conversation], _ error: Error?) -> Void) {
        var conversations = [Conversation]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(conversations, error)
                return
            }
            
            snapshot?.documentChanges.forEach({ (change) in
                let dictionary = change.document.data()
                let message = Message(dictionary: dictionary)
                
                UserService.shared.fetchUser(uid: change.document.documentID) { (user) in
                    let conversation = Conversation(user: user, message: message)
                                       conversations.append(conversation)
                                       completion(conversations, error)
                }
            })
            
           
        }
    }
    
}
