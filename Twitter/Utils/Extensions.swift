//
//  Extensions.swift
//  TwitterTutorial
//
//  Created by Stephen Dowless on 1/12/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit
import JGProgressHUD

typealias AlertAction = ((UIAlertAction) -> Void)?

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }
    
    func centerX(inView view: UIView, top: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop!).isActive = true
        }
    }
    
    func centerY(inView view: UIView, left: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat? = nil, constant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant!).isActive = true
        
        if let left = left, let padding = paddingLeft {
            self.leftAnchor.constraint(equalTo: left, constant: padding).isActive = true
        }
    }
    
    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func addConstraintsToFillView(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        anchor(top: view.topAnchor, left: view.leftAnchor,
               bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
    }
    
    func clearShadow() {
        layer.shadowColor = UIColor.clear.cgColor
    }
}




extension UIViewController {
    static let hud = JGProgressHUD(style: .extraLight)
    
    func configureGradientLayer(fromColor start: UIColor, toColor end: UIColor) {
        let gradient =  CAGradientLayer()
        gradient.colors = [start.cgColor, end.cgColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame //Fit gradient to view
    }
    
    func showLoader(_ show: Bool, withText text: String = "Loading") {
        view.endEditing(true)
        if show {
             UIViewController.hud.textLabel.text = text
            UIViewController.hud.show(in: view)
        } else {
            UIViewController.hud.dismiss()
        }
        
    }
    
    func showError(withText text: String) {
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = text
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: view)
        hud.dismiss(afterDelay: 3.0)
    }
    
    func showAlert(withTitle title: String? = nil, withMessage message: String) {
        var alertTitle: String
        if let title = title {
            alertTitle = title
        } else {
            alertTitle = "Error"
        }
        
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func configureNavigationBar(withTitle title: String, prefersLargeTitles: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .backgroundColor
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.title = title
        
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark //Make the status bar white in color
    }
    
    func dismissKeyboardIfTappingOutside() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(false)
    }
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.color = .white
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            
            label.centerX(inView: view)
            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { (subview) in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3, animations: {
                        subview.alpha = 0
                    }, completion: { _ in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
        
    }
    
    func logger(withDebug debug: String) {
        print("Debug: \(debug)")
    }
    
    func sizeForText(withText text: String, forWidth width: CGFloat, fontSize size: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = text
        measurementLabel.numberOfLines = 0
        measurementLabel.font = UIFont.systemFont(ofSize: size)
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    func shouldHideActionButton(_ value: Bool) {
        if let tabBarController = self.tabBarController as? MainTabController {
            tabBarController.actionButton.isHidden = value
        }
    }
    
    func didSelectRetweet(_ retweet: AlertAction,
                          _ retweetWithComment: AlertAction ) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = .black
        
        let retweetAction = UIAlertAction(title: "Retweet", style: .default, handler: retweet)
        retweetAction.setValue(UIImage(systemName: "repeat"), forKey: "image")
        retweetAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
    
        let retweetWithCommentAction = UIAlertAction(title: "Retweet with comment", style: .default, handler: retweetWithComment)
        retweetWithCommentAction.setValue(UIImage(systemName: "square.and.pencil"), forKey: "image")
        retweetWithCommentAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        alertController.addAction(retweetAction)
        alertController.addAction(retweetWithCommentAction)
        
        presentAlert(alertController: alertController)
    }
    
    func didSelectTweetActionButton(forUsername username: String,
                                    _ notInterested: AlertAction,
                                    _ unfollow: AlertAction,
                                    _ mute: AlertAction,
                                    _ block: AlertAction,
                                    _ report: AlertAction ) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = .black
        
        let notInterestedAction = UIAlertAction(title: "Not interested in this", style: .default, handler: notInterested)
        notInterestedAction.setValue(UIImage(systemName: "hand.thumbsdown"), forKey: "image")
        notInterestedAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let unfollowAction = UIAlertAction(title: "Unfollow @\(username)", style: .default, handler: unfollow)
        unfollowAction.setValue(UIImage(systemName: "person.crop.circle.badge.xmark"), forKey: "image")
        unfollowAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let muteAction = UIAlertAction(title: "Mute @\(username)", style: .default, handler: mute)
        muteAction.setValue(UIImage(systemName: "xmark"), forKey: "image")
        muteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let blockAction = UIAlertAction(title: "Block @\(username)", style: .default, handler: block)
        blockAction.setValue(UIImage(systemName: "lock"), forKey: "image")
        blockAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let reportAction = UIAlertAction(title: "Report Tweet", style: .default, handler: report)
        reportAction.setValue(UIImage(systemName: "flag"), forKey: "image")
        reportAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        alertController.addAction(notInterestedAction)
        alertController.addAction(unfollowAction)
        alertController.addAction(muteAction)
        alertController.addAction(blockAction)
        alertController.addAction(reportAction)
        
        presentAlert(alertController: alertController)
    }
    
