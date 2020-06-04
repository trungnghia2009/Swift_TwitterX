//
//  Constants.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Firebase

let kSTORAGE_REF = Storage.storage().reference()
let kSTORAGE_PROFILE_IMAGES = kSTORAGE_REF.child("profile_images")

let kDB_REF = Database.database().reference()
let kREF_USERS = kDB_REF.child("users")
let kREF_TWEETS = kDB_REF.child("tweets")
let kREF_USER_TWEETS = kDB_REF.child("user-tweets")
let kREF_USER_FOLLOWERS = kDB_REF.child("user-followers")
let kREF_USER_FOLLOWING = kDB_REF.child("user-following")
let kREF_TWEET_REPLIES = kDB_REF.child("tweet-replies")
let kREF_USER_LIKES = kDB_REF.child("user-likes")
let kREF_TWEET_LIKES = kDB_REF.child("tweet-likes")
let kREF_TWEET_RETWEETS = kDB_REF.child("tweet-retweets")
let kREF_NOTIFICATION = kDB_REF.child("notifications")
let kREF_USER_REPLIES = kDB_REF.child("user-replies")
let kREF_USER_USERNAMES = kDB_REF.child("user-usernames")
