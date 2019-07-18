//
//  SignupViewController.swift
//  InstagramApp
//
//  Created by User on 18/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var animatedGradientView: AnimatedGradient!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeField: UITextField?
    var keyboardNotification: NSNotification?
    
    lazy var touchView: UIView = {
        let _touchView = UIView()
        _touchView.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.0)
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        _touchView.addGestureRecognizer(touchViewTapped)
        _touchView.isUserInteractionEnabled = true
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        return _touchView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.borderWidth = CGFloat(0.5)
        signUpButton.layer.borderColor = UIColor.white.cgColor
        signUpButton.layer.cornerRadius = CGFloat(3.0)
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatedGradientView.startAnimation()
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animatedGradientView.stopAnimation()
        deregisterForKeyboardNotifications()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillbeHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func signUpButtonDidTouch(_ sender: Any) {
        
        
    }
    
    @IBAction func alreadyHaveAnAccountButtonDidTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        view.addSubview(touchView)
        self.keyboardNotification = notification
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + 10), right: 0.0)
        self.scrollView.contentInset = contentInsets
        
        var aRect: CGRect = UIScreen.main.bounds
        aRect.size.height -= keyboardSize!.height
        if activeField != nil {
            if (!aRect.contains(activeField!.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                }
        }
    }
    
    @objc func keyboardWillbeHidden(notification: NSNotification) {
        touchView.removeFromSuperview()
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
}
extension SignupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
}
