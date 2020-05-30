//
//  AuthService.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

struct RegistrationCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    var profileImageUrl: String?
}

struct AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    let auth = Auth.auth()
    
    func loginUser(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        auth.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func uploadImageToFireStore(withEmail email: String, withImage image: UIImage?, completion: @escaping (Error?, String?) -> Void) {
        var profileImageUrl: String?
        let error: Error? = nil
        if let image = image?.resizeWithWidth(width: 600.0) {
            let imageData = image.jpegData(compressionQuality: 0.8)!
            let fileName = email + "_avatar.jpg"
            
            let ref = Storage.storage().reference(withPath: "/profile_images/\(fileName)")
            
            ref.putData(imageData, metadata: nil) { (meta, error) in
                if let error = error {
                    completion(error, profileImageUrl)
                    return
                }
                
                ref.downloadURL { (url, error) in
                    if let error = error {
                        completion(error, profileImageUrl)
                        return
                    }
                    
                    profileImageUrl = url?.absoluteString
                    completion(error, profileImageUrl)
                }
            }
        } else {
            completion(error, profileImageUrl)
        }
    }
    
    
    func createUser(withCredentials credentials: RegistrationCredentials, completion: @escaping (Error?, DatabaseReference?) -> Void) {
        let databaseReference: DatabaseReference? = nil
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
            if let error = error {
                completion(error, databaseReference)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let data = ["email": credentials.email,
                        "fullname": credentials.fullname,
                        "username": credentials.username,
                        "profileImageUrl": credentials.profileImageUrl ?? ""] as [String : Any]
            
            // Add user record to database
            kREF_USERS.child(uid).updateChildValues(data) { (error, data) in
                if let error = error {
                    completion(error, databaseReference)
                    return
                }
                completion(error, data)
                
            }
            
            // Add user-username to database, using for mention
            let usernameData = [credentials.username: uid]
            kREF_USER_USERNAMES.updateChildValues(usernameData)

        }
        
    }
    
    
}

extension UIImage {
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

