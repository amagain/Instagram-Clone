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
        dataSource = self
        
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
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newPage"), object: nil)
    }
}

extension NewPostPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
}
