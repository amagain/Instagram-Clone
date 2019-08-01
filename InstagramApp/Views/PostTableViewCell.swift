//
//  PostTableViewCell.swift
//  InstagramApp
//
//  Created by Gwinyai on 17/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userNameTitleButton: UIButton!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var postCommentLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var post: Post?
    
    weak var profileDelegate: ProfileDelegate?
    
    weak var feedDelegate: FeedDataDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        profileImage.layer.masksToBounds = true
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        
    }
    
    @IBAction func userNameButtonDidTouch(_ sender: Any) {
        
        profileDelegate?.userNameDidTouch()
        
    }
    
    @IBAction func likeButtonDidTouch(_ sender: Any) {
        
        
        
    }
    
    
}
