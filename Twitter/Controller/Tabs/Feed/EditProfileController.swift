//
//  EditProfileController.swift
//  Twitter
//
//  Created by trungnghia on 5/28/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "EditProfileCell"

protocol EditProfileControllerDelegate: class {
    func controller(_ controller: EditProfileController, wantsToUpdate user: User)
    func handleLogout()
}

class EditProfileController: UITableViewController {

    //MARK: - Properties
    weak var delegate: EditProfileControllerDelegate?
    
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private let footerView = EditProfileFooter()
    private let imagePicker = UIImagePickerController()
    private var selectedImage: UIImage? {
        didSet {
            headerView.profileImageView.image = selectedImage
            //Turn flag to upload image
        }
    }
    
    private var isUploadImage = false
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardIfTappingOutside()
        configureImagePicker()
        configureNavigationBar()
        configureTableView()
    }
    

    
    //MARK: - API
    
    
    //MARK: - Helpers
    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    private func configureTableView() {
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        
        footerView.delegate = self
        tableView.tableFooterView = footerView
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        tableView.isScrollEnabled = false
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    //MARK: - Selectors
    @objc private func handleCancel() {
        delegate?.controller(self, wantsToUpdate: user)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleSave() {
        
        showLoader(true, withText: "Profile Updating...")
        if isUploadImage {
            AuthService.shared.uploadImageToFireStore(withEmail: user.email, withImage: selectedImage) { (error, url) in
                if let error = error {
                    self.showAlert(withMessage: error.localizedDescription)
                    return
                }
                
                guard let url = url else { return }
                self.user.profileImageUrl = url
                
                UserService.shared.saveUserData(user: self.user) { (error, ref) in
                    self.showLoader(false)
                    self.logger("Update succeeded..")
                }
            }
        } else {
            UserService.shared.saveUserData(user: self.user) { (error, ref) in
                self.showLoader(false)
                self.logger("Update succeeded..")
            }
        }
        
        isUploadImage = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }

}

//MARK: - UITableViewDataSource
extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditProfileCell
        cell.delegate = self
        let option = EditProfileOptions.allCases[indexPath.row]
        let viewModel = EditProfileViewModel(user: user, option: option)
        cell.viewModel = viewModel
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let option = EditProfileOptions.allCases[indexPath.row]
        return option == .bio ? 100 : 48
    }
    
}


//MARK: - EditProfileHeaderDelegate
extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        logger("Handle change profile photo..")
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - EditProfileFooterDelegate
extension EditProfileController: EditProfileFooterDelegate {
    func handleLogout() {
        logger("Handle logout..")
        
        view.endEditing(false)
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to log out ?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            self.dismiss(animated: true) {
                self.delegate?.handleLogout()
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        selectedImage = image
        isUploadImage = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
}

extension EditProfileController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        guard let viewModel = cell.viewModel else { return }
        
        switch viewModel.option {
            
        case .fullname:
            guard let value = cell.getInfoTextField() else { return }
            user.fullname = value
        case .username:
            guard let value = cell.getInfoTextField() else { return }
            user.username = value
        case .bio:
            user.bio = cell.getBioTextView()
        }
        
        logger("Fullname is \(user.fullname)")
        logger("Username is \(user.username)")
        logger("Bio is \(user.bio ?? "")")
    }
    
    
}
