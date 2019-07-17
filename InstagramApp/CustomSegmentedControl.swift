//
//  CustomSegmentedControl.swift
//  InstagramApp
//
//  Created by User on 17/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

protocol ActivityDelegate: class {
    func scrollTo(index: Int)
}

class CustomSegmentedControl: UIView {
    
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentIndex = 0
    let buttonTitles: [String] = ["Following", "You"]
    let textColor: UIColor = .lightGray
    let selectorColor: UIColor = .black
    let selectorTextColor: UIColor = .black
    
    weak var delegate: ActivityDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    func updateView() {
        buttons.removeAll()
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        for buttonTitle in buttonTitles {
            let button = UIButton.init(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            //            button.addTarget(self, action: #selector(), for: .touchUpInside)
            buttons.append(button)
        }
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        let y = (self.frame.maxY - self.frame.minY) - 2.0
        selector = UIView.init(frame: CGRect.init(x: 0, y: y, width: selectorWidth, height: 2.0))
        selector.backgroundColor = selectorColor
        addSubview(selector)
        
    }
    
}
