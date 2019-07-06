//
//  UserData.swift
//  InstagramApp
//
//

import Foundation

import UIKit

struct User {
    
    var name: String
    
    var profileImage: UIImage
    
}

class UsersModel {
    
    var users: [User] = [User]()
    
    init() {
        
        let user1 = User(name: "John Carmack", profileImage: UIImage(named: "user1")!)
        
        users.append(user1)
        
        let user2 = User(name: "Bjarne Stroustrup", profileImage: UIImage(named: "user2")!)
        
        users.append(user2)
        
    }
    
    
}
