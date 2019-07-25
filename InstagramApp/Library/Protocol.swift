//
//  Protocol.swift
//  InstagramApp
//
//  Created by User on 26/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

protocol FeedDataDelegate: class {
    func commentsDidTouch(post: Post)
}

protocol ProfileDelegate: class {
    func userNameDidTouch()
}

protocol ActivityDelegate: class {
    func scrollTo(index: Int)
    func activityDidTouch()
}
protocol ProfileHeaderDelegate: class {
    func profileImageDidTouch()
}
