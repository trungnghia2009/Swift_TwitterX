//
//  RegisterController.swift
//  Twitter
//
//  Created by trungnghia on 5/22/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {
    
    //MARK: - Properties
    private var profileImage: UIImage?
    private var viewModel = RegistrationViewModel()
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.clipsToBounds = true // Fit image to border
        button.setDimensions(width: 150, height: 150)
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x-1"), textField: emailTextField)
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        return tf
    }()
    
    private lazy var passwordContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        tf.returnKeyType = .next
        return tf
    }()
    
    private lazy var fullnameContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTextField)
    private let fullnameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Full Name")
        tf.returnKeyType = .next
        return tf
    }()
    
    private lazy var usernameContainerView = InputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: usernameTextField)
    private let usernameTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Username")
        tf.returnKeyType = .done
        return tf
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 5
        button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleRegistration), for: .touchUpInside)
        button.accessibilityIdentifier = "SignInBtn"
        return button
    }()
    
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                                                           .foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                                                                 .foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotificationObservers()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        fullnameTextField.delegate = self
        usernameTextField.delegate = self
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barStyle = .default
    }
    
    //MARK: - Helpers
    private func configureUI() {
        
        view.backgroundColor = .twitterBlue
        dismissKeyboardIfTappingOutside()
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view, top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 8)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   fullnameContainerView,
                                                   usernameContainerView,
                                                   signInButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 16, paddingLeft: 32, paddingRight: 32)
        
    }
    
    private func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    //MARK: - Selectors
    @objc private func handleSelectPhoto() {
        logger("Handle Select photo..")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func handleRegistration() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let fullname = fullnameTextField.text!
        let username = usernameTextField.text!
        
        showLoader(true, withText: "Uploading image...")
        AuthService.shared.uploadImageToFireStore(withEmail: email, withImage: profileImage) { (error, url) in
            self.showLoader(false)
            if let error = error {
                self.showAlert(withMessage: error.localizedDescription)
                return
            }
            
            let credentials = RegistrationCredentials(email: email, password: password, fullname: fullname, username: username, profileImageUrl: url)
            
            self.showLoader(true, withText: "Creating user...")
            AuthService.shared.createUser(withCredentials: credentials) { (error, ref) in
                self.showLoader(false)
                if let error = error {
                    self.showAlert(withMessage: error.localizedDescription)
                    return
                }
                
                // configure UI for SignIn
//                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
//                    let window = sceneDelegate.window?.rootViewController as? MainTabController {
//                    window.authenticateUserAndConfigureUI()
//                }
//
//                self.dismiss(animated: true, completion: nil)
                PresenterManager.shared.show(vc: .containerController)
            }
        }
    }
    
    @objc private func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func textDidChange(sender: UITextField) {
        switch sender {
        
        case emailTextField:
            viewModel.email = sender.text
        case passwordTextField:
            viewModel.password = sender.text
        case fullnameTextField:
            viewModel.fullname = sender.text
        
        default:
            viewModel.username = sender.text
        }
        checkFormStatus()
    }
    
    @objc private func keyboardWillShow() {
        print("Keyboard will show")
        // For iPhone 6s,7,8
        if view.frame.size.height == 667 {
            view.frame.origin.y = -110
        } else {
            view.frame.origin.y = -50
        }
    }
    
    @objc private func keyboardWillHide() {
        print("Keyboard will hide")
        view.frame.origin.y = 0
        
    }
    
}


//MARK: - UIImagePickerControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        profileImage = image
        plusPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 3.0
        plusPhotoButton.layer.cornerRadius = 150 / 2
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - AuthenticationControllerProtocol
extension RegistrationController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if viewModel.formIsValid {
            signInButton.isEnabled = true
            signInButton.backgroundColor = .white
        } else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
}


//MARK: - UITextFieldDelegate
extension RegistrationController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            fullnameTextField.becomeFirstResponder()
        case fullnameTextField:
            usernameTextField.becomeFirstResponder()
            
        default:
            usernameTextField.resignFirstResponder()
            perform(#selector(handleRegistration))
        }
        
        return true
    }
}
