//
//  ActivityViewController.swift
//  InstagramApp
//
//  Created by User on 17/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var segmentedControl: CustomSegmentedControl! {
        didSet {
            segmentedControl.delegate = self
        }
    }
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    var currentIndex: Int = 0
    lazy var slides: [ActivityView] = {
    
        let followingActivityData = FollowingActivityModel()
        let followingView = Bundle.main.loadNibNamed("ActivityView", owner: nil, options: nil)?.first as! ActivityView
        followingView.activityData = followingActivityData.followingActivity
        
        let youActivityData = YouActivityModel()
        let youView = Bundle.main.loadNibNamed("ActivityView", owner: nil, options: nil)?.first as! ActivityView
        youView.activityData = youActivityData.youActivity
        
        return [followingView, youView]
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }


}