    func didSelectUserTweetAction(_ pinToProfile: AlertAction,
                                  _ deleteTweet: AlertAction) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = .black
        
        let pinToProfiledAction = UIAlertAction(title: "Pin to profile", style: .default, handler: pinToProfile)
        pinToProfiledAction.setValue(UIImage(systemName: "pin"), forKey: "image")
        pinToProfiledAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let deleteTweetAction = UIAlertAction(title: "Delete Tweet", style: .default, handler: pinToProfile)
        deleteTweetAction.setValue(UIImage(systemName: "trash"), forKey: "image")
        deleteTweetAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        alertController.addAction(pinToProfiledAction)
        alertController.addAction(deleteTweetAction)
        
        presentAlert(alertController: alertController)
    }
    
    func didSelectShareTweetAction(_ sendViaDirectionMessage: AlertAction,
                                   _ addToBookmarks: AlertAction,
                                   _ copyLinkToTweet: AlertAction,
                                   _ shareTweetVia: AlertAction ) {
        
        let alertController = UIAlertController(title: "Share Tweet", message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = .black
        alertController.setTitleFontSize(size: 20)
        
        let sendViaDirectionMessageAction = UIAlertAction(title: "Send via Direct Message", style: .default, handler: sendViaDirectionMessage)
        sendViaDirectionMessageAction.setValue(UIImage(systemName: "envelope"), forKey: "image")
        sendViaDirectionMessageAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let addToBookmarksMessageAction = UIAlertAction(title: "Add Tweet to Booknarks", style: .default, handler: addToBookmarks)
        addToBookmarksMessageAction.setValue(UIImage(systemName: "bookmark"), forKey: "image")
        addToBookmarksMessageAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let copyLinkToTweetMessageAction = UIAlertAction(title: "Copy link to Tweet", style: .default, handler: copyLinkToTweet)
        copyLinkToTweetMessageAction.setValue(UIImage(systemName: "doc.on.doc"), forKey: "image")
        copyLinkToTweetMessageAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let shareTweetViaAction = UIAlertAction(title: "Share Tweet via...", style: .default, handler: shareTweetVia)
        shareTweetViaAction.setValue(UIImage(named: "share")?.withRenderingMode(.alwaysOriginal), forKey: "image")
        shareTweetViaAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        alertController.addAction(sendViaDirectionMessageAction)
        alertController.addAction(addToBookmarksMessageAction)
        alertController.addAction(copyLinkToTweetMessageAction)
        alertController.addAction(shareTweetViaAction)
        
        presentAlert(alertController: alertController)
    }
    
    private func presentAlert(alertController: UIAlertController) {
        present(alertController, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
}







// MARK: - UIColor
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let twitterBlue = UIColor.rgb(red: 29, green: 161, blue: 242)
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
}


extension NSObject {
    func logger(_ text: String) {
        print("Debug: \(text)")
    }
}

//MARK: - UITableView
extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
    }

    func restore() {
        self.backgroundView = nil
    }
}

extension UIAlertController {
    func setTitleFontSize(size: CGFloat?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)
        
        if let size = size {
            attributeString.addAttributes([.font: UIFont.boldSystemFont(ofSize: size)],
                                          range: NSMakeRange(0, title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle")
    }
    
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first, let groupView = bgView.subviews.first, let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
}

extension UIApplication {
    class var topViewController: UIViewController? { return getTopViewController() }
    private class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.filter { $0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController { return getTopViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController { return getTopViewController(base: selected) }
        }
        if let presented = base?.presentedViewController { return getTopViewController(base: presented) }
        return base
    }

    private class func _share(_ data: [Any],
                              applicationActivities: [UIActivity]?,
                              setupViewControllerCompletion: ((UIActivityViewController) -> Void)?) {
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        setupViewControllerCompletion?(activityViewController)
        UIApplication.topViewController?.present(activityViewController, animated: true, completion: nil)
    }

    class func share(_ data: Any...,
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
    class func share(_ data: [Any],
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
}


//MARK: - Scroll
enum ScrollDirection {
    case Top
    case Right
    case Bottom
    case Left
    
    func contentOffsetWith(scrollView: UIScrollView) -> CGPoint {
        var contentOffset = CGPoint.zero
        switch self {
            case .Top:
                contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
            case .Right:
                contentOffset = CGPoint(x: scrollView.contentSize.width - scrollView.bounds.size.width, y: 0)
            case .Bottom:
                contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
            case .Left:
                contentOffset = CGPoint(x: -scrollView.contentInset.left, y: 0)
        }
        return contentOffset
    }
}

extension UIScrollView {
    func scrollTo(direction: ScrollDirection, animated: Bool = true) {
        self.setContentOffset(direction.contentOffsetWith(scrollView: self), animated: animated)
    }
    
    func scrollToBottom(animated: Bool) {
       if self.contentSize.height < self.bounds.size.height { return }
       let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
       self.setContentOffset(bottomOffset, animated: animated)
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}
