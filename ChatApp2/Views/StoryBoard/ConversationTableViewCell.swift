//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by MackBookAir on 04/06/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLable: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 21, weight: .semibold)
        return lable
    }()
    
    private let userMessageLable: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 19, weight: .regular)
        lable.numberOfLines = 0
        return lable
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLable)
        contentView.addSubview(userMessageLable)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 80,
                                     height: 80)
        userNameLable.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.heigth - 20) / 2 )
        userMessageLable.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLable.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.heigth - 20) / 2)
    }
    
    public func configure(with model: Conversation){
        self.userMessageLable.text = model.latestMessage.text
        self.userNameLable.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result{
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get  image url: \(error)")
            }
        })
    }
}
