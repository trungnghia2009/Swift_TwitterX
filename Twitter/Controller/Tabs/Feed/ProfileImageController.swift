//
//  ProfileImageController.swift
//  Twitter
//
//  Created by trungnghia on 5/29/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

protocol ProfileImageControllerDelegate: class {
    func controller(_ controller: ProfileImageController, wantsToUpdate user: User)
}

class ProfileImageController: UIViewController {

    //MARK: - Properties
    weak var delegate: ProfileImageControllerDelegate?
    
    private var user: User
    private let imagePicker = UIImagePickerController()
    private var selectedImage: UIImage? {
        didSet { profileImageView.image = selectedImage }
    }
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .black
        iv.sd_setImage(with: URL(string: user.profileImageUrl))
        return iv
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.25
        button.addTarget(self, action: #selector(handleEditTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                                bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(editButton)
        editButton.setDimensions(width: 50, height: 30)
        editButton.layer.cornerRadius = 15
        editButton.centerX(inView: view)
        editButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 20)
        
        if Auth.auth().currentUser?.uid != user.uid {
            editButton.isHidden = true
        }
        
        configureImagePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    
    //MARK: - Helpers
    private func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    private func updateImageToFirestore() {
        showLoader(true, withText: "Profile updating...")
        AuthService.shared.uploadImageToFireStore(withEmail: user.email, withImage: selectedImage) { (error, url) in
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            guard let url = url else { return }
            self.user.profileImageUrl = url
            self.delegate?.controller(self, wantsToUpdate: self.user)
            
            UserService.shared.saveUserData(user: self.user) { (error, ref) in
                self.showLoader(false)
                self.navigationController?.popViewController(animated: true)
                self.logger("Update succeeded..")
            }
        }
    }
    
    
    //MARK: - Selectors
    @objc private func handleEditTapped() {
        logger("Handle edit tapped..")
        present(imagePicker, animated: true, completion: nil)
    }

}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProfileImageController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        selectedImage = image
        
        dismiss(animated: true) {
            self.updateImageToFirestore()
        }
        
        
    }
}
