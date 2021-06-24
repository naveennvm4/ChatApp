//
//  StorageManager.swift
//  ChatApp
//
//  Created by MackBookAir on 31/05/21.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    /*
     /images/naveennvm4-gmail-com_profile_picture.png
     */
    
    public typealias uploadPictureCompletion = (Result<String, Error>) -> Void
    
    //Upload Profile Picture to Firebase Storage and returns completion with url string to download
    public func uploadProfilePic(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else{
                //Failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get Download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("Download URL returned:\(urlString)")
                completion(.success(urlString))
            })
        })
    }
    //Upload Photo that sent in the conversation
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion){
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: {[weak self] metadata, error in
            guard error == nil else{
                //Failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get Download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("Download URL returned:\(urlString)")
                completion(.success(urlString))
            })
        })
    }
    //Upload Video that sent in the conversation
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping uploadPictureCompletion){
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else{
                //Failed
                print("Failed to upload file to firebase for video")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("Failed to get Download URL")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("Download URL returned:\(urlString)")
                completion(.success(urlString))
            })
        })
    }
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadUrl
    }
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
}
