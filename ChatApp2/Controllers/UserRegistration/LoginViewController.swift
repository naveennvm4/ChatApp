//
//  LoginViewController.swift
//  ChatApp
//
//  Created by MackBookAir on 30/05/21.
//

import UIKit
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var imageView: UIImageView!
        
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    private var loginObserver: NSObjectProtocol?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        
        emailField.autocorrectionType = .no
        emailField.returnKeyType = .continue
        emailField.layer.cornerRadius = 12
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.lightGray.cgColor
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        emailField.leftViewMode = .always
        emailField.backgroundColor = .white
        emailField.autocapitalizationType = .none
        
        passwordField.autocorrectionType = .no
        passwordField.returnKeyType = .done
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordField.leftViewMode = .always
        passwordField.backgroundColor = .white
        passwordField.isSecureTextEntry = true
        
        loginButton.layer.cornerRadius = 12
        loginButton.layer.masksToBounds = true
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    @IBAction private func loginButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard  let email = emailField.text,let password = passwordField.text, !email.isEmpty,!password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        //Firebase Login
        AuthenticationManager.loginUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else{
                print("Failed to login with email:\(email)")
                return
            }
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result{
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else{
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("failed to read data with error \(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("User Logged In: \(user)")
            //Move to conversation View Controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTavBarVC = storyboard.instantiateViewController(identifier: "MainTabBarController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTavBarVC)
        }
    }
    
    func alertUserLoginError(){
        let alret = UIAlertController(title: "Alert",
                                      message: "Please enter All Info to Login",
                                      preferredStyle: .alert)
        alret.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alret, animated: true)
    }
}


extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            loginButtonTapped()
        }
        return true
    }
}
