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
        for pageToShow in pagesToShow {
            let page = newViewController(pageToShow: pageToShow)
            orderedViewControllers.append(page)
        }
        if let firstViewController = orderedViewControllers.first {
            
            setViewControllers([firstViewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(NewPostPageViewController.newPage(notification:)), name: NSNotification.Name(rawValue: "newPage"), object: nil)
    }
    
    @objc func newPage(notification: NSNotification) {
        if let receivedObject = notification.object as? NewPostPagesToShow {
            showViewController(index: receivedObject.rawValue)
        }
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
