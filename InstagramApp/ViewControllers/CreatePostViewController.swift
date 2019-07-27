//
//  CreatePostViewController.swift
//  InstagramApp
//
//  Created by User on 27/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postCaptionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var postImage: UIImage!
    var activeTextView: UITextView?
    var keyboardNotification: NSNotification?
    
    lazy var touchView: UIView = {
        let _touchView = UIView()
        _touchView.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.0)
        let touchViewTapped = UIGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        _touchView.addGestureRecognizer(touchViewTapped)
        _touchView.isUserInteractionEnabled = true
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        return _touchView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImageView.image = postImage
        postCaptionTextView.layer.borderWidth = CGFloat(0.5)
        postCaptionTextView.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        postCaptionTextView.layer.cornerRadius = CGFloat(3.0)
        postCaptionTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotification()
    }
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        view.addSubview(touchView)
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 10.0), right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = UIScreen.main.bounds
        aRect.size.height -= keyboardSize!.height
        if activeTextView != nil {
            if (aRect.contains(activeTextView!.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWasHidden(notification: NSNotification) {
        touchView.removeFromSuperview()
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func postButtonDidTouch(_sender: Any) {
        
    }
}

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
}
