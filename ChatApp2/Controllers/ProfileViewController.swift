//
//  ProfileViewController.swift
//  ChatApp1
//
//  Created by MackBookAir on 08/06/21.
//
import UIKit
import SDWebImage

final class ProfileViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        accountButton.layer.masksToBounds = true
        accountButton.layer.cornerRadius = 12
        
        notificationButton.layer.masksToBounds = true
        notificationButton.layer.cornerRadius = 12
        
        settingButton.layer.masksToBounds = true
        settingButton.layer.cornerRadius = 12
        
        logOutButton.layer.masksToBounds = true
        logOutButton.layer.cornerRadius = 12
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                self.imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        nameLabel.text = UserDefaults.standard.value(forKey: "name") as? String
        emailLabel.text = UserDefaults.standard.value(forKey: "email") as? String
    }

    
    @IBAction func logOutButtonTapped(){
        let actionSheet = UIAlertController(title: "",
                                            message: "",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive,
                                            handler: { _ in
                                                UserDefaults.standard.setValue(nil, forKey: "email")
                                                UserDefaults.standard.setValue(nil, forKey: "name")
                                                AuthenticationManager.userLogout()
                                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                                let LoginVC = storyboard.instantiateViewController(identifier: "LoginNavigationVC")
                                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(LoginVC)
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        self.present(actionSheet, animated: true)
    }
}
