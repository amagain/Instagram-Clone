//
//  NewPostPageViewController.swift
//  InstagramApp
//
//  Created by User on 12/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class NewPostPageViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    var orderedViewControllers: [UIViewController] = [UIViewController]()
    var pagesToShow: [NewPostPagesToShow] = NewPostPagesToShow.PagesToShow()
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    private func newViewController(pageToShow: NewPostPagesToShow) -> UIViewController {
        var viewController: UIViewController!
        let newPostStoryboard = UIStoryboard(name: "NewPost", bundle: nil)
        
        switch pageToShow {
        case .camera:
            viewController = newPostStoryboard.instantiateViewController(withIdentifier: pageToShow.identifier) as! CameraViewController
        case .library:
            viewController = newPostStoryboard.instantiateViewController(withIdentifier: pageToShow.identifier) as! PhotoLibraryViewController
        }
        return viewController
    }
    
    func showViewController(index: Int) {
        if currentIndex > index {
            setViewControllers([orderedViewControllers[index]], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
        }
        else if currentIndex < index {
            setViewControllers([orderedViewControllers[index]], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        }
        currentIndex = index
    }
}
