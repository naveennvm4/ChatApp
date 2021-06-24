//
//  AuthenticationManager.swift
//  ChatApp2
//
//  Created by MackBookAir on 10/06/21.
//

import Foundation
import FirebaseAuth

struct AuthenticationManager {
    
    static func createUser(withEmail:String,password:String, completion:@escaping ((AuthDataResult?, Error?) -> Void)){
        
        Auth.auth().createUser(withEmail: withEmail, password: password, completion: completion )
        
    }
    
    static func loginUser(withEmail:String, password:String, completion:@escaping ((AuthDataResult?, Error?) -> Void)){
        
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: completion)
        
    }
    
    static func userLogout(){
        do{
            try FirebaseAuth.Auth.auth().signOut()
        }
        catch{
            
        }
    }
}
