//
//  ActivityView.swift
//  InstagramApp
//
//  Created by User on 17/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class ActivityView: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var activityData: [Activity] = [Activity]() {
        didSet {
            tableView.reloadData()
        }
    }
    override func awakeFromNib() {
        tableView.register(UINib(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: "ActivityTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ActivityView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80.0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        cell.profileImage.image = activityData[indexPath.row].userImage
        cell.detailsLabel.text = activityData[indexPath.row].details
        return cell
    }
}

extension ActivityView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityData.count
    }
}
