//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by MackBookAir on 30/05/21.
//

import UIKit
import JGProgressHUD

class SignUpViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 70
        imageView.isUserInteractionEnabled = true
        
        firstNameField.autocorrectionType = .no
        firstNameField.returnKeyType = .continue
        firstNameField.layer.cornerRadius = 12
        firstNameField.layer.borderWidth = 1
        firstNameField.layer.borderColor = UIColor.lightGray.cgColor
        firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        firstNameField.leftViewMode = .always
        firstNameField.backgroundColor = .white
        
        lastNameField.autocorrectionType = .no
        lastNameField.returnKeyType = .continue
        lastNameField.layer.cornerRadius = 12
        lastNameField.layer.borderWidth = 1
        lastNameField.layer.borderColor = UIColor.lightGray.cgColor
        lastNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        lastNameField.leftViewMode = .always
        lastNameField.backgroundColor = .white
        
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
        
        signUpButton.layer.cornerRadius = 12
        signUpButton.layer.masksToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapChangeProfilePic(){
        presntPhotoActionSheet()
        
    }
    
    @IBAction private func signUpButtonTapped(){
        
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        //Firebase Account Already Exists
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self]exists in
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else{
                // user already exists
                strongSelf.alertUserLoginError(message: "Email Address is already Exists")
                return
            }
            
            //Firebase User Creation
            AuthenticationManager.createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else{
                    print("Error creating User")
                    return
                }
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success{
                        //Upload Image
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else{
                            return
                        }
                        let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePic(with: data, fileName: filename, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage Manager Error: \(error)")
                            }
                        })
                    }
                })
                //Move to conversation View Controller
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTavBarVC = storyboard.instantiateViewController(identifier: "MainTabBarController")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTavBarVC)
            })
        })
    }
    
    func alertUserLoginError(message: String = "Please  Enter All Info to Create User"){
        let alret = UIAlertController(title: "Alert",
                                      message: message,
                                      preferredStyle: .alert)
        alret.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alret, animated: true)
    }
}


extension SignUpViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField{
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField{
            emailField.becomeFirstResponder()
        }
        else if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            signUpButtonTapped()
        }
        return true
    }

}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presntPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would yoou like to select a picture",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Choos Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
                                            }))
        present(actionSheet, animated: true)
        
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
