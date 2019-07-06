//
//  ActivityData.swift
//  InstagramApp
//
//

import Foundation

import UIKit

struct Activity {
    
    var userImage: UIImage
    
    var details: String
    
}

class FollowingActivityModel {
    
    var followingActivity: [Activity] = [Activity]()
    
    init() {
        
        let user1 = User(name: "John Carmack", profileImage: UIImage(named: "user1")!)
        
        let user2 = User(name: "Bjarne Stroustrup", profileImage: UIImage(named: "user2")!)
        
        followingActivity.append(Activity(userImage: user1.profileImage, details: "\(user1.name) started following Bill"))
        
        followingActivity.append(Activity(userImage: user2.profileImage, details: "\(user2.name) started following Steve"))
        
    }
    
}

class YouActivityModel {
    
    var youActivity: [Activity] = [Activity]()
    
    init() {
        
        let user1 = User(name: "John Carmack", profileImage: UIImage(named: "user1")!)
        
        let user2 = User(name: "Bjarne Stroustrup", profileImage: UIImage(named: "user2")!)
        
        youActivity.append(Activity(userImage: user1.profileImage, details: "Follow \(user1.name) and others you may know to see thier photos and videos"))
        
        youActivity.append(Activity(userImage: user2.profileImage, details: "Follow \(user2.name) and others you may know to see their photos and videos"))
        
    }
    
}


