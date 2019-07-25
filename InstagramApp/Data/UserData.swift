//
//  UserData.swift
//  InstagramApp
//
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

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

class UserModel {
    static var collection: DatabaseReference {
        get {
            return Database.database().reference().child("users")
        }
    }
    var username: String = ""
    var bio: String = ""
    init?(_ snapshot: DataSnapshot){
        guard let value = snapshot.value as? [String: Any] else { return nil }
        print(value)
        self.username = value["username"] as? String ?? "Failed"
        self.bio = value["bio"] as? String ?? "Failed"
    }
}

