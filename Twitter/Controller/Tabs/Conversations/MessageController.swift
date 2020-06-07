//
//  ChatController.swift
//  Twitter
//
//  Created by trungnghia on 6/5/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MessageCell"

class MessageController: UICollectionViewController {

    //MARK: - Properties
    private let user: User
    private var messages = [Message]()
    var height: CGFloat = 0
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50)) // Need to check with: let iv = CustomInputAccessoryView()
        iv.delegate = self
        return iv
    }()
    
    //MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        configureUI()
        fetchMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldHideActionButton(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldHideActionButton(false)
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool { // Need this for inputAccessoryView
        return true
    }
    
    
    //MARK: - API
    
    
    //MARK: - Helpers
    private func configureUI() {
        dismissKeyboardIfTappingOutside()
        navigationItem.title = "@\(user.username)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_arrow_back_white_24dp"), style: .plain, target: self, action: #selector(handleLeftBarButton))
        
        collectionView.backgroundColor = .white
        collectionView!.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        
        //dismiss keyboard if scroll in message view
        collectionView.keyboardDismissMode = .interactive
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    private func fetchMessage() {
        showLoader(true)
        MessageService.shared.fetchMessages(forUser: user) { (messages, error) in
            self.showLoader(false)
            if let error = error {
                print("Debug: Failed to fetch messages \(error.localizedDescription)")
                self.showError(withText: error.localizedDescription)
                return
            }
            
            self.messages = messages
            self.collectionView.reloadData()
            
            //Scroll to latest message
            self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: false)
        }
    }
    
    //MARK: - Selectors
    @objc private func handleLeftBarButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func keyboardShow(notification: NSNotification) {
        print("Keyboard show notification")
        
        
        if let userInfo = notification.userInfo,
            
            let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            print("Debug: \(keyboardRectangle.height)")
            
                
            if keyboardRectangle.height > 100 {
                let bottomOffset = CGPoint(x: 0, y: collectionView.contentSize.height - keyboardRectangle.height - height)
                collectionView.setContentOffset(bottomOffset, animated: true)
                
            } else {
                height = keyboardRectangle.height
            }
        }
        
    }
    

}


//MARK: - UICollectionViewDataSource
extension MessageController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.message = messages[indexPath.item] // Add messge info to MessageCell
        cell.message?.user = user  //Add user info to get profile image
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension MessageController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Need to handle dynamic Cell sizing
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimateSizeCell = MessageCell(frame: frame)
        estimateSizeCell.message = messages[indexPath.row]
        estimateSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimateSize = estimateSizeCell.systemLayoutSizeFitting(targetSize)
        
        return CGSize(width: view.frame.width, height: estimateSize.height)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
}

//MARK: - CustomInputAccessoryViewDelegate
extension MessageController: CustomInputAccessoryViewDelegate {
    func didEndEditting() {
        logger("End Editting...")
        
    }
    
    func didBeginEditting() {
        logger("Begin editting..")
    }
    
    func inputView(_ inputView: CustomInputAccessoryView, _ message: String) {
        logger("Text send is \(message)")
        MessageService.shared.uploadMessage(message, toUser: user) { (error) in
            if let error = error {
                print("Debug: Failed to upload message with error: \(error.localizedDescription)")
                self.showError(withText: error.localizedDescription)
                return
            }
        }
    }
    
}

    
