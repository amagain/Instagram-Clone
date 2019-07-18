//
//  LoginViewController.swift
//  InstagramApp
//
//  Created by User on 18/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
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
        animatedGradientView.startAnimation()
        registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animatedGradientView.stopAnimation()
        deregisterKeyboardNotificatios()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillbeHidden(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func deregisterKeyboardNotificatios() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        
    }
    
    @objc func keyboardWillbeHidden(notification: NSNotification) {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func loginButtonDidTouch(_ sender: Any) {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        let spinner = UIViewController.displayLoading(withView: self.view)
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            guard let strongSelf = self else {return}
            DispatchQueue.main.async {
                UIViewController.removeLoading(spinner: spinner)
            }
            if error == nil {
                DispatchQueue.main.async {
                    //login
                }
            }
            else if let error = error {
                var errorTitle: String = "Login Error"
                var errorMessage: String = "Problem loggin in"
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .wrongPassword:
                        errorTitle = "Wrong Password"
                        errorMessage = " The password is wrong"
                    case .invalidEmail:
                        errorTitle = "Email invalid"
                        errorMessage = "Please enter a valid email"
                    default:
                        break
                    }
                    let alert = Helper.errorAlert(title: errorTitle, message: errorMessage)
                    DispatchQueue.main.async {
                        strongSelf.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func dontHaveAccountButtonDidTouch(_ sender: Any) {
        performSegue(withIdentifier: "SignupSegue", sender: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
}
